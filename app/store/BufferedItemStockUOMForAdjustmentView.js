Ext.define('Inventory.store.BufferedItemStockUOMForAdjustmentView', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbuffereditemstockuomforadjustmentview',

    requires: [
        'Inventory.model.ItemStockUOMForAdjustmentView'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ItemStockUOMForAdjustmentView',
            storeId: 'BufferedItemStockUOMForAdjustmentView',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/ItemStock/SearchItemStockUOMForAdjustment'
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