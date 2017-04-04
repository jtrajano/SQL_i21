/**
 * Created by LZabala on 10/23/2015.
 */
Ext.define('Inventory.store.ItemStockUOMView', {
    extend: 'Ext.data.Store',
    alias: 'store.icitemstockuomview',

    requires: [
        'Inventory.model.ItemStockUOMView'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ItemStockUOMView',
            storeId: 'ItemStockUOMView',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/ItemStock/SearchItemStockUOMs'
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