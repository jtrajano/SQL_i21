/**
 * Created by LZabala on 9/3/2015.
 */
Ext.define('Inventory.store.ItemStockView', {
    extend: 'Ext.data.Store',
    alias: 'store.icitemstockview',

    requires: [
        'Inventory.model.ItemStockView'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ItemStockView',
            storeId: 'ItemStockView',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Item/SearchItemStocks'
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