/**
 * Created by LZabala on 10/30/2014.
 */
Ext.define('Inventory.store.LotStatus', {
    extend: 'Ext.data.Store',
    alias: 'store.iclotstatus',

    requires: [
        'Inventory.model.LotStatus'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.LotStatus',
            storeId: 'LotStatus',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/LotStatus/Get',
                    update: '../Inventory/api/LotStatus/Put',
                    create: '../Inventory/api/LotStatus/Post',
                    destroy: '../Inventory/api/LotStatus/Delete'
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