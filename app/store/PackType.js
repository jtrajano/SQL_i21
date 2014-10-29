/**
 * Created by LZabala on 10/1/2014.
 */
Ext.define('Inventory.store.PackType', {
    extend: 'Ext.data.Store',
    alias: 'store.inventorypacktype',

    requires: [
        'Inventory.model.PackType'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.PackType',
            storeId: 'PackType',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/PackType/GetPackTypes',
                    update: '../Inventory/api/PackType/PutPackTypes',
                    create: '../Inventory/api/PackType/PostPackTypes',
                    destroy: '../Inventory/api/PackType/DeletePackTypes'
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