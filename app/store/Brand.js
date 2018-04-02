/**
 * Created by LZabala on 10/1/2014.
 */
Ext.define('Inventory.store.Brand', {
    extend: 'Ext.data.Store',
    alias: 'store.icbrand',

    requires: [
        'Inventory.model.Brand'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.Brand',
            storeId: 'Brand',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/brand/get',
                    update: './inventory/api/brand/put',
                    create: './inventory/api/brand/post',
                    destroy: './inventory/api/brand/delete'
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