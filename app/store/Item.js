/**
 * Created by LZabala on 9/11/2014.
 */
Ext.define('Inventory.store.Item', {
    extend: 'Ext.data.Store',
    alias: 'store.icitem',

    requires: [
        'Inventory.model.Item'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.Item',
            timeout: 120000,
            storeId: 'Item',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Item/Get',
                    update: '../Inventory/api/Item/Put',
                    create: '../Inventory/api/Item/Post',
                    destroy: '../Inventory/api/Item/Delete'
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