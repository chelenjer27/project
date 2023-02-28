#!/bin/bash


PATH="/sbin:/usr/sbin:/usr/local/sbin:/bin:/usr/bin:/usr/local/bin"                                                                                            
 
if pidof -x $(basename $0) > /dev/null; then
   for p in $(pidof -x $(basename $0)); do
   if [ $p -ne $$ ]; then
   echo "Script $0 is already running: exiting"
    exit
   fi
   done
fi


# variables
LOGFILE="access.log"
#LOGFILE_GZ="/var/log/nginx/access.log.*"
RESPONSE_CODE="200"




# functions
filters(){
awk '$9==200' \
| grep -v "\/rss\/" \
| grep -v robots.txt \
| grep -v "\.css" \
| grep -v "\.jss*" \
| grep -v "\.png" \
| grep -v "\.ico"
}

filters_404(){
grep "404"
}

request_ips(){
awk '{print $1}'
}

request_method(){
awk '{print $6}' \
| cut -d'"' -f2
}

request_pages(){
awk '{print $7}'
}

wordcount(){
sort \
| uniq -c
}

sort_desc(){
sort -rn
}

return_kv(){
awk '{print $1, $2}'
}

return_top_ten(){
head -10
}

## actions
get_request_ips(){
echo ""
echo  $(date)"Top 10 Request IP's:"
echo "===================="

cat $LOGFILE \
| filters \
| request_ips \
| wordcount \
| sort_desc \
| return_kv \
| return_top_ten
echo ""
}

get_request_methods(){
echo $(date) "Top Request Methods:"
echo "===================="
cat $LOGFILE \
| filters \
| request_method \
| wordcount \
| return_kv
echo ""
}

get_request_pages_404(){
echo $(date) "Top 10: 404 Page Responses:"
echo "==========================="
zgrep '-' $LOGFILE $LOGFILE_GZ\
| filters_404 \
| request_pages \
| wordcount \
| sort_desc \
| return_kv \
| return_top_ten
echo ""
}


get_request_pages(){
echo $(date) "Top 10 Request Pages:"
echo "====================="
cat $LOGFILE \
| filters \
| request_pages \
| wordcount \
| sort_desc \
| return_kv \
| return_top_ten
echo ""
}

get_request_pages_all(){
echo $(date) "Top 10 Request Pages from All Logs:"
echo "==================================="
zgrep '-' --no-filename $LOGFILE $LOGFILE_GZ \
| filters \
| request_pages \
| wordcount \
| sort_desc \
| return_kv \
| return_top_ten
echo ""
}

exec 1>nginx.log

get_request_ips
get_request_methods
get_request_pages
get_request_pages_all
get_request_pages_404

echo 'Attachment'|mail -s 'Nginx log Alert' postmaster@domen.local -a ./nginx.log