/**
 * Created by LZabala on 10/1/2014.
 */
Ext.define('Inventory.store.Category', {
    extend: 'Ext.data.Store',
    alias: 'store.iccategory',

    requires: [
        'Inventory.model.Category'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.Category',
            storeId: 'Category',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/category/get',
                    update: './inventory/api/category/put',
                    create: './inventory/api/category/post',
                    destroy: './inventory/api/category/delete'
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