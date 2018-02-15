/**
 * Created by LZabala on 9/18/2015.
 */
Ext.define('Inventory.store.BufferedInventoryValuation', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseBufferedStore',
    alias: 'store.icbufferedinventoryvaluation',

    requires: [
        'Inventory.model.InventoryValuation'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.InventoryValuation',
            storeId: 'BufferedInventoryValuation',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/item/searchinventoryvaluation'
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