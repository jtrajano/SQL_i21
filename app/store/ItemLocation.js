/**
 * Created by LZabala on 10/23/2014.
 */
Ext.define('Inventory.store.ItemLocation', {
    extend: 'Ext.data.Store',
    alias: 'store.inventoryitemlocation',

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
                    read: '../Inventory/api/ItemLocation/GetItemLocations',
                    update: '../Inventory/api/ItemLocation/PutItemLocations',
                    create: '../Inventory/api/ItemLocation/PostItemLocations',
                    destroy: '../Inventory/api/ItemLocation/DeleteItemLocations'
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