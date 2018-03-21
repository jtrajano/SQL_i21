/**
 * Created by kkarthick on 18-09-2014.
 */

Ext.define('Inventory.store.Manufacturer', {
    extend: 'Ext.data.Store',
    alias: 'store.icmanufacturer',

    requires: [
        'Inventory.model.Manufacturer'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.Manufacturer',
            storeId: 'Manufacturer',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/manufacturer/get',
                    update: './inventory/api/manufacturer/put',
                    create: './inventory/api/manufacturer/post',
                    destroy: './inventory/api/manufacturer/delete'
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