#!/bin/bash
# by hzwuboxiao
#rm -rf result/ messageContent.txt
rm -rf ./result/table_result_wrong_item.tmp

tableresult=./result/table_result_wrong_item.tmp

current_time=`date -d now "+%F_%H%M%S"`

for param in $*;do


for folder in $(ls -l code/ |grep "^d" |awk '{print $9}');do
   echo "INFO "$(date -d now '+%F %T')" 开始处理"$folder"工程" 1>>log/check."$current_time".log
   #echo "找到的目录"$folder
   #如果该工程下环境不存在，则跳过

   #有些工程路径不严格遵守"工程名/src/main/resources/环境名"的格式，则按照下面的规则处理
   # need_change_path_flag
   #	=1: 不需要改变路径
   #	=2：需要改变路径，$path_name是需要改变的路径的名称
   #	=3：直接在后面加conf
   need_change_path_flag=1
   path_name="not_used"
   if [[ "$folder"x == "disconf"x || "$folder"x == "haitao-matter"x ]];then
       need_change_path_flag=2
       path_name=$folder"-web"
       if [ ! -d "code/"$folder"/"$folder"-web/src/main/resources/"$param ];then
          echo "ERROR "$(date -d now '+%F %T')" "$folder"工程中"$param"环境不存在" 1>>log/check."$current_time".log
          continue
       fi
   elif [[ "$folder"x == "haitao"x || "$folder"x == "haitao-pay"x ]];then
       need_change_path_flag=3
   
       if [ ! -d "code/"$folder"/src/main/resources/conf/"$param ];then
          echo "ERROR "$(date -d now '+%F %T')" "$folder"工程中"$param"环境不存在" 1>>log/check."$current_time".log
          continue
       fi
   elif [ "$folder"x == "global-ms"x ];then
       need_change_path_flag=2
       path_name="kaola-ms-war"
       if [ ! -d "code/"$folder"/kaola-ms-war/src/main/resources/"$param ];then
          echo "ERROR "$(date -d now '+%F %T')" "$folder"工程中"$param"环境不存在" 1>>log/check."$current_time".log
          continue
       fi
   elif [ "$folder"x == "global-online"x ];then
       need_change_path_flag=2
       path_name="online-war"
       if [ ! -d "code/"$folder"/online-war/src/main/resources/"$param ];then
          echo "ERROR "$(date -d now '+%F %T')" "$folder"工程中"$param"环境不存在" 1>>log/check."$current_time".log
          continue
       fi
   else
    if [ ! -d "code/"$folder"/src/main/resources/"$param ];then
       echo "ERROR "$(date -d now '+%F %T')" "$folder"工程中"$param"环境不存在" 1>>log/check."$current_time".log
       continue
    fi
  fi
 
   echo "INFO "$(date -d now '+%F %T')" 开始检查"$param"环境和online环境下的配置文件异同" 1>>log/check."$current_time".log

   ./scripts/newCheck.sh $folder  $param $current_time $need_change_path_flag $path_name

   echo "INFO "$(date -d now '+%F %T')" 检查"$param"环境和online环境下的配置文件异同完成" 1>>log/check."$current_time".log
   echo "INFO "$(date -d now '+%F %T')" 开始检查"$param"环境的配置文件的错误配置项，基于标准配置文件" 1>>log/check."$current_time".log
   echo "开始写入"$folder"---->"$param
   echo "["$param"."$folder"]" 1>> $tableresult
   ./scripts/createTxt.sh $folder ./stdprops/"$param"/"$folder".txt $param $current_time $need_change_path_flag $path_name $tableresult

   echo "INFO "$(date -d now '+%F %T')" 检查"$param"环境的配置文件的错误配置项完成" 1>>log/check."$current_time".log
   echo "INFO "$(date -d now '+%F %T')" 处理"$folder"工程完成" 1>>log/check."$current_time".log
done


echo "INFO "$(date -d now '+%F %T')" 开始收集检测结果..." 1>>log/check."$current_time".log
if [  -d "./result" ]; then
   files=`find ./result/"$current_time"/"$param"/ -name "*.txt" 2> /dev/null`
   
   echo $param"环境" 1>>mail/messageContent/messageContent."$current_time".txt

   for file in $files;do 

   projNameTmp=`echo ${file##*/} |  cut -d '.' -f1`
   projName=${projNameTmp##*check}
   #echo "工程名"$projName" 文件名"$file
   nums=`echo $(cat $file | head -1) | grep -o '[0-9]\+'`
   lostfiles=`echo $nums | awk -F ' ' '{print $1}'`
   lostitems=`echo $nums | awk -F ' ' '{print $2}'`
   wrongitems=`echo $nums | awk -F ' ' '{print $3}'`
   #如果没有错误，将那些生成的文件都删了
   if [ $lostfiles -eq 0 ] && [ $lostitems -eq 0 ] && [ $wrongitems -eq 0 ];then
      rm -rf $file
   fi
   mkdir -p mail/messageContent
   #echo $param"环境:" 1>>mail/messageContent/messageContent."$current_time".txt
   echo $projName"工程：缺少"$lostfiles"个配置文件，"$lostitems"个配置项，对比标准配置文件，有"$wrongitems"个错误配置项" 1>>mail/messageContent/messageContent."$current_time".txt
   done
   echo "" 1>>mail/messageContent/messageContent."$current_time".txt
   tar -cf  ./result/result"$current_time".tar ./result/"$current_time"/
   #rm -rf ./result/"$current_time"
  
fi
echo "INFO "$(date -d now '+%F %T')" 检测结果收集完成!请到mail/和result/下查看结果" 1>>log/check."$current_time".log

done



#delete a tmp file
#rm -rf $tableresult


echo $current_time
./createTableResult.sh "not_used" $current_time

#check_time=${current_time}
#echo ${check_time}
da=`date "+%Y-%m-%d"`


subject="配置文件校验结果("$da")"
msgContent=./mail/messageContent/messageContent."$current_time".txt
attachment=./result/result"$current_time".tar

#mutt hzzhuliqing@corp.netease.com,hzwuboxiao@corp.netease.com -e "my_hdr from:hzzhuliqing@corp.netease.com" -s $subject -a $attachment  < $msgContent
mutt hzwuboxiao@corp.netease.com -e "my_hdr from:wbxstudy@163.com" -s $subject -a $attachment  < $msgContent

