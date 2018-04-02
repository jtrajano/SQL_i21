/**
 * Created by LZabala on 10/10/2014.
 */
Ext.define('Inventory.store.Receipt', {
    extend: 'Ext.data.Store',
    alias: 'store.icreceipt',

    requires: [
        'Inventory.model.Receipt'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.Receipt',
            storeId: 'Receipt',
            pageSize: 50,
            batchActions: true,
            timeout: 600000,
            proxy: {
                timeout: 600000,
                type: 'rest',
                api: {
                    read: './inventory/api/inventoryreceipt/get',
                    update: './inventory/api/inventoryreceipt/put',
                    create: './inventory/api/inventoryreceipt/post',
                    destroy: './inventory/api/inventoryreceipt/delete'
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