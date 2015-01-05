/**
 * Created by LZabala on 11/25/2014.
 */
Ext.define('Inventory.store.BufferedItemStockDetailView', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbuffereditemstockdetailview',

    requires: [
        'Inventory.model.ItemStockDetailView'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ItemStockDetailView',
            storeId: 'BufferedItemStockDetailView',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Item/GetItemStockDetails'
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