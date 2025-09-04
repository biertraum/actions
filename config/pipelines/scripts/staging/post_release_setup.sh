#!/usr/bin/env bash

# check and edit this path (public path of magento)

if [ ! -f app/etc/env.php ]
then
  echo "This is the first deploy? You must set magento env.php"
  exit 3
fi

echo "Import magento config"
/usr/bin/php bin/magento app:config:import --no-interaction

echo "Check setup:upgrade status"
# use --no-ansi to avoid color characters
message=$(/usr/bin/php bin/magento setup:db:status --no-ansi)

if [[ ${message:0:3} == "All" ]]; then
  echo "No setup upgrade - clear cache";
  /usr/bin/php bin/magento cache:clean
else
  echo "Run setup:upgrade - maintenance mode"
  /usr/bin/php bin/magento maintenance:enable
  /usr/bin/php bin/magento setup:upgrade --keep-generated --no-interaction
  /usr/bin/php bin/magento maintenance:disable
  /usr/bin/php bin/magento cache:flush
fi
