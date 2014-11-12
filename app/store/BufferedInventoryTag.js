/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedInventoryTag', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.inventorybufferedtag',

    requires: [
        'Inventory.model.InventoryTag'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.InventoryTag',
            storeId: 'BufferedTag',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Tag/GetTags'
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
