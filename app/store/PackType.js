/**
 * Created by LZabala on 10/1/2014.
 */
Ext.define('Inventory.store.PackType', {
    extend: 'Ext.data.Store',
    alias: 'store.icpacktype',

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
                    read: '../inventory/api/packtype/getpacktypes',
                    update: '../inventory/api/packtype/putpacktypes',
                    create: '../inventory/api/packtype/postpacktypes',
                    destroy: '../inventory/api/packtype/deletepacktypes'
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