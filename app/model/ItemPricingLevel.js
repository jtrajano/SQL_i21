/**
 * Created by LZabala on 10/24/2014.
 */
Ext.define('Inventory.model.ItemPricingLevel', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemPricingLevelId',

    fields: [
        { name: 'intItemPricingLevelId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemPricingLevels',
                    storeConfig: {
                        remoteFilter: true,
                        proxy: {
                            type: 'rest',
                            api: {
                                read: '../Inventory/api/ItemPricing/GetItemPricingLevels'
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
        { name: 'strPriceLevel', type: 'string'},
        { name: 'intUnitMeasureId', type: 'int', allowNull: true },
        { name: 'dblUnit', type: 'float'},
        { name: 'dblMin', type: 'float'},
        { name: 'dblMax', type: 'float'},
        { name: 'strPricingMethod', type: 'string'},
        { name: 'strCommissionOn', type: 'string'},
        { name: 'dblCommissionRate', type: 'float'},
        { name: 'dblUnitPrice', type: 'float'},
        { name: 'dtmBeginDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'dtmEndDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'intSort', type: 'int'},

        { name: 'strLocationName', type: 'string'},
        { name: 'strUnitMeasure', type: 'string'},
        { name: 'strUPC', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strLocationName'},
        {type: 'presence', field: 'strPriceLevel'},
        {type: 'presence', field: 'strUnitMeasure'},
        {type: 'presence', field: 'dblUnit'},
        {type: 'presence', field: 'strPricingMethod'},
        {type: 'presence', field: 'dblUnitPrice'},
        {type: 'presence', field: 'dtmBeginDate'}
    ]
});