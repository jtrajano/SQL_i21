/**
 * Created by LZabala on 9/29/2014.
 */
Ext.define('Inventory.model.ItemUPC', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemUPCId',

    fields: [
        { name: 'intItemUPCId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemUPCs',
                    storeConfig: {
                        remoteFilter: true,
                        proxy: {
                            type: 'rest',
                            api: {
                                read: '../Inventory/api/ItemUPC/GetItemUPCs'
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
        { name: 'intItemUnitMeasureId', type: 'int', allowNull: true },
        { name: 'dblUnitQty', type: 'float' },
        { name: 'strUPCCode', type: 'string' },
        { name: 'intSort', type: 'int', allowNull: true },

        { name: 'strUnitMeasure', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strUnitMeasure'}
    ]
});