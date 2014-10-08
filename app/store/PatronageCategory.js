/**
 * Created by rnkumashi on 16-09-2014.
 */

Ext.define('Inventory.store.PatronageCategory', {
    extend: 'Ext.data.Store',
    alias: 'store.inventorypatronagecategory',

    requires: [
        'Inventory.model.PatronageCategory'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.PatronageCategory',
            storeId: 'PatronageCategory',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/PatronageCategory/GetPatronageCategories',
                    update: '../Inventory/api/PatronageCategory/PutPatronageCategories',
                    create: '../Inventory/api/PatronageCategory/PostPatronageCategories',
                    destroy: '../Inventory/api/PatronageCategory/DeletePatronageCategories'
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
