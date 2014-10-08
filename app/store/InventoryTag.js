/**
 * Created by marahman on 16-09-2014.
 */
Ext.define('Inventory.store.InventoryTag', {
    extend: 'Ext.data.Store',
    alias: 'store.inventorytag',

    requires: [
        'Inventory.model.InventoryTag'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.InventoryTag',
            storeId: 'Tag',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Tag/GetTags',
                    update: '../Inventory/api/Tag/PutTags',
                    create: '../Inventory/api/Tag/PostTags',
                    destroy: '../Inventory/api/Tag/DeleteTags'
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
