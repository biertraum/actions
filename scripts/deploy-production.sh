#!/bin/bash

set -e

PROJECT_PATH="$(pwd)"

echo "project path is $PROJECT_PATH";

which ssh-agent || ( apt-get update -y && apt-get install openssh-client -y )
eval $(ssh-agent -s)
mkdir ~/.ssh/ && echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa && chmod 600 ~/.ssh/id_rsa
ssh-add ~/.ssh/id_rsa
echo "$SSH_CONFIG" > /etc/ssh/ssh_config && chmod 600 /etc/ssh/ssh_config

echo "Create artifact and send to server"

cd $PROJECT_PATH


echo "Deploying to production server";

mkdir -p deployer/scripts/
cp -R /opt/config/pipelines/scripts/production deployer/scripts/production

echo 'creating bucket dir'
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  production "mkdir -p $HOST_DEPLOY_PATH_BUCKET"

ARCHIVES="deployer/scripts/production"

[ -d "magento" ] && ARCHIVES="$ARCHIVES magento"

tar cfz "$BUCKET_COMMIT" $ARCHIVES
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  "$BUCKET_COMMIT" production:$HOST_DEPLOY_PATH_BUCKET


cd /opt/config/php-deployer

echo 'Deploying production ...';

echo '------> Deploying bucket ...';
# deploy bucket
php7.4 ./vendor/bin/dep deploy-bucket production \
-o bucket-commit=$BUCKET_COMMIT \
-o host_bucket_path=$HOST_DEPLOY_PATH_BUCKET \
-o deploy_path_custom=$HOST_DEPLOY_PATH \
-o deploy_keep_releases=$INPUT_KEEP_RELEASES \
-o write_use_sudo=$WRITE_USE_SUDO

# Run pre-release script in order to setup the server before magento deploy
if [ -d "$PROJECT_PATH/magento" ]
then
  # link media to be able to run weltpixel less generation
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  staging "mv $HOST_DEPLOY_PATH/release/magento/pub/media $HOST_DEPLOY_PATH/release/magento/pub/media.orig"
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  staging "ln -sf $HOST_DEPLOY_PATH/shared/magento/pub/media $HOST_DEPLOY_PATH/release/magento/pub/media"
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  production "cd $HOST_DEPLOY_PATH/release/magento/ && /bin/bash $HOST_DEPLOY_PATH/deployer/scripts/production/release_setup.sh"
fi

echo '------> Deploying release ...';

DEFAULT_DEPLOYER="deploy"
if [ $INPUT_DEPLOYER = "no-permission-check" ]
then
  DEFAULT_DEPLOYER="deploy:no-permission-check"
fi

# deploy release
php7.4 ./vendor/bin/dep $DEFAULT_DEPLOYER production \
-o bucket-commit=$BUCKET_COMMIT \
-o host_bucket_path=$HOST_DEPLOY_PATH_BUCKET \
-o deploy_path_custom=$HOST_DEPLOY_PATH \
-o deploy_keep_releases=$INPUT_KEEP_RELEASES \
-o write_use_sudo=$WRITE_USE_SUDO

echo "running magento deployer"
if [ -d "$PROJECT_PATH/magento" ]
then
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  production "cd $HOST_DEPLOY_PATH/current/magento/ && /bin/bash $HOST_DEPLOY_PATH/deployer/scripts/production/post_release_setup.sh"
fi

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  production "cd $HOST_DEPLOY_PATH_BUCKET && /bin/bash $HOST_DEPLOY_PATH/deployer/scripts/production/post_release_cleanup.sh $INPUT_KEEP_RELEASES"

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  production "cluster-control login --pa_token='${MAXCLUSTER_TOKEN}' && cluster-control php:reload ${MAXCLUSTER_SERVER} && cluster-control logout"