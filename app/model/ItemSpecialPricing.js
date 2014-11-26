/**
 * Created by LZabala on 10/24/2014.
 */
Ext.define('Inventory.model.ItemSpecialPricing', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemSpecialPricingId',

    fields: [
        { name: 'intItemSpecialPricingId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemSpecialPricings',
                    storeConfig: {
                        complete: true,
                        sortOnLoad: true,
                        sorters: {
                            direction: 'ASC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'intLocationId', type: 'int', allowNull: true },
        { name: 'strPromotionType', type: 'string'},
        { name: 'dtmBeginDate', type: 'date'},
        { name: 'dtmEndDate', type: 'date'},
        { name: 'intUnitMeasureId', type: 'int', allowNull: true },
        { name: 'dblUnit', type: 'float'},
        { name: 'strDiscountBy', type: 'string'},
        { name: 'dblDiscount', type: 'float'},
        { name: 'dblUnitAfterDiscount', type: 'float'},
        { name: 'dblAccumulatedQty', type: 'float'},
        { name: 'dblAccumulatedAmount', type: 'float'},
        { name: 'intSort', type: 'int'},

        { name: 'strLocationName', type: 'string'},
        { name: 'strUnitMeasure', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'intLocationId'}
    ]
});