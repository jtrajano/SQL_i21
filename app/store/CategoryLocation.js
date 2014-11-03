/**
 * Created by LZabala on 11/3/2014.
 */
Ext.define('Inventory.store.CategoryLocation', {
    extend: 'Ext.data.Store',
    alias: 'store.inventorycategorylocation',

    requires: [
        'Inventory.model.CategoryLocation'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.CategoryLocation',
            storeId: 'CategoryLocation',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/CategoryLocation/GetCategoryLocations',
                    update: '../Inventory/api/CategoryLocation/PutCategoryLocations',
                    create: '../Inventory/api/CategoryLocation/PostCategoryLocations',
                    destroy: '../Inventory/api/CategoryLocation/DeleteCategoryLocations'
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