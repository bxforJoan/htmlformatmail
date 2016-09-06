cat $1 |  egrep -v " +$" | sed s/[[:space:]]//g | grep -v "^#" | grep -E "=|\[" | while read line;do
   len=`echo $line |  wc -L`
   if [[ $len -gt 0 ]];then
      echo $line >> $2
   fi
done
