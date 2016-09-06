#!/bin/bash
# by wuboxiao

rm -rf ./tmp/*
rm -rf checkConfig.diff checkConfig.error checkConfig.result
if [ $4 -eq 1 ];then
   files=`find code/"$1"/src/main/resources/online -name "*.properties" 2> /dev/null`
elif [ $4 -eq 2 ];then
   files=`find code/"$1"/"$5"/src/main/resources/online -name "*.properties" 2> /dev/null`
elif [ $4 -eq 3 ];then
   files=`find code/"$1"/src/main/resources/conf/online -name "*.properties" 2> /dev/null`
fi

#feflag:是否存在配置文件缺失的标志
feflag=0
#fdifftflag:文件存在差异时的首行提示文字“缺失的配置项检查结果:”是否存在的标志
fdifftflag=0
for i in $files;do
   
    #checkFile=${i/online/"$2"}
    #原本用上一行就可以获得$2环境 的配置文件，但是由于global-online工程中包含online字样，所以利用下面的*贪婪匹配
    checkFile=`echo $i | sed -e "s/\(.*\)\/online\/\(.*\)/\1\/"$2"\/\2/"`
    #获取文件到环境的前缀，如haitao/src/online/ihome-asyn/disconf.properties,其前缀为haitao/src/online
    checkFilePrefix=`echo $checkFile | sed -e "s/\(.*\)\/"$2"\/\(.*\)/\1\/"$2"\//"`
    checkFileName=${checkFile##*/}
    if [ ! -f $checkFile ];then
       feflag=1
       echo -e "    "${checkFile#$checkFilePrefix} 1>> checkConfig.error
       echo "WARNING "$(date -d now '+%F %T')" "$2"环境缺少"$checkFileName"配置文件" 1>>log/check."$3".log
       continue
    fi
    #调用clearExSymbals.sh脚本预处理配置文件
    ./scripts/clearExSymbals.sh $i ./tmp/"$checkFileName".tmp1
    ./scripts/clearExSymbals.sh $checkFile ./tmp/"$checkFileName".tmp2
     
    online=./tmp/"$checkFileName".tmp1
    perforstable=./tmp/"$checkFileName".tmp2
    diff $online $perforstable 1>> checkConfig.result
   
    if [ $? -eq 0 ];then
       #两个文件完全一致 
       echo "INFO "$(date -d now '+%F %T')" "$2"环境的"$checkFileName"配置文件和online环境的配置文件完全一致" 1>>log/check."$3".log
       continue
    elif [ $? -eq 1 ];then     
       #结果为1代表两个配置文件有差异
       echo "WARNING "$(date -d now '+%F %T')" "$2"环境的"$checkFileName"配置文件和online环境的配置文件存在差异" 1>>log/check."$3".log
       if [ $fdifftflag -eq 0 ];then
        
          echo "缺失的配置项检查结果:" 1>> checkConfig.diff
          fdifftflag=1
       fi
       fdiflag=0
       cat $online | while read line
       do
           key=${line%%=*}
           key_find_line=`cat $perforstable | grep $key"="`
           key_find=${key_find_line%%=*}
           if [ "$key"x == "$key_find"x ];then
              continue
           fi

           if [ -z "$key_find" ];then
              if [ $fdiflag -eq 0 ];then 
		 echo -e $checkFileName 1>>checkConfig.diff
                 fdiflag=1
              fi    
              echo -e $key 1>>checkConfig.diff
           fi
       done
     rm -rf $online $perforstable
    fi
done
#缺失的配置文件都写到checkConfig.error中去了，统计行数即可算出缺失的配置文件数目
if [ ! -f checkConfig.error ];then
   lostfilenum=0
else
   lostfilenum=$(cat checkConfig.error | wc -l)
fi
#echo -e $2"缺少"$lostfilenum"个配置文件"
outputfile=result/"$3"/"$2"/"$1"
mkdir -p $outputfile
touch $outputfile/check"$1".txt
echo -e $1"工程："$2"环境缺少"$lostfilenum"个配置文件\n++++++++++++++++++++++++++++++++++++++++++++++++++" 1>>$outputfile/check"$1".txt

#echo -e "  \c"
#用顿号间隔打印输出
filelines=1
if [ $lostfilenum -ne 0 ];then
   echo -e "缺失的配置文件:\c" 1>>$outputfile/check"$1".txt
   cat checkConfig.error | while read line
   do 
      if [ $filelines -eq "$lostfilenum" ];then
         echo -e $line"\n++++++++++++++++++++++++++++++++++++++++++++++++++" 1>>$outputfile/check"$1".txt
         break
      fi
      echo -e $line"、\c" 1>>$outputfile/check"$1".txt
      ((filelines++))
   done
fi
#echo ""
#缺失的配置项和所在配置文件名都记录到checkConfig.diff中了
if [ ! -f checkConfig.diff ];then
   alllostitem=1
   chkfilelines=1
else
   chkfilelines=$(cat checkConfig.diff | wc -l)
   alllostitem=$(grep -v '.properties' checkConfig.diff | wc -l)
fi
sed -i '1s/^.*/、'"$2"'缺少'"$((alllostitem-1))"'个配置项/g' checkConfig.diff
sed -i '1s/$/&'"、缺少"$((alllostitem-1))"个配置项，"'/g' $outputfile/check"$1".txt
#如果只有一行，表示没有配置项缺失
if [ $chkfilelines -eq 1 ];then
   echo "无配置项缺失" 1>> checkConfig.diff
   #cat checkConfig.diff
else 
   #接下来统计缺失的配置项个数
   prop_file_nums=`cat checkConfig.diff | grep "properties" | wc -l`
   file_count_pos=1
   #echo $file_count_pos" "$prop_file_nums
   while [[ $file_count_pos -le $prop_file_nums ]];do
       if [[ $file_count_pos -eq $prop_file_nums ]];then
          error_item_pre=`grep -n ".properties" checkConfig.diff | head -"$file_count_pos" | tail -1 | awk -F ':' '{print $1}'`
          lines_nums=`cat checkConfig.diff | wc -l`
          sed -i "$error_item_pre"'s/$/&有'"$((lines_nums-error_item_pre))"'个配置项缺失/g' checkConfig.diff
          awk 'NR=='"$error_item_pre" checkConfig.diff 1>>$outputfile/check"$1".txt
          echo -e "\c" 1>>$outputfile/check"$1".txt
          awk 'NR>'"$error_item_pre"' && NR<'"$lines_nums" checkConfig.diff | while read eachitem
          do
              echo -e  $eachitem"、\c" 1>>$outputfile/check"$1".txt
          done
          awk 'NR=='"$lines_nums" checkConfig.diff 1>>$outputfile/check"$1".txt
          echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++" 1>>$outputfile/check"$1".txt
          ((file_count_pos++))
          break
       fi
       error_item_pre=`grep -n ".properties" checkConfig.diff | head -"$file_count_pos" | tail -1 | awk -F ':' '{print $1}'`
       error_item_next=`grep -n ".properties" checkConfig.diff | head -"$((++file_count_pos))" | tail -1 | awk -F ':' '{print $1}'`
      # sed -i "$error_item_pre"'s/$/&有'"$((error_item_next-error_item_pre-1))"'个配置项缺失/g' checkConfig.diff
       sed -i "$error_item_pre"'s/$/&有'"$((error_item_next-error_item_pre-1))"'个配置项缺失/g' checkConfig.diff
       awk 'NR=='"$error_item_pre" checkConfig.diff 1>>$outputfile/check"$1".txt
       echo -e  "\c" 1>>$outputfile/check"$1".txt
       awk 'NR>'"$error_item_pre"' && NR<'"$((error_item_next-1))" checkConfig.diff | while read eachitem
       do
           echo -e $eachitem"、\c" 1>>$outputfile/check"$1".txt
       done
       awk 'NR=='"$((error_item_next-1))" checkConfig.diff 1>>$outputfile/check"$1".txt
       echo -e "" 1>>$outputfile/check"$1".txt
       ((file_count_pos++))
   done
fi
if [ "$1" == "global-ms" ];then
 cp checkConfig.diff checkConfig.difftmp
fi
rm -rf check.result  checkConfig.error  checkConfig.result checkConfig.diff
