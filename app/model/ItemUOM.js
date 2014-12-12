/**
 * Created by LZabala on 9/17/2014.
 */
Ext.define('Inventory.model.ItemUOM', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
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
        { name: 'intUnitMeasureId', type: 'int', allowNull: true},
        { name: 'dblUnitQty', type: 'float'},
        { name: 'dblSellQty', type: 'float'},
        { name: 'dblWeight', type: 'float'},
        { name: 'strDescription', type: 'string'},
        { name: 'ysnStockUnit', type: 'boolean'},
        { name: 'ysnAllowPurchase', type: 'boolean'},
        { name: 'ysnAllowSale', type: 'boolean'},
        { name: 'dblConvertToStock', type: 'float'},
        { name: 'dblConvertFromStock', type: 'float'},
        { name: 'dblLength', type: 'float'},
        { name: 'dblWidth', type: 'float'},
        { name: 'dblHeight', type: 'float'},
        { name: 'dblVolume', type: 'float'},
        { name: 'dblMaxQty', type: 'float'},

        { name: 'strUnitMeasure', type: 'string'},
        { name: 'intDecimalCalculation', type: 'int'},
        { name: 'intDecimalDisplay', type: 'int'}
    ],

    validators: [
        {type: 'presence', field: 'strUnitMeasure'}
    ]
});