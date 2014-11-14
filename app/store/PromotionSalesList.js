/**
 * Created by LZabala on 11/14/2014.
 */
Ext.define('Inventory.store.PromotionSalesList', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.storepromotionsaleslist',

    requires: [
        'Inventory.model.PromotionSalesList'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.PromotionSalesList',
            storeId: 'PromotionSalesList',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/PromotionSalesList/GetPromotionSalesLists'
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