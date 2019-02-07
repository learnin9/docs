#/bin/bash!

#export JAVA_HOME=/app/soft/java/java-1.8.0_181
#export JRE_HOME=$JAVA_HOME/jre
#export CLASSPATH=$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH
#export MAVEN_HOME=/app/soft/maven/maven-3.6.0
#export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$MAVEN_HOME/bin:$PATH

#set +x

PART_LIST=$*
PART_T()
{
 #参数获取
x=1
for n in `echo "$*"`
  do
        case "$n" in
          -n|n|-N|N)
              eval PROJECT_NAME=\${$(($x+1))}
              ;;
          -r|r|-R|R)
              eval PROJECT_ROOT=\${$(($x+1))}
              ;;
          -p|p|-P|P)
              eval PACKAGE_NAME=\${$(($x+1))}
              ;;
          -f|f|-F|F)
              eval FROM_DIR=\${$(($x+1))}
              ;;
             *)
              x=$(($x+1))
              continue
        esac
        x=$(($x+1))
  done
}


BUILD()
{
	echo "正在检查存放目录是否存在..."
	if [ ! -d $PROJECT_ROOT/appdir ]; then
            echo '目录不存在, 正在创建...'
            mkdir -p $PROJECT_ROOT/{appdir,backup}
            echo '目录创建完成! 即将开始打包...'
          else
            echo "目录正确,已经存在! 即将开始打包..."
	fi
	cd /app/soft/jenkins/workspace/$PROJECT_NAME
	mvn -U clean install -Dmaven.test.skip=true
	echo "正在备份旧版本的包并替换新包"
#	mv $PROJECT_ROOT/appdir/$PROJECT_NAME*  $PROJECT_ROOT/backup/$PROJECT_NAME-$(date +%Y-%m-%d--%H-%M).jar
	echo "mv $PROJECT_ROOT/appdir/$PACKAGE_NAME  $PROJECT_ROOT/backup/$PROJECT_NAME-$(date +%Y-%m-%d-%H:%M).jar"
	mv $PROJECT_ROOT/appdir/$PACKAGE_NAME  $PROJECT_ROOT/backup/$PROJECT_NAME-$(date +%Y-%m-%d-%H:%M).jar
	echo "cp  -f $FROM_DIR  $PROJECT_ROOT/appdir/ "
	cp  -f $FROM_DIR  $PROJECT_ROOT/appdir/
        echo '-------------'
        echo "  打包完成   "
        echo '-------------'
}


if [ "$*x" != "x" ]
  then
    echo "传参举例，参数为 '-n project_name -r project_root -p package_name -f from_dir' "
    PART_T ${PART_LIST}
  else

    PROJECT_NAME=""
    PROJECT_ROOT=""
    PACKAGE_NAME=""

    if [ "${PROJECT_NAME}x" == "x" ] && [ "${PROJECT_ROOT}x" == "x" ] && [ "${PACKAGE_NAME}x" == "x" ]
      then
        echo "传参举例，参数为 '-n project_name -r project_root -p package_name -f from_dir' "
        exit
    fi
fi

echo " PROJECT_NAME=$PROJECT_NAME ,  PROJECT_ROOT=$PROJECT_ROOT , PACKAGE_NAME=$PACKAGE_NAME FROM_DIR=$FROM_DIR "

BUILD
