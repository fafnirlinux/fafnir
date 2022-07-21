/* This is https://fenua.org/gaetan/src/usocks-0.7.c */
/*
 * Copyright (C) 2013-2018, Gaetan Bisson <bisson@archlinux.org>.
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
 * SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
 * OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
 * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

/*
 * USocks. Minimalistic SOCKS5 proxying library.
 *
 * USocks implements a connect() function over the system one in order to
 * forward connections through a prescribed SOCKS5 proxy; its design focuses
 * are code clarity and conciseness.
 *
 * Compile with:
 *
 *   cc -O2 -fPIC -ldl -shared -o usocks.so usocks.c
 *
 * Use by exporting:
 *
 *   USOCKS_PORT=7772
 *   USOCKS_ADDR=127.0.0.1
 *   LD_PRELOAD=`pwd`/usocks.so
 */


/* ****************************************************************************
 *
 * HEADERS
 *
 */


#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <dlfcn.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>


/* ****************************************************************************
 *
 * INITIALIZE PROXY DATA AND LOCATE SYSTEM FUNCTIONS
 *
 */


struct sockaddr_in us_proxy;

typedef int (*connect_t)(int, const struct sockaddr *, socklen_t);
connect_t sys_connect;

int us_init (void) {
	char *port = getenv("USOCKS_PORT");
	char *addr = getenv("USOCKS_ADDR");
	if (!port) return -1;
	if (!addr) return -1;

	memset(&us_proxy, 0, sizeof(us_proxy));
	us_proxy.sin_family = AF_INET;
	us_proxy.sin_port = htons(atoi(port));
	us_proxy.sin_addr.s_addr = inet_addr(addr);

	sys_connect = (connect_t)(intptr_t)dlsym(RTLD_NEXT, "connect");
	return 0;
}


/* ****************************************************************************
 *
 * LEAVE NO BYTES BEHIND
 *
 */


int us_sendall (int socket, const char *buffer, size_t length, int flags) {
	int r, off=0;
	while(off<length) {
		r = send(socket, buffer+off, length-off, flags);
		if (r<0) return -1;
		off += r;
	}
	return off;
}

int us_recvall (int socket, char *buffer, size_t length, int flags) {
	int r, off=0;
	while (off<length) {
		r = recv(socket, buffer+off, length-off, flags);
		if (r<0) return -1;
		off += r;
	}
	return off;
}


/* ****************************************************************************
 *
 * REDEFINE CONNECT()
 *
 */


const unsigned char l4[] = { 0x7f };                                            /* matches loopback IPv4 addresses    */
const unsigned char l6[] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 };  /* matches loopback IPv6 address      */
const unsigned char l64[] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0xff, 0xff, 0x7f }; /* matches loopback IPv6to4 addresses */

int connect (int sock, const struct sockaddr *addr, socklen_t len) {
	int p, t, v, f=sizeof(t);
	char b[256];

	if (!sys_connect) if (us_init()) return -1;

	/* let unix domain sockets and loopback traffic through */
	switch (addr->sa_family) {
		case AF_UNIX:
			return sys_connect(sock,addr,len);
		case AF_INET6:
#if 0
			if (!memcmp(&(((struct sockaddr_in6 *)addr)->sin6_addr.s6_addr), l64, 13) ||
			    !memcmp(&(((struct sockaddr_in6 *)addr)->sin6_addr.s6_addr), l6, 16))
				return sys_connect(sock,addr,len);
#endif
			v=16;
			break;
		case AF_INET:
#if 0
			/*if (!memcmp(&(((struct sockaddr_in *)addr)->sin_addr.s_addr), l4, 1))
				return sys_connect(sock,addr,len);*/
#endif
			v=4;
			break;
		default:
			return -1;
	}

	/* let non-TCP through */
	getsockopt(sock, SOL_SOCKET, SO_TYPE, &t, (socklen_t *)&f);
	if (t!=SOCK_STREAM) return sys_connect(sock,addr,len);

	/* open blocking connection to proxy */
	f = fcntl(sock, F_GETFL);
	p = socket(AF_INET, SOCK_STREAM, 0);
	fcntl(p, F_SETFL, f & ~O_NONBLOCK);
	if (sys_connect(p,(struct sockaddr*)&us_proxy,sizeof(us_proxy))) return -1;

	/* protocol version and authentication method */
	memcpy(b, "\x05\x01\x00", 3);
	if (us_sendall(p,b,3,0)!=3) goto err;
	if (us_recvall(p,b,2,0)!=2) goto err;
	if (memcmp(b,"\x05\x00",2)) goto err;

	/* connection request */
	memcpy(b, "\x05\x01\x00", 3);
	if (v==4) {
		b[3] = '\x01';
		memcpy(b+4, &(((struct sockaddr_in *)addr)->sin_addr.s_addr), 4);
		memcpy(b+8, &(((struct sockaddr_in *)addr)->sin_port), 2);
	} else {
		b[3] = '\x04';
		memcpy(b+4, &(((struct sockaddr_in6 *)addr)->sin6_addr.s6_addr), 16);
		memcpy(b+20, &(((struct sockaddr_in6 *)addr)->sin6_port), 2);
	}
	if (us_sendall(p,b,v+6,0)!=v+6) goto err;
	if (us_recvall(p,b,4,0)!=4) goto err;
	if (memcmp(b,"\x05\x00\x00",3)) goto err;
	if (us_recvall(p,b,v+2,0)!=v+2) goto err;

	/* return proxy socket */
	close(sock);
	fcntl(p, F_SETFL, f);
	fcntl(p, F_DUPFD, sock);

	return 0;

err:
	close(p);
	return -1;
}
