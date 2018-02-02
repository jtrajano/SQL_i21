/**
 * Created by LZabala on 1/8/2015.
 */
Ext.define('Inventory.store.BufferedItemFactory', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    alias: 'store.icbuffereditemfactory',

    requires: [
        'Inventory.model.CompactItemFactory'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.CompactItemFactory',
            storeId: 'BufferedItemFactory',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/itemfactory/search'
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