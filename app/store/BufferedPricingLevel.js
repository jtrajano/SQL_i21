/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedPricingLevel', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbufferedpricinglevel',

    requires: [
        'Inventory.model.PricingLevel'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.PricingLevel',
            storeId: 'BufferedPricingLevel',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/PricingLevel/GetPricingLevels'
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