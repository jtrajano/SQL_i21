/**
 * Created by LZabala on 10/1/2014.
 */
Ext.define('Inventory.store.CountGroup', {
    extend: 'Ext.data.Store',
    alias: 'store.iccountgroup',

    requires: [
        'Inventory.model.CountGroup'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.CountGroup',
            storeId: 'CountGroup',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/countgroup/get',
                    update: './inventory/api/countgroup/put',
                    create: './inventory/api/countgroup/post',
                    destroy: './inventory/api/countgroup/delete'
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