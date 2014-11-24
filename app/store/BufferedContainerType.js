/**
 * Created by LZabala on 11/24/2014.
 */
Ext.define('Inventory.store.BufferedContainerType', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.inventorybufferedcontainertype',

    requires: [
        'Inventory.model.ContainerType'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ContainerType',
            storeId: 'BufferedContainerType',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/ContainerType/GetContainerTypes'
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