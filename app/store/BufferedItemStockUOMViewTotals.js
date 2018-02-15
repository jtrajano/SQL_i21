Ext.define('Inventory.store.BufferedItemStockUOMViewTotals', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseBufferedStore',
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
                    read: './inventory/api/itemstock/searchitemstockuomviewtotals'
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