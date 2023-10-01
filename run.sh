#!/bin/bash
fileWorkspaceFolder="/home/maso/Project/Odoo-16/docker"
docker run --rm \
    --network psql_default \
    --volume ${fileWorkspaceFolder}/../odoo:/var/lib/odoo \
    --volume ${fileWorkspaceFolder}/../:/extra-add \
    -p 8069:8069 \
    c5f88b09ad44 \
    --db_host db \
    --db_password odoo \
    --db_user odoo \
    --database odoo16-main \
    --addons-path "/extra-add/odoo/addons,/extra-add/CybroAddons,/extra-add/odoo-exchange,/extra-add/odoo-viraweb123,/extra-add/odoo-mobile-service,/extra-add/sale-workflow,/extra-add/iot,/extra-add/odoo-beton,/extra-add/trip2persia,/extra-add/account-reconcile,/extra-add/bank-statement-import,/extra-add/odoo-hr" \
    --load vw_odooo_patch \
    --update  vw_hr_attendence \
    --dev all 

