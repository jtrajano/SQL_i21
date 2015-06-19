/**
 * Created by LZabala on 1/27/2015.
 */
Ext.define('Inventory.store.BufferedCategoryUOM', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbufferedcategoryuom',

    requires: [
        'Inventory.model.CategoryUOM'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.CategoryUOM',
            storeId: 'BufferedCategoryUOM',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/CategoryUOM/Search'
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