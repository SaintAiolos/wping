#!/bin/bash
# make linux'ping windows-like
max=0
min=2000
avg=0
sum=0
tmp=0
count=0
reveive=0
lost=0
per=0
PINGRESULT=`date +%N`
if [ $# -ne 1 ];then
	echo "usage: $0  <host>"
	exit 1
fi
echo "Pinging $1 with 32 bytes of data:"
while ((1))
do
ping -s 24 -c 1 -W 1 $1>/tmp/.winping$PINGRESULT
if [ $? -ne 0 ];then
	let lost++
	let count++
	echo "Request time out."
else
	let receive++
	let count++
	cat /tmp/.winping$PINGRESULT|sed -n 's/icmp_seq=1/icmp_seq='$count'/p'
	tmp=`cat /tmp/.winping$PINGRESULT|sed -n '/32 byte/p'|awk '{print $7}'|awk -F '=' '{print $2}'|awk '{print $1}'`
	if [ $(echo "$tmp > $max"|bc) -eq 1 ];then
		max=`echo "$tmp"|bc -l`
	fi
	if [ $(echo "$tmp < $min"|bc) -eq 1 ];then
		min=`echo "$tmp"|bc -l`
	fi
	sum=`echo "$sum + $tmp"|bc -l`
	avg=`echo "scale=2;$sum/$receive"|bc -l`
	per=`echo "scale=2;$(echo "$lost/$count*100"|bc -l)/1"|bc -l`
	sleep 1
fi
trap 'echo -e "\nPing statistics for $1:\n  Packets:Sent = $count, Receive = $receive, Lost = $lost <$per %>,\nApproximate round trip times in milli-seconds:\n  Minimum = $min ms, Maximum = $max ms, Average = $avg ms" && exit 0' INT
done
exit 0
