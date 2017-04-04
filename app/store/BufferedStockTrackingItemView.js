Ext.define('Inventory.store.BufferedStockTrackingItemView', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbufferedstocktrackingitemview',

    requires: [
        'Inventory.model.ItemStockView'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ItemStockView',
            storeId: 'BufferedStockTrackingItemView',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Item/SearchStockTrackingItems'
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