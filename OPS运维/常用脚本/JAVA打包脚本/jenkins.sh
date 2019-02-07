#jenkins步骤配置脚本

source ~/.bash_profile

### 环境信息 ##
PROJECT_NAME=java_monitor   #JOB名称
PACKAGE_NAME='java_monitor-*.jar'   #包名
PROJECT_ROOT=/mapbar/app/project/$PROJECT_NAME
FROM_DIR=/mapbar/app/soft/jenkins/workspace/$PROJECT_NAME/target/$PACKAGE_NAME   #这个地方可能会有所调整

set +x
## 使用脚本进行打包
sh  /app/jenkins/scripts/build_jar.sh -n ${PROJECT_NAME} -r ${PROJECT_ROOT} -p ${PACKAGE_NAME} -f ${FROM_DIR}


