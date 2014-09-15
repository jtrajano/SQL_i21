/**
 * Created by LZabala on 9/11/2014.
 */
Ext.define('Inventory.store.Item', {
    extend: 'Ext.data.Store',

    requires: [
        'Inventory.model.Item'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.Item',
            storeId: 'Item',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Item/GetItems',
                    update: '../Inventory/api/Item/PutItem',
                    create: '../Inventory/api/Item/PostItem',
                    destroy: '../Inventory/api/Item/DeleteItem'
                },
                reader: {
                    type: 'json',
                    root: 'data',
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