/**
 * Created by LZabala on 10/23/2014.
 */
Ext.define('Inventory.store.ItemLocation', {
    extend: 'Ext.data.Store',
    alias: 'store.icitemlocation',

    requires: [
        'Inventory.model.ItemLocation'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ItemLocation',
            storeId: 'ItemLocation',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/ItemLocation/Get',
                    update: '../Inventory/api/ItemLocation/Put',
                    create: '../Inventory/api/ItemLocation/Post',
                    destroy: '../Inventory/api/ItemLocation/Delete'
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