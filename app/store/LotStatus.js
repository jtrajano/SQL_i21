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
                    read: './inventory/api/lotstatus/get',
                    update: './inventory/api/lotstatus/put',
                    create: './inventory/api/lotstatus/post',
                    destroy: './inventory/api/lotstatus/delete'
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