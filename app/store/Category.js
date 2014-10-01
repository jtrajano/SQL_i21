/**
 * Created by LZabala on 10/1/2014.
 */
Ext.define('Inventory.store.Category', {
    extend: 'Ext.data.Store',

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
                    read: '../Inventory/api/Item/GetCategories',
                    update: '../Inventory/api/Item/PutCategories',
                    create: '../Inventory/api/Item/PostCategories',
                    destroy: '../Inventory/api/Item/DeleteCategories'
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