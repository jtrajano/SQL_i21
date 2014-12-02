/**
 * Created by LZabala on 10/20/2014.
 */
Ext.define('Inventory.model.ItemStock', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemStockId',

    fields: [
        { name: 'intItemStockId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemStocks',
                    storeConfig: {
                        complete: true,
                        remoteFilter: true,
                        proxy: {
                            type: 'rest',
                            api: {
                                read: '../Inventory/api/ItemStock/GetItemStocks'
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
        { name: 'intLocationId', type: 'int', allowNull: true },
        { name: 'strWarehouse', type: 'string'},
        { name: 'intUnitMeasureId', type: 'int', allowNull: true },
        { name: 'dblUnitOnHand', type: 'float'},
        { name: 'dblOrderCommitted', type: 'float'},
        { name: 'dblOnOrder', type: 'float'},
        { name: 'dblReorderPoint', type: 'float'},
        { name: 'dblMinOrder', type: 'float'},
        { name: 'dblSuggestedQuantity', type: 'float'},
        { name: 'dblLeadTime', type: 'float'},
        { name: 'strCounted', type: 'string'},
        { name: 'intInventoryGroupId', type: 'int', allowNull: true},
        { name: 'ysnCountedDaily', type: 'boolean'},
        { name: 'intSort', type: 'int'}
    ],

    validators: [
        {type: 'presence', field: 'strLocationName'}
    ]
});