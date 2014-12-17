/**
 * Created by LZabala on 11/24/2014.
 */
Ext.define('Inventory.store.BufferedRestriction', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbufferedrestriction',

    requires: [
        'Inventory.model.Restriction'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.Restriction',
            storeId: 'BufferedRestriction',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Restriction/GetRestrictions'
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