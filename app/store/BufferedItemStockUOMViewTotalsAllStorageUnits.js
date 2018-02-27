Ext.define('Inventory.store.BufferedItemStockUOMViewTotalsAllStorageUnits', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbuffereditemstockuomviewtotalsallstorageunits',

    requires: [
        'Inventory.model.ItemStockUOMViewTotals'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ItemStockUOMViewTotals',
            storeId: 'BufferedItemStockUOMViewTotalsAllStorageUnits',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/itemstock/searchitemstockuomviewtotalsallstorageunits'
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