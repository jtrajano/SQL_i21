/**
 * Created by LZabala on 10/9/2014.
 */
Ext.define('Inventory.store.Document', {
    extend: 'Ext.data.Store',
    alias: 'store.inventorydocument',

    requires: [
        'Inventory.model.Document'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.Document',
            storeId: 'Document',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Document/GetDocuments',
                    update: '../Inventory/api/Document/PutDocuments',
                    create: '../Inventory/api/Document/PostDocuments',
                    destroy: '../Inventory/api/Document/DeleteDocuments'
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