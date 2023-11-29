#!/usr/bin/env bash

echo "building ....."

chown -R root:root .
PROJECT_PATH="$(pwd)"

echo "currently in $PROJECT_PATH"

if [ -d "$PROJECT_PATH/magento" ]
then
   cd "$PROJECT_PATH/magento"

   php7.2  /usr/local/bin/composer install --dry-run --no-dev --no-progress &> /dev/null

   COMPOSER_COMPATIBILITY=$?

   echo "Composer compatibility: $COMPOSER_COMPATIBILITY"

   set -e

    php7.2 /usr/local/bin/composer install --no-dev --no-progress

    chmod +x bin/magento

    #mysqladmin -h mysql -u root -pmagento status
    ## fix magento error: connection default is not defined
    echo "<?php  return ['db' => [ 'table_prefix' => '', 'connection' => [ 'default' => [ 'host' => 'mysql', 'dbname' => 'magento', 'username' => 'root', 'password' => 'magento', 'model' => 'mysql4', 'engine' => 'innodb', 'initStatements' => 'SET NAMES utf8;', 'active' => '1' ] ]]];" > app/etc/env.php
    ## end fix ##

    if [ -n "$INPUT_DISABLE_MODULES"  ]
    then
      echo "These modules will be discarded during install process $INPUT_DISABLE_MODULES"
      [ -f app/etc/config.php ] && cp app/etc/config.php app/etc/config.php.orig
    fi

    bash /opt/config/utils/pagebuilder-compatibility-checker.sh
    bash /opt/config/utils/common-magento-installer.sh

    ## Build static contents TODO Static Contact
#    bash /opt/config/utils/custom-theme-builder.sh

#    if [ -z "$INPUT_LANGS"  ] && [ -z "$INPUT_THEMES"  ]
#    then
      ## the switch to production will build static content for all languages declared in config.php
#      bin/magento deploy:mode:set production
#    else
#      bin/magento setup:di:compile
#      bin/magento deploy:mode:set --skip-compilation production
      # deploy static build for different locales
#      export IFS=","
#      magento_themes=${INPUT_THEMES:+${INPUT_THEMES//,/' '}""}
#      magento_themes=${INPUT_THEMES:+"-t "${magento_themes// /' -t '}" -t Magento/backend"}
#      languages="$INPUT_LANGS"
#      if [ -n "$languages"  ]
#      then
#        for locale in $languages; do
#          echo "bin/magento setup:static-content:deploy $magento_themes $locale"
#          bin/magento setup:static-content:deploy $magento_themes $locale
#        done
#      else
#          echo "bin/magento setup:static-content:deploy $magento_themes"
#          bin/magento setup:static-content:deploy $magento_themes
#      fi
#      composer dump-autoload -o
#    fi

    if [ -n "$INPUT_DISABLE_MODULES"  ]
    then
      [ -f app/etc/config.php.orig ] && cat app/etc/config.php.orig > app/etc/config.php
    fi

    rm app/etc/env.php
fi

cd $PROJECT_PATH
