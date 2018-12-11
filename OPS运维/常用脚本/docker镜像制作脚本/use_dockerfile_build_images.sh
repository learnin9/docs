source ~/.bash_profile
base_dir=$(pwd)
version=$(cat $base_dir/nginx/version)
set +x

cd $base_dir/nginx/
ls -al
sudo docker images
sudo docker build -t tchroot/nginx:$version  $base_dir/nginx/
sudo docker images
sudo docker push tchroot/nginx:$version

