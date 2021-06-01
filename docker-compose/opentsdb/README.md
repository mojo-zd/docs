以下tsdb打头的命令需要进入opentsdb容器执行。
- start-time、end-time格式请参考 http://opentsdb.net/docs/build/html/user_guide/query/dates.html

- 删除metrics脚本参考 https://gist.github.com/dimamedvedev/f45a2a0b092ff9f9f777

- query metrics http://opentsdb.net/docs/build/html/user_guide/cli/query.html
```
tsdb query 1h-ago 1m-ago sum proc.loadavg.1m
```
注:操作前请确认主机时间和容器时间是否同步。如果时间不同步处理时候可以采用一下思路
1. 同步容器和主机时间,采集的metrics是以主机的时间为准,需要矫正容器时间为主机时间
2. 在容器中执行命令操作时,自动加减容器与主机的时间差
### test
- install nc
```
yum install nmap-ncat.x86_64
```
- create metrics(采集linux metrics写入opentsdb), 创建metrics有多种方式(HTTP APIs| Telnet),telnet用户测试比较方便。

metrics: proc.loadavg.1m、proc.loadavg.5m
```
cat >loadavg-collector.sh <<\EOF
#!/bin/bash
set -e
while true; do
  awk -v now=`date +%s` -v host=`hostname` \
  '{ print "put proc.loadavg.1m " now " " $1 " host=" host;
    print "put proc.loadavg.5m " now " " $2 " host=" host }' /proc/loadavg
  sleep 15
done | nc -w 30 host.name.of.tsd PORT
EOF
```
- delete metrics of duration
```
tsdb uid grep . | awk {'print $2'} #获取所有metrics
tsdb scan --delete 10m-ago 3m-ago sum proc.loadavg.1m
```
注: opentsdb的query|delete操作中的 start-end time以hour为单位。
eg: 当前时间为2:40, start: 30m-ago  end:1m-ago查询的是2:00-2:40的数据并不是2:10-2:40的数据。