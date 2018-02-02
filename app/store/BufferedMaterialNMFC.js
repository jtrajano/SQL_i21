/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedMaterialNMFC', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    alias: 'store.icbufferedmaterialnmfc',

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
                    read: './inventory/api/materialnmfc/search'
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