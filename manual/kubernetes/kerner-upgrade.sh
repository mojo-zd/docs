#!/usr/bin/expect

while read line
do
	if [ -n "$line" ]; then
		# 上传脚本到目标主机
		spawn scp ./demo.sh $line:/root
		expect "*password:"
		send `5HERoV1XxXspYy3l\r`
		# 登录到目标服务器
		spawn ssh -I root $line
		expect "*password:"
		send `5HERoV1XxXspYy3l\r`
		expect "]# "
		send "exec ./demo.sh\r"
		send "exit\r"
		expect eof
	fi
done < host-list.txt