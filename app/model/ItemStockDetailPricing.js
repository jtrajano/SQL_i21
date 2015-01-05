/**
 * Created by LZabala on 1/5/2015.
 */
Ext.define('Inventory.model.ItemStockDetailPricing', {
    extend: 'Ext.data.Model',

    requires: [
        'Ext.data.Field'
    ],

    fields: [
        { name: 'intItemPricingId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.ItemStockDetailView',
                inverse: {
                    role: 'tblICItemPricings',
                    storeConfig: {
                        complete: true,
                        remoteFilter: true,
                        sortOnLoad: true,
                        sorters: {
                            direction: 'DESC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'intLocationId', type: 'int', allowNull: true },
        { name: 'dblRetailPrice', type: 'float'},
        { name: 'dblWholesalePrice', type: 'float'},
        { name: 'dblLargeVolumePrice', type: 'float'},
        { name: 'dblSalePrice', type: 'float'},
        { name: 'dblMSRPPrice', type: 'float'},
        { name: 'strPricingMethod', type: 'string'},
        { name: 'dblAmountPercent', type: 'float'},
        { name: 'dblLastCost', type: 'float'},
        { name: 'dblStandardCost', type: 'float'},
        { name: 'dblMovingAverageCost', type: 'float'},
        { name: 'dblEndMonthCost', type: 'float'},
        { name: 'ysnActive', type: 'boolean'},
        { name: 'intSort', type: 'int'},

        { name: 'strLocationName', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'intLocationId'}
    ]
});