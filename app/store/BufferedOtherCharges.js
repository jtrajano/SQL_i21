/**
 * Created by LZabala on 4/17/2015.
 */
Ext.define('Inventory.store.BufferedOtherCharges', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseBufferedStore',
    alias: 'store.icbufferedothercharges',

    requires: [
        'Inventory.model.CompactItem'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.CompactItem',
            storeId: 'BufferedOtherCharges',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/item/searchothercharges'
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