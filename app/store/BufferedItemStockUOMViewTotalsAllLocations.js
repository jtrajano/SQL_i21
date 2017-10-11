Ext.define('Inventory.store.BufferedItemStockUOMViewTotalsAllLocations', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbuffereditemstockuomviewtotalsalllocations',

    requires: [
        'Inventory.model.ItemStockUOMViewTotals'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ItemStockUOMViewTotals',
            storeId: 'BufferedItemStockUOMViewTotalsAllLocations',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/itemstock/searchitemstockuomviewtotalsalllocations'
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