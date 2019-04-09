#!/bin/bash

###################################
#删除早于12天的ES集群的索引
###################################
function delete_indices() {
    comp_date=`date -d "12 day ago" +"%Y-%m-%d"`   #要保留几天的数据这里自定义即可`data -d "12 day ago"`
    date1="$1 00:00:00"
    date2="$comp_date 00:00:00"

    t1=`date -d "$date1" +%s`
    t2=`date -d "$date2" +%s`

    if [ $t1 -le $t2 ]; then
        echo "$1时间早于$comp_date，进行索引删除"
        #转换一下格式，将类似2019-01-02格式转化为20190102
        format_date=`echo $1| sed 's/-/\./g'`
        curl -XDELETE http://10.100.5.14:9200/*$format_date
    fi
}

curl -XGET http://10.100.5.14:9200/_cat/indices | awk -F" " '{print $3}' | awk -F"-" '{print $NF}' | egrep "[0-9]*\.[0-9]*\.[0-9]*" | sort | uniq  | sed 's/\./-/g' | while read LINE
do
    #调用索引删除函数
    delete_indices $LINE
done

