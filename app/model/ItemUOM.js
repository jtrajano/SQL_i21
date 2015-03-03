/**
 * Created by LZabala on 9/17/2014.
 */
Ext.define('Inventory.model.ItemUOM', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field',
        'AccountsPayable.common.validators.NotZero'
    ],

    idProperty: 'intItemUOMId',

    fields: [
        { name: 'intItemUOMId', type: 'int'},
        { name: 'intItemId',
            type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemUOMs',
                    storeConfig: {
                        remoteFilter: true,
                        proxy: {
                            type: 'rest',
                            api: {
                                read: '../Inventory/api/ItemUnitMeasure/GetItemUnitMeasures'
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
        { name: 'intUnitMeasureId', type: 'int', allowNull: true },
        { name: 'dblUnitQty', type: 'float' },
        { name: 'dblSellQty', type: 'float' },
        { name: 'dblWeight', type: 'float' },
        { name: 'intWeightUOMId', type: 'int', allowNull: true },
        { name: 'strDescription', type: 'string' },
        { name: 'strUpcCode', type: 'string' },
        { name: 'ysnStockUnit', type: 'boolean' },
        { name: 'ysnAllowPurchase', type: 'boolean' },
        { name: 'ysnAllowSale', type: 'boolean' },
        { name: 'dblLength', type: 'float' },
        { name: 'dblWidth', type: 'float' },
        { name: 'dblHeight', type: 'float' },
        { name: 'intDimensionUOMId', type: 'int', allowNull: true },
        { name: 'dblVolume', type: 'float' },
        { name: 'intVolumeUOMId', type: 'int', allowNull: true },
        { name: 'dblMaxQty', type: 'float' },
        { name: 'intSort', type: 'int', allowNull: true },
        { name: 'strUnitMeasure', type: 'string'},
        { name: 'intDecimalCalculation', type: 'int'},
        { name: 'intDecimalDisplay', type: 'int'}
    ],

    validators: [
        {type: 'presence', field: 'strUnitMeasure'},
        {type: 'notzero', field: 'dblUnitQty'}
    ]
});