/**
 * Created by LZabala on 10/1/2014.
 */
Ext.define('Inventory.store.StorageLocation', {
    extend: 'Ext.data.Store',
    alias: 'store.icstoragelocation',

    requires: [
        'Inventory.model.StorageLocation'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.StorageLocation',
            storeId: 'StorageLocation',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/StorageLocation/Get',
                    update: '../Inventory/api/StorageLocation/Put',
                    create: '../Inventory/api/StorageLocation/Post',
                    destroy: '../Inventory/api/StorageLocation/Delete'
                },
                reader: {
                    type: 'json',
                    rootProperty: 'data',
                    messageProperty: 'message'
                },
                writer: {
                    type: 'json',
                    allowSingle: false
                }
            }
        }, cfg)]);
    }
});