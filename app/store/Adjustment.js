/**
 * Created by LZabala on 10/1/2014.
 */
Ext.define('Inventory.store.Adjustment', {
    extend: 'Ext.data.Store',
    alias: 'store.icadjustment',

    requires: [
        'Inventory.model.Adjustment'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.Adjustment',
            storeId: 'Adjustment',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/inventoryadjustment/get',
                    update: './inventory/api/inventoryadjustment/put',
                    create: './inventory/api/inventoryadjustment/post',
                    destroy: './inventory/api/inventoryadjustment/delete'
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