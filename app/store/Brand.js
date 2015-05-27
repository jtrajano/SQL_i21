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
                    read: '../Inventory/api/Brand/Get',
                    update: '../Inventory/api/Brand/Put',
                    create: '../Inventory/api/Brand/Post',
                    destroy: '../Inventory/api/Brand/Delete'
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