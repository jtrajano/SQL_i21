/**
 * Created by FMontefrio on 02/27/2017.
 */
Ext.define('Inventory.store.BufferedItemSubLocations', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbuffereditemsublocations',

    requires: [
        'Inventory.model.ItemSubLocations'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ItemSubLocations',
            storeId: 'BufferedItemSubLocationsStore',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Item/SearchItemSubLocations'
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