#!/bin/zsh
# 这个脚本可以根据文件16进制判断压缩格式，然后通过对应命令解压
# 解压函数:file接收文件名,cmd接收命令,opt参数选项
decompress() { 
	file=$1
	cmd=$2
	opt=$3
	$cmd $opt $file 
}


# 数组：存储支持的压缩格式和对应的文件头和解压命令
# 每个元素的格式为：文件16进制头:解压命令:选项
formats=(
377abcaf:7z:x
213c6172:ar:x
425a6839:bunzip2:
504b0304:unzip:
7f454c46:7z:x
1f8b0808:gunzip:
5d000080:unlzma:
1f8b0800:tar:-zxvf
fd377a58:unxz:
)
#判断是否为tar
filesion=$(file $1 | cut -d':' -f2-)
if  [[ "$filesion" == *tar* ]]; then
	tar -xvf "$1"	
#判断是否为文件
elif [[ -f $1 ]]; then
	header=$(xxd -p -l 4 $1)
# 定义一个变量，表示是否找到匹配的格式
	found=0
# 遍历数组，匹配文件头和解压命令
	for format in $formats; do
# 使用IFS分隔数组元素的各个字段
		IFS=: read head cmd opt <<< $format
# 如果文件头匹配，调用解压函数，并设置found为1
		if [[ $header == $head* ]]; then
			decompress $1 $cmd $opt
			found=1
			break
		fi
	done
# 如果没有找到匹配的格式，打印提示信息
	if [[ $found == 0 ]]; then
		echo "无法识别的压缩格式"
	fi
else
	echo "不是一个文件"
	fi


