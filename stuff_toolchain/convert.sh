#!/bin/sh

if [[ -z $1 ]]; then
	echo "no package defined"
	exit 1
fi

if [[ -z $2 ]]; then
	echo "no section defined"
	exit 1
elif [[ ! -d $2 ]]; then
	echo "section doesnt exit"
	exit 1
fi

if [[ ! -d $2/$1 ]]; then
	echo "package doesnt exist: $1"
	exit 1
fi

mkdir -p out/pkg/$2 out/stuff

name=$1
file=$2/$name/Pkgfile

target=out/pkg/$2/$name

if [[ -f $target ]]; then
	rm $target
fi

ver_line=$(grep -m 1 'version=' $file)

if [[ -n $ver_line ]]; then

ver=${ver_line#"version="}

echo "ver=$ver" >> $target
echo "" >> $target

fi

line=$(grep '# Depends on' $file)

if [[ -n $line ]]; then

eval arr=(${line#"# Depends on: "})

if (( ${#arr[@]} > 0 )); then
	echo "[deps]" >> $target

	for dep in "${arr[@]}"
	do
  		echo $dep >> $target
	done

	echo "" >> $target
fi

fi

linee=$(grep "source=(" $file)

src=${linee#"source=("}
src=${src//[[:blank:]]/}

if [[ ${src: -1} == ')' ]] || [[ ${src: -1} == '\' ]]; then
	src=${src::-1}
fi

if [[ -n $src ]]; then
	echo "[srcs]" >> $target
	src="${src//'$name'/%name}"
	src="${src//'${name}'/%name}"
	src="${src//'$version'/%ver}"
	src="${src//'${version}'/%ver}"
	src="${src//'${version%.*}'/${ver%.*}}"
	echo $src >> $target
	echo "" >> $target
fi

linenum=0
if [[ -n $(grep -m 1 'build()' $file) ]]; then
	linenum=$(grep -n 'build()' $file | head -n 1 | cut -d: -f1)
fi

if [[ $linenum == 0 ]]; then
	if [[ -n $(grep -m 1 'build ()' $file) ]]; then
		linenum=$(grep -n 'build ()' $file | head -n 1 | cut -d: -f1)
	fi
fi

if [[ $linenum != 0 ]]; then

linecount=$(wc -l < $file)

for_start=no

echo "[build]" >> $target

for (( i=$linenum+1; i<=$linecount-1; i++ )); do
	line=$(sed -n "${i}p" < $file)

	if [[ -z $line ]]; then
		continue;
	fi

	if [[ $line == *"cd $name"* ]] || [[ $line == *'cd $name'* ]] || [[ $line == *'cd $SRC'* ]]; then
		continue
	fi

	line="${line//'$name'/%name}"
	line="${line//'${name}'/%name}"
	line="${line//'$version'/%ver}"
	line="${line//'${version}'/%ver}"

	line="${line//'${version%.*}'/${ver%.*}}"

	line=${line//'"$PKG"'/"%dest"}
	line=${line//'$PKG'/"%dest"}

	line=${line//'"${PKG}"'/"%dest"}
	line=${line//'${PKG}'/"%dest"}

	line=${line//'"$SRC"'/"%files"}
	line=${line//'$SRC'/"%files"}

	line=${line//'"${SRC}"'/"%files"}
	line=${line//'${SRC}'/"%files"}

	line=${line//"%dest/usr"/"%dest"}

	line=${line/"--prefix=/usr"/"--prefix=%prefix"}

	line=${line//"=/usr"/"="}

	line=${line/"./configure"/"%conf"}
	line=${line/"%conf --prefix=%prefix"/"%conf"}

	if [[ $line == *"../%name-%ver/configure"* ]]; then
		echo '.%conf \' >> $target
		continue;
	fi

	if [[ ${line//[[:blank:]]/} == "--prefix"* ]]; then
		continue;
	fi

	if [[ $line == *"make" ]]; then
		echo "%make" >> $target
		continue;
	fi

	if [[ $line == *"patch" ]]; then
		continue;
	fi

	if [[ $line == *"make DESTDIR=%dest install" ]] || [[ $line == *"make install DESTDIR=%dest" ]]; then
		echo "%inst" >> $target
		continue;
	fi

	first=$(echo $line | cut -c 1)

	if [[ $first == '#' ]] || [[ $first == '{' ]]; then
		continue;
	fi

	if [[ $line == *"done" ]]; then
		for_start=no
	fi

	if [[ $first == '-' ]] || [[ $for_start == yes ]]; then
		line="\t$line"
	fi

	if [[ $line == *"for "* ]]; then
		for_start=yes
	fi

	line=${line/'ln -sf ../../'/'ln -sf ../'}

	echo -e $line >> $target
done
fi

for entry in $2/$name/*; do
	if [[ $(basename $entry) != "Pkgfile" ]]; then
		mkdir -p out/stuff/$name

		if [[ $(basename $entry) == *".patch" ]] || [[ $(basename $entry) == *".diff" ]]; then
			mkdir -p out/stuff/$name/patches
			cp $entry out/stuff/$name/patches
		else
			cp $entry out/stuff/$name
		fi
	fi
done

exit 0
