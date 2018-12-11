source ~/.bash_profile
base_dir=$(pwd)
version=$(cat $base_dir/velocity-engine-core/version)
set +x

cd $base_dir/velocity-engine-core/
ls -al
echo "----------   正在拷贝文件... ------------"
cp /app/project/velocity-engine-core/velocity-engine-core-$version.jar $base_dir/velocity-engine-core/
sudo docker images
echo "-----------  开始build镜像...  -----------"
sudo docker build -t tchroot/velocity-engine-core:$version  $base_dir/velocity-engine-core/
echo "-----   build镜像完成,以下为新镜像... ----"
sudo docker images
echo "-----   正在上传镜像到docker hub...   ----"
sudo docker push tchroot/velocity-engine-core:$version
echo "-----  镜像push完成, 整个流程已经完成 ----"
