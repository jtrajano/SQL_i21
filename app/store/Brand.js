/**
 * Created by LZabala on 10/1/2014.
 */
Ext.define('Inventory.store.Brand', {
    extend: 'Ext.data.Store',
    alias: 'store.inventorybrand',

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
                    read: '../Inventory/api/Brand/GetBrands',
                    update: '../Inventory/api/Brand/PutBrands',
                    create: '../Inventory/api/Brand/PostBrands',
                    destroy: '../Inventory/api/Brand/DeleteBrands'
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