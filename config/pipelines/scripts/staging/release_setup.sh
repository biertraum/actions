#!/usr/bin/env bash

set -e

if [ ! -f app/etc/env.php ]
then
  cp app/etc/env.TEST.php app/etc/env.php
fi

# operation to make before the switch of the release folder
# Generate code
php bin/magento setup:di:compile

# Build static files
php bin/magento setup:static-content:deploy de_DE -f -j 3
php bin/magento setup:static-content:deploy en_US --area adminhtml -f -j 3

# generate CSS for the Theme weltpixel
#php bin/magento weltpixel:less:generate
#php bin/magento weltpixel:css:generate --store default
#php bin/magento weltpixel:css:generate --store bw_de
#php bin/magento weltpixel:css:generate --store bb_de
#php bin/magento weltpixel:css:generate --store hp_de
#php bin/magento weltpixel:css:generate --store riegele_de
#php bin/magento weltpixel:css:generate --store schoenramer_de
#php bin/magento weltpixel:css:generate --store wittmann_de
#php bin/magento weltpixel:css:generate --store floetzinger_de
#php bin/magento weltpixel:css:generate --store biertraum_de
#php bin/magento weltpixel:css:generate --store alpenbrauerei_de
#php bin/magento weltpixel:css:generate --store alpenbrauerei_alpenstoff_de
#php bin/magento weltpixel:css:generate --store alpenbrauerei_buergerbraeu_de
#php bin/magento weltpixel:css:generate --store bf_de
#php bin/magento weltpixel:css:generate --store hirsch_de
#php bin/magento weltpixel:css:generate --store meckatzer_de