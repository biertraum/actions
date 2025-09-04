#!/usr/bin/env bash

set -e

if [ ! -f app/etc/env.php ]
then
  cp app/etc/env.TEST.php app/etc/env.php
fi

# operation to make before the switch of the release folder
# Generate code
/usr/bin/php bin/magento setup:di:compile

# Build static files
/usr/bin/php bin/magento setup:static-content:deploy de_DE -f -j 3
/usr/bin/php bin/magento setup:static-content:deploy en_US --area adminhtml -f -j 3

# generate CSS for the Theme weltpixel
/usr/bin/php bin/magento weltpixel:less:generate
/usr/bin/php bin/magento weltpixel:css:generate --store default
/usr/bin/php bin/magento weltpixel:css:generate --store bw_de
/usr/bin/php bin/magento weltpixel:css:generate --store bb_de
/usr/bin/php bin/magento weltpixel:css:generate --store hp_de
/usr/bin/php bin/magento weltpixel:css:generate --store riegele_de
/usr/bin/php bin/magento weltpixel:css:generate --store schoenramer_de
/usr/bin/php bin/magento weltpixel:css:generate --store wittmann_de
/usr/bin/php bin/magento weltpixel:css:generate --store floetzinger_de
/usr/bin/php bin/magento weltpixel:css:generate --store biertraum_de
/usr/bin/php bin/magento weltpixel:css:generate --store alpenbrauerei_de
/usr/bin/php bin/magento weltpixel:css:generate --store alpenbrauerei_alpenstoff_de
/usr/bin/php bin/magento weltpixel:css:generate --store alpenbrauerei_buergerbraeu_de
/usr/bin/php bin/magento weltpixel:css:generate --store bf_de
/usr/bin/php bin/magento weltpixel:css:generate --store hirsch_de
/usr/bin/php bin/magento weltpixel:css:generate --store meckatzer_de