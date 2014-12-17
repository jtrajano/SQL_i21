/**
 * Created by LZabala on 10/1/2014.
 */
Ext.define('Inventory.store.MaterialNMFC', {
    extend: 'Ext.data.Store',
    alias: 'store.icmaterialnmfc',

    requires: [
        'Inventory.model.MaterialNMFC'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.MaterialNMFC',
            storeId: 'MaterialNMFC',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/MaterialNMFC/GetMaterialNMFCs',
                    update: '../Inventory/api/MaterialNMFC/PutMaterialNMFCs',
                    create: '../Inventory/api/MaterialNMFC/PostMaterialNMFCs',
                    destroy: '../Inventory/api/MaterialNMFC/DeleteMaterialNMFCs'
                },
                reader: {
                    type: 'json',
                    rootProperty: 'data',
                    messageProperty: 'message'
                },
                writer: {
                    type: 'json',
                    allowSingle: false
                }
            }
        }, cfg)]);
    }
});