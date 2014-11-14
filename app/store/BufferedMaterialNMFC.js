/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedMaterialNMFC', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.inventorybufferedmaterialnmfc',

    requires: [
        'Inventory.model.MaterialNMFC'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.MaterialNMFC',
            storeId: 'BufferedMaterialNMFC',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/MaterialNMFC/GetMaterialNMFCs'
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