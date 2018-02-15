/**
 * Created by LZabala on 1/28/2015.
 */
Ext.define('Inventory.store.BufferedItemPricingView', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseBufferedStore',
    alias: 'store.icbuffereditempricingview',

    requires: [
        'Inventory.model.ItemStockDetailPricing'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ItemStockDetailPricing',
            storeId: 'BufferedItemPricingView',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/itempricing/searchitempricingviews'
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