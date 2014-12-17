/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedFactoryUnitType', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbufferedfactoryunittype',

    requires: [
        'Inventory.model.FactoryUnitType'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.FactoryUnitType',
            storeId: 'BufferedFactoryUnitType',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/StorageUnitType/GetStorageUnitTypes'
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
