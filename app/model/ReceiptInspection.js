/**
 * Created by LZabala on 10/10/2014.
 */
Ext.define('Inventory.model.ReceiptInspection', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryReceiptInspectionId',

    fields: [
        { name: 'intInventoryReceiptInspectionId', type: 'int'},
        { name: 'intInventoryReceiptId', type: 'int',
            reference: {
                type: 'Inventory.model.Receipt',
                inverse: {
                    role: 'tblICInventoryReceiptInspections',
                    storeConfig: {
                        complete: true,
                        remoteFilter: true,
                        proxy: {
                            type: 'rest',
                            api: {
                                read: '../Inventory/api/InventoryReceipt/GetReceiptInspections'
                            },
                            reader: {
                                type: 'json',
                                rootProperty: 'data'
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
        { name: 'intQAPropertyId', type: 'int', allowNull: true },
        { name: 'ysnSelected', type: 'boolean'},
        { name: 'intSort', type: 'int'},
        { name: 'strPropertyName', type: 'string'},
    ],

    validators: [
        {type: 'presence', field: 'intQAPropertyId'}
    ]
});