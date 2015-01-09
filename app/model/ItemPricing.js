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
                        remoteFilter: true,
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
                            direction: 'DESC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'intLocationId', type: 'int', allowNull: true },
        { name: 'intItemUnitMeasureId', type: 'int', allowNull: true },
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
        { name: 'dtmBeginDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'dtmEndDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'intSort', type: 'int'},

        { name: 'strLocationName', type: 'string'},
        { name: 'strUnitMeasure', type: 'string'},
        { name: 'strUPC', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'intLocationId'},
        {type: 'presence', field: 'intItemUnitMeasureId'},
        {type: 'presence', field: 'dblStandardCost'},
        {type: 'presence', field: 'strPricingMethod'},
        {type: 'presence', field: 'dblRetailPrice'},
        {type: 'presence', field: 'dtmBeginDate'}
    ]
});