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
        { name: 'strPriceLevel', type: 'string'},
        { name: 'intUnitMeasureId', type: 'int', allowNull: true },
        { name: 'dblUnit', type: 'float'},
        { name: 'dblMin', type: 'float'},
        { name: 'dblMax', type: 'float'},
        { name: 'strPricingMethod', type: 'string'},
        { name: 'strCommissionOn', type: 'string'},
        { name: 'dblCommissionRate', type: 'float'},
        { name: 'dblUnitPrice', type: 'float'},
        { name: 'ysnActive', type: 'boolean'},
        { name: 'intSort', type: 'int'},

        { name: 'strLocationName', type: 'string'},
        { name: 'strUnitMeasure', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'intLocationId'}
    ]
});