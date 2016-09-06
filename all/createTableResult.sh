#!/bin/bash
# by hzwuboxiao

rm -rf ./mail/messageContent/"$2".html
#总述文件
comment=./mail/messageContent/messageContent."$2".txt
#环境个数，目的是为了统计各个环境下面的工程的个数，以便确定表格的行数
envnums=`grep "环境" $comment | wc -l`
echo "envnums="$envnums
#先创建一个结果文件吧
touch ./mail/messageContent/"$2".html
resulthtml=./mail/messageContent/"$2".html
#先把表头写进去
echo "<html><head><meta charset='utf-8'></head><body><a name='page_top'><div width='100%' height='1px'></div></a><table border='1' cellspacing='0' width='1000'><tr align='center'><td>环境名</td><td>工程名</td><td>缺少的配置文件个数</td><td>缺失的配置项个数</td><td>错误的配置项个数</td></tr>" >> $resulthtml
#开始创建表格了，应该要用一个循环
env_count_pos=1
while [[ $env_count_pos -le $envnums ]];do
    echo "当前大小:"$env_count_pos"=-=-=-=-=-=-=当前环境个数"$envnums
    #如果要处理的是最后一个环境
    if [[ $env_count_pos -eq $envnums ]];then
	#先找到当前环境下有多少个工程，以便确定表格占用的行数
        #env_item_pre:最后一个"环境"所在的行数
        env_item_pre=`grep -n "环境" $comment | head -"$env_count_pos" | tail -1 | awk -F ':' '{print $1}'`
        #env_name:环境名称
        env_name=`cat $comment | sed -n "$env_item_pre"p | awk -F '环境' '{print $1}'`
        #env_item_last:总述文件的行数
        env_item_last=`cat $comment | wc -l`
        echo "<tr align='center'><td rowspan='"$((env_item_last-env_item_pre-1))"'><a name='"$env_name"'>$env_name</a></td>" >> $resulthtml
        #先处理当前环境下的第一个工程
        proj_name=`cat $comment | sed -n "$((env_item_pre+1))"p | awk -F '工程' '{print $1}'` 
        nums=`cat $comment | sed -n "$((env_item_pre+1))"p | grep -o '[0-9]\+'`
        lost_files=`echo $nums | awk -F ' ' '{print $1}'`
        lost_items=`echo $nums | awk -F ' ' '{print $2}'`
        wrong_items=`echo $nums | awk -F ' ' '{print $3}'`
        echo "<td><a target='_self' href='#"$proj_name"'>"$proj_name"</a></td><td>"$lost_files"</td><td>"$lost_items"</td><td>"$wrong_items"</td></tr>" >> $resulthtml

        awk 'NR>'"$((env_item_pre+1))"' && NR<'"$env_item_last" $comment | while read eachitem
            do
                #处理每一行，也就是每一个工程的总述，即类似于下面这行：
                #credits工程：缺少1个配置文件，1个配置项，对比标准配置文件，有0个错误配置项
                #先获取工程名
                proj_name=`echo $eachitem | awk -F '工程' '{print $1}'`
                #再获取上面的1 1 和 0三个数字                
                nums=`echo $eachitem | grep -o '[0-9]\+'`
                lost_files=`echo $nums | awk -F ' ' '{print $1}'`
                lost_items=`echo $nums | awk -F ' ' '{print $2}'`
                wrong_items=`echo $nums | awk -F ' ' '{print $3}'`
                echo "<tr align='center'><td><a target='_self' href='#"$proj_name"'>"$proj_name"</a></td><td>"$lost_files"</td><td>"$lost_items"</td><td>"$wrong_items"</td></tr>" >> $resulthtml
            done
        ((env_count_pos++))
        #这个break一定要加
        break
    fi
    echo "当前指标大小:"$env_count_pos
    #要处理的不是最后一个环境
    env_item_pre=`grep -n "环境" $comment | head -"$env_count_pos" | tail -1 | awk -F ':' '{print $1}'`
    #env_name:环境名称
    env_name=`cat $comment | sed -n "$env_item_pre"p | awk -F '环境' '{print $1}'`
    #env_item_next:下一个“环境”所在的行数
    env_item_next=`grep -n "环境" $comment | head -"$((++env_count_pos))" | tail -1 | awk -F ':' '{print $1}'`
    echo "<tr align='center'><td rowspan='"$((env_item_next-env_item_pre-2))"'><a name='"$env_name"'>"$env_name"</a></td>" >> $resulthtml
    #先处理当前环境下的第一个工程
    proj_name=`cat $comment | sed -n "$((env_item_pre+1))"p | awk -F '工程' '{print $1}'`
    nums=`cat $comment | sed -n "$((env_item_pre+1))"p | grep -o '[0-9]\+'`
    lost_files=`echo $nums | awk -F ' ' '{print $1}'`
    lost_items=`echo $nums | awk -F ' ' '{print $2}'`
    wrong_items=`echo $nums | awk -F ' ' '{print $3}'`
    echo "<td><a target='_self' href='#"$proj_name"'>"$proj_name"</a></td><td>"$lost_files"</td><td>"$lost_items"</td><td>"$wrong_items"</td></tr>" >> $resulthtml
    awk 'NR>'"$((env_item_pre+1))"' && NR<'"$((env_item_next-1))" $comment | while read eachitem
        do
            #处理每一行，也就是每一个工程的总述，即类似于下面这行：
            #credits工程：缺少1个配置文件，1个配置项，对比标准配置文件，有0个错误配置项
            #先获取工程名
            proj_name=`echo $eachitem | awk -F '工程' '{print $1}'`
            #再获取上面的1 1 和 0三个数字
            nums=`echo $eachitem | grep -o '[0-9]\+'`
            lost_files=`echo $nums | awk -F ' ' '{print $1}'`
            lost_items=`echo $nums | awk -F ' ' '{print $2}'`
            wrong_items=`echo $nums | awk -F ' ' '{print $3}'`
            echo "<tr align='center'><td><a target='_self' href='#"$proj_name"'>"$proj_name"</a></td><td>"$lost_files"</td><td>"$lost_items"</td><td>"$wrong_items"</td></tr>" >> $resulthtml
        done
     echo "<tr height='20px'><td colspan='5'>&nbsp;&nbsp;</td></tr>" >> $resulthtml
    ((env_count_pos++))
done
echo "</table><br><br><br>" >> $resulthtml
#至此，已经完成了第一个表格的创建

#分割线--------------------------------------------------------------------------------------------------------------------------------------------

#先统计一下环境的个数，虽然和envnums值可能一样，但统计方式不一样，用处也不一样
env_cnt=`ls -l result/"$2"/ | grep "^d" | wc -l`
#下面开始创建其他表格
#循环工程名
for proj_name in $(ls -l code/ |grep "^d" |awk '{print $9}');do
    env_cnt_pos=1
    #先写入表头
    echo "<table border='1' cellspacing='0' width='1000px'  style='word-break:break-all; word-wrap:break-all;'><tr align='center'><td width='15%'>环境名\工程名</td><td colspan='2'><a name='"$proj_name"'>"$proj_name"</a></td></tr>" >> $resulthtml
    #循环环境名
    for env_name in $(ls -l result/"$2"/ | grep "^d" | awk '{print $9}');do
        #如果处理的是最后一个环境,表格最后不用加一个空行
        if [ $env_cnt_pos -eq $env_cnt ];then
            echo "<tr align='center'><td rowspan='3'><a target='_self' href='#page_top'>"$env_name"</a></td><td width='15%'>缺失的配置文件</td>" >> $resulthtml
            #要处理的结果文件
            target_file=./result/"$2"/"$env_name"/"$proj_name"/check"$proj_name".txt
            #下面取出缺失的配置文件
            #如果结果文件不存在，则表明缺少、缺失和错误三者均为0,为0的时候，最好在表格中添加几个空格&nbsp;不然表格的边框线显示不出来
            if [ ! -f $target_file ];then
                echo "<td align='left'>无</td></tr><tr><td align='center'>缺失的配置项</td><td align='left'>无</td></tr><tr><td align='center'>错误的配置项</td><td align='left'>无</td></tr>" >> $resulthtml
                #这已经是最后一个环境了，所以在跳出循环之前要将表尾写入html文件中
                echo "</table><br><br><br>" >> $resulthtml
                continue
            fi
            #如果结果文件存在，也有可能缺失的配置文件为0个的情况
            lost_prop_files_count=`cat $target_file | grep "缺失的配置文件" | wc -l`
            if [ $lost_prop_files_count -eq 0 ];then
                echo "<td align='left'>无</td></tr>" >> $resulthtml
            else
                lost_prop_files=`cat $target_file | grep "缺失的配置文件" | awk -F ':' '{print $2}'`
                echo "<td align='left'>"$lost_prop_files"</td></tr>" >> $resulthtml
            fi
            echo "<tr><td align='center'>缺失的配置项</td>" >> $resulthtml   
            #下面取出缺失的配置项
            #看看是否存在缺失的配置项
            lost_item_cnt=`cat $target_file | grep "配置项缺失" | wc -l` 
            #如果不存在缺失的配置项
            if [ $lost_item_cnt -eq 0 ];then
                echo "<td align='left'>无</td></tr>" >> $resulthtml
            #如果存在缺失的配置项
            else
                #找到起始行和'++++++++++++'所在行，将中间这些行全部取出来
                lost_item_start_line=`grep -n '配置项缺失' $target_file | head -1 | awk -F ':' '{print $1}'`
                #下面的+号和文本中对应的，少一个都不行
                plus_symbal_cnt=`grep -n '++++++++++++++++++++++++++++++++++++++++++++++++++' $target_file | tail -1 | awk -F ':' '{print $1}'`
                #下面将缺失的配置项一行一行写入到table的<td>中 
                echo "<td align='left'>" >> $resulthtml
                awk 'NR>='"$lost_item_start_line"' && NR<'"$plus_symbal_cnt" $target_file | while read each_line
                    do  
                        echo $each_line"<br>" >> $resulthtml
                    done
                echo "</td></tr>" >> $resulthtml
            fi
            #下面取出错误的配置项
            echo "<tr><td align='center'>错误的配置项</td>" >> $resulthtml
            wrong_item_cnt=`cat $target_file | grep "配置项错误" | wc -l`
            #如果不存在错误的配置项，1是因为文本中至少有一个“错误的配置项”字样
            if [ $wrong_item_cnt -eq 1 ];then
                echo "<td align='left'>无</td></tr>" >> $resulthtml
            else
                #调用了python脚本取出错误的配置项
                #单引号，双引号需要小心，容易出错`'"
                wrong_item_content=`python -c 'import parserutil;parserutil.ConfigUtil("./result/table_result_wrong_item.tmp").get_wrong_item_by_proj_and_env("'$env_name'","'$proj_name'")'`
                #这里默认就是靠左显示，所以没加align='left'
                echo "<td>"$wrong_item_content"</td></tr>" >> $resulthtml
            fi
            echo "</table><br><br><br>" >> $resulthtml
            ((env_cnt_pos++))
            break
        fi
        echo "<tr align='center'><td rowspan='3'><a target='_self' href='#page_top'>"$env_name"</a></td><td width='15%'>缺失的配置文件</td>" >> $resulthtml
        #要处理的结果文件
        target_file=./result/"$2"/"$env_name"/"$proj_name"/check"$proj_name".txt
        #下面取出缺失的配置文件
        #如果结果文件不存在，则表明缺少、缺失和错误三者均为0
        if [ ! -f $target_file ];then
            echo "<td align='left'>无</td></tr><tr><td align='center'>缺失的配置项</td><td align='left'>无</td></tr><tr><td align='center'>错误的配置项</td><td align='left'>无</td></tr>" >> $resulthtml
            #需要跳出当前环境的循环，处理下一个环境的数据,跳出之前先递增一下env_cnt_pos
            ((env_cnt_pos++))
            continue
        fi
        #如果结果文件存在，也有可能缺失的配置文件为0个的情况
        lost_prop_files_count=`cat $target_file | grep "缺失的配置文件" | wc -l`
        if [ $lost_prop_files_count -eq 0 ];then
            echo "<td align='left'>无</td></tr>" >> $resulthtml
        else
            lost_prop_files=`cat $target_file | grep "缺失的配置文件" | awk -F ':' '{print $2}'`
            echo "<td align='left'>"$lost_prop_files"</td></tr>" >> $resulthtml
        fi
        echo "<tr><td align='center'>缺失的配置项</td>" >> $resulthtml
        #下面取出缺失的配置项
        #看看是否存在缺失的配置项
        lost_item_cnt=`cat $target_file | grep "配置项缺失" | wc -l`
        #如果不存在缺失的配置项
        if [ $lost_item_cnt -eq 0 ];then
            echo "<td align='left'>无</td></tr>" >> $resulthtml
        #如果存在缺失的配置项
        else
            #找到起始行和'++++++++++++'所在行，将中间这些行全部取出来
            lost_item_start_line=`grep -n '配置项缺失' $target_file | head -1 | awk -F ':' '{print $1}'`
            plus_symbal_cnt=`grep -n '++++++++++++++++++++++++++++++++++++++++++++++++++' $target_file | tail -1 | awk -F ':' '{print $1}'`
            #下面将缺失的配置项一行一行写入到table的<td>中
            echo "<td align='left'>" >> $resulthtml
            awk 'NR>='"$lost_item_start_line"' && NR<'"$plus_symbal_cnt" $target_file | while read each_line
                do
                    echo $each_line"<br>" >> $resulthtml
                done
            echo "</td></tr>" >> $resulthtml
        fi
        #下面取出错误的配置项
        echo "<tr><td align='center'>错误的配置项</td>" >> $resulthtml
        wrong_item_cnt=`cat $target_file | grep "配置项错误" | wc -l`
        #如果不存在错误的配置项
        if [ $wrong_item_cnt -eq 1 ];then
            echo "<td align='left'>无</td></tr>" >> $resulthtml
        else
            wrong_item_content=`python -c 'import parserutil;parserutil.ConfigUtil("./result/table_result_wrong_item.tmp").get_wrong_item_by_proj_and_env("'$env_name'","'$proj_name'")'`
            echo "<td>"$wrong_item_content"</td></tr>" >> $resulthtml
        fi
        echo "<tr height='20px'><td colspan='3'>&nbsp;&nbsp;</td></tr>" >> $resulthtml
        ((env_cnt_pos++))
    done
done

#将临时文件删除
#rm -rf ./result/table_result_wrong_item.tmp
echo "</body></html>" >> $resulthtml
