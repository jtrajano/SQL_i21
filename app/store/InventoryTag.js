/**
 * Created by marahman on 16-09-2014.
 */
Ext.define('Inventory.store.InventoryTag', {
    extend: 'Ext.data.Store',
    alias: 'store.ictag',

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
                    read: '../Inventory/api/Tag/Get',
                    update: '../Inventory/api/Tag/Put',
                    create: '../Inventory/api/Tag/Post',
                    destroy: '../Inventory/api/Tag/Delete'
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
