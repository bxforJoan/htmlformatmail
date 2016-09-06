#!/bin/bash
# by hzwuboxiao

rm -rf std_chk.error wubox.res
std_cfg_files=$(python -c 'import parserutil;parserutil.ConfigUtil("'$2'").get_prop_file_name()')
#错误配置项总数
wrong_item_nums=0
#字符最大宽度，用于格式化显示
max_width=0
#配置文件个数，用于统计每个配置文件的错误配置项个数
file_count=0
#文件是否错误的标志
error_file_flag=0
for std_cfg_file in $std_cfg_files
do
   error_file_flag=0
   std_prop_file=${std_cfg_file//[\[\',\]]/}


   #预处理标准配置文件，有些配置项是sql=select from sys date这种各个词之间有空格的
   ./scripts/clearExSymbals.sh $2 ./tmp/"$std_prop_file".cmp.tmp1
   std_conf=./tmp/"$std_prop_file".cmp.tmp1


   if [ $5 -eq 1 ];then
      files=`find code/"$1"/src/main/resources/"$3"/ -name  $std_prop_file 2> /dev/null`
   elif [ $5 -eq 2 ];then
      files=`find code/"$1"/"$6"/src/main/resources/"$3"/ -name  $std_prop_file 2> /dev/null`
   elif [ $5 -eq 3 ];then
      files=`find code/"$1"/src/main/resources/conf/"$3"/ -name  $std_prop_file 2> /dev/null`
   fi
   #如果文件不存在，直接跳过，因为前一个脚本已经检查过了
   if [ -z "$files" ];then
      echo "WARNING "$(date -d now '+%F %T')" "$std_prop_file"文件不存在，跳过比对过程" 1>>log/check."$4".log
      continue
   fi
   filename_written_flag=0
    
   #预处理文件
    
   ./scripts/clearExSymbals.sh $files ./tmp/"$std_prop_file".cmp.tmp2
   stableorperf=./tmp/"$std_prop_file".cmp.tmp2

   std_prop_keys=$(python -c 'import parserutil;parserutil.ConfigUtil("'$std_conf'").get_keys_by_prop_file("'$std_prop_file'")')
   #echo "std_prop_keys*************"$std_prop_keys
   for std_prop_key in $std_prop_keys;do
      std_prop_key_=${std_prop_key//[\[\',\]]/}
      std_prop_value=$(python -c 'import parserutil;parserutil.ConfigUtil("'$std_conf'").get_value_by_key_and_section("'$std_prop_file'","'$std_prop_key_'")')
      #下面这种处理是处理多个=的情况
      check_value=`cat $stableorperf | grep "^$std_prop_key_=\(.*\)" | awk -F '=' '{for(i=2;i<=NF-1;i++) printf "%s=",$i;}'`
      check_value_tail=`cat $stableorperf | grep "^$std_prop_key_=\(.*\)" | awk -F '=' '{for(i=NF;i<=NF;i++) printf "%s",$i;}'`
      check_value=$check_value$check_value_tail
      

      #check_value=`cat $files | grep -v "^#" | grep -v "^$" | grep "^$std_prop_key_=\(.*\)" | sed -e 's/^"$std_prop_key_"=\(.*\)/\1/g'`
      #去除前后空格
      #std_prop_value=`echo $std_prop_value | sed "s/^\s*//g" | sed "s/\s*$//g"`
      #check_value=`echo $check_value | sed "s/^\s*//g" | sed "s/\s*$//g"`
      
      if [ ! "$std_prop_value"x == "$check_value"x ];then
          if [ ! $error_file_flag -eq 1 ];then
             ((file_count++))
             echo "" 1>>std_chk.error
             error_file_flag=1
          fi
          ((wrong_item_nums++))
          if [ ! $filename_written_flag -eq 1 ];then
              echo "配置文件"${std_prop_file##*/} 1>>std_chk.error
              #下面的./tmp/result_table_wrong_item.tmp文件是为了生成表格结果的
              randomnums1=`date +%s%N`
              echo "V_"$randomnums1"_V=s"${std_prop_file##*/}":" >> $7
              echo "标准配置项separatorcharsperformance配置项" 1>>std_chk.error
              filename_written_flag=1
          fi
          #wc -l：统计文件行数;wc -L：统计一行长度
          current_width=`echo $std_prop_key_"="$std_prop_value | wc -L`
          if [ $current_width -gt $max_width ];then
              max_width=$current_width
          fi
          echo -e $std_prop_key_"="$std_prop_value"separatorchars\c" 1>>std_chk.error
          randomnum2=`date +%s%N`
          echo "V_"$randomnum2"_V=s标准:"$std_prop_key_"="$std_prop_value  >> $7

          result=`cat $stableorperf | grep -v "#" | grep "^"$std_prop_key_"=.*"`
          if [ -z "$result" ];then
             randomnum3=`date +%s%N`
             echo "V_"$randomnum3"_V=s当前:缺少"$std_prop_key_ >> $7
             echo  "缺少"$std_prop_key_  1>>std_chk.error
          else
             randomnum4=`date +%s%N`
             echo "V_"$randomnum4"_V=s当前:"$result >> $7
             echo  $result 1>>std_chk.error
          fi
          #echo $std_prop_key_"="$std_prop_value"separatorchars" 1>>std_chk.error
      fi
   done
   rm -rf $stableorperf $std_conf
done
file_count_pos=1
#echo $max_width
while [[ $file_count_pos -le $file_count ]];do
   if [[ $file_count_pos -eq $file_count ]];then
       error_item_pre=`grep -n ".properties" std_chk.error | head -"$file_count_pos" | tail -1 | awk -F ':' '{print $1}'`
       lines_nums=`cat std_chk.error 2> /dev/null | wc -l`
      # echo $lines_nums" === "$error_item_pre
       sed -i "$error_item_pre"'s/$/&有'"$((lines_nums-error_item_pre-1))"'个配置项错误/g' std_chk.error
       break
   fi
   error_item_pre=`grep -n ".properties" std_chk.error | head -"$file_count_pos" | tail -1 | awk -F ':' '{print $1}'`
   error_item_next=`grep -n ".properties" std_chk.error | head -"$((++file_count_pos))" | tail -1 |  awk -F ':' '{print $1}'`
   sed -i "$error_item_pre"'s/$/&有'"$((error_item_next-error_item_pre-3))"'个配置项错误/g' std_chk.error
   ((file_count_pos++))
done
#加的调试的
#if [[ $max_width -gt 200 ]];then
#    max_width=70
#fi
#echo $max_width
mkdir -p result/"$4"/"$3"/"$1"
file_path=result/"$4"/"$3"/"$1"
#加的调试的
echo "有"$wrong_item_nums"个配置项错误" 1>>wubox.res
cat std_chk.error 2> /dev/null | while read eachline;do
  left_val=`echo $eachline | awk -F 'separatorchars' '{print $1}'`
  right_val=`echo $eachline | awk -F 'separatorchars' '{print $2}'`
  
  is_title=`echo $left_val | grep '标准配置项'`
  #如果太长了，就输出前面一部分吧
  #if [[ ${#left_val} -gt 50 ]];then
  #   left_val=`echo $left_val | cut -b1-50`
  #   left_val=$left_val"..."
  #   max_width=70
  #fi
  #if [[ ${#right_val} -gt 50 ]];then
  #   right_val=`echo $right_val | cut -b1-50`
  #   right_val=$right_val"..."
  #   max_width=70
  #fi
  #如果太长了，就输出前面一部分
#      printf '%-'"$((max_width+20))"'s %-s\n' $left_val $right_val >>columnformattmpfile.cftf
#      cat columnformattmpfile.cftf 
#      cat columnformattmpfile.cftf | column -t >>$file_path/check"$1".txt
#
#      rm -rf columnformattmpfile.cftf

  if [[ "$is_title" != "" ]];then
      printf '%-'"$((max_width+20))"'s %-s\n' $left_val $right_val 1>>$file_path/check"$1".txt
#      cat columnformattmpfile.cftf | column -t 1>>$file_path/check"$1".txt
#      rm -rf columnformattmpfile.cftf
  else
      printf '%-'"$((max_width+15))"'s %-s\n' $left_val $right_val 1>>$file_path/check"$1".txt
      #if [ -n "$left_val" ];then
      #  isINeed=`echo $left_val | grep "配置文件" | wc -l`
      #  if [ $isINeed -eq 0 ];then      
      #     randomnum2=`date +%s%N` 
      #     echo "V_"$randomnum2"_V=s标准:"$left_val >> $7
      #     echo "错误的配置项"$left_val"=============="$right_val
      #     randomnum3=`date +%s%N` 
      #     echo "V_"$randomnum3"_V=s当前:"$right_val >> $7
      #     randomnum4=`date +%s%N` 
      #     echo "V_"$randomnum4"_V=s" >> $7
      #  fi
      #fi        
#      cat columnformattmpfile.cftf | column -t 1>>$file_path/check"$1".txt
#      rm -rf columnformattmpfile.cftf      
  fi
done
sed -i '1s/$/&'"$(cat wubox.res | head -1 )"'/g' $file_path/check"$1".txt
#if [[ $1 == "credits" ]];then
#   cp std_chk.error credits.error
#fi
rm -rf wubox.res std_chk.error 
