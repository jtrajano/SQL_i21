/**
 * Created by LZabala on 9/3/2015.
 */
Ext.define('Inventory.store.Lot', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    alias: 'store.iclot',

    requires: [
        'Inventory.model.Lot'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.Lot',
            storeId: 'Lot',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/lot/get'
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