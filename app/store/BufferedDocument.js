/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedDocument', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.inventorybuffereddocument',

    requires: [
        'Inventory.model.Document'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.Document',
            storeId: 'BufferedDocument',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Document/GetDocuments'
                },
                reader: {
                    type: 'json',
                    rootProperty: 'data',
                    messageProperty: 'message'
                }
            }
        }, cfg)]);
    }
});