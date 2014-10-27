/**
 * Created by LZabala on 10/24/2014.
 */
Ext.define('Inventory.model.ItemPricing', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemPricingId',

    fields: [
        { name: 'intItemPricingId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemPricings',
                    storeConfig: {
                        proxy: {
                            type: 'rest',
                            api: {
                                read: '../Inventory/api/ItemPricing/GetItemPricings'
                            },
                            reader: {
                                type: 'json',
                                rootProperty: 'data',
                                messageProperty: 'message'
                            }
                        },
                        sortOnLoad: true,
                        sorters: {
                            direction: 'ASC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'intLocationId', type: 'int'},
        { name: 'dblRetailPrice', type: 'float'},
        { name: 'dblWholesalePrice', type: 'float'},
        { name: 'dblLargeVolumePrice', type: 'float'},
        { name: 'dblSalePrice', type: 'float'},
        { name: 'dblMSRPPrice', type: 'float'},
        { name: 'strPricingMethod', type: 'string'},
        { name: 'dblLastCost', type: 'float'},
        { name: 'dblStandardCost', type: 'float'},
        { name: 'dblMovingAverageCost', type: 'float'},
        { name: 'dblEndMonthCost', type: 'float'},
        { name: 'ysnActive', type: 'boolean'},
        { name: 'intSort', type: 'int'},

        { name: 'strLocationName', type: 'string'}
    ]
});