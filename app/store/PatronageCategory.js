/**
 * Created by rnkumashi on 16-09-2014.
 */

Ext.define('Inventory.store.PatronageCategory', {
    extend: 'Ext.data.Store',
    alias: 'store.icpatronagecategory',

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
                    read: '../Inventory/api/PatronageCategory/Get',
                    update: '../Inventory/api/PatronageCategory/Put',
                    create: '../Inventory/api/PatronageCategory/Post',
                    destroy: '../Inventory/api/PatronageCategory/Delete'
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
