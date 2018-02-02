/**
 * Created by LZabala on 11/24/2014.
 */
Ext.define('Inventory.store.BufferedContainerType', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    alias: 'store.icbufferedcontainertype',

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
                    read: './inventory/api/containertype/search'
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