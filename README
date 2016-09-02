项目说明
公司有线上环境(online)和两套测试环境：performance和stable.
测试时，由于经常需要修改配置文件，导致performance和stable常常与online环境配置不一致，所以需要写一个脚本，检测下配置文件的异同，需要实现以下几个目标：
1、对比online,分别检测performance和stable环境下，缺少哪些配置文件
2、对比online，分别检测performance和stable环境下，缺少哪些配置项
3、对比标准配置文件，分别检测performance和stable环境下，有哪些配置项错误

比如：
online配置如下
jdbc.properties
jdbc_health.driverClassName=oracle.jdbc.driver.OracleDriver
jdbc_health.url=jdbc:oracle:thin:@10.165.176.228:6521:global
jdbc_health.username=global
jdbc_health.password=jReSebM
jdbc_health.maximumConnectionCount=200
jdbc_health.maximumActiveTime=3600000
jdbc_health.maximumConnectionLifetime=3600000

dubbo.properties
dubbo.registry.address=zookeeper://10.165.149.27:2181
dubbo.application.name=haitao-cacheIndex
dubbo.environment=online
dubbo.provider.group=online
dubbo.consumer.group=online

performance配置如下：
dubbo.properties
dubbo.registry.address=zookeeper://10.165.149.27:2181
dubbo.application.name=haitao-cacheIndex
dubbo.provider.group=performance
dubbo.consumer.group=test


标准配置：

[dubbo.properties]
dubbo.registry.address=zookeeper://10.165.149.27:2181
dubbo.application.name=haitao-cacheIndex
dubbo.environment=performance
dubbo.provider.group=performance
dubbo.consumer.group=performance

则，performance具有如下问题：
1、缺少jdbc.properties配置文件
2、缺少dubbo.environment配置项
3、对比标准配置，dubbo.consumer.group=test配置项错误
