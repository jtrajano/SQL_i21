Ext.define('Inventory.store.BufferedItemStockUOMViewTotals', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbuffereditemstockuomviewtotals',

    requires: [
        'Inventory.model.ItemStockUOMViewTotals'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ItemStockUOMViewTotals',
            storeId: 'BufferedItemStockUOMViewTotals',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/ItemStock/SearchItemStockUOMViewTotals'
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