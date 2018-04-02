/**
 * Created by LZabala on 10/9/2014.
 */
Ext.define('Inventory.store.Document', {
    extend: 'Ext.data.Store',
    alias: 'store.icdocument',

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
                    read: './inventory/api/document/get',
                    update: './inventory/api/document/put',
                    create: './inventory/api/document/post',
                    destroy: './inventory/api/document/delete'
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