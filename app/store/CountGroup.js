/**
 * Created by LZabala on 10/1/2014.
 */
Ext.define('Inventory.store.CountGroup', {
    extend: 'Ext.data.Store',
    alias: 'store.inventorycountgroup',

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
                    read: '../Inventory/api/CountGroup/GetCountGroups',
                    update: '../Inventory/api/CountGroup/PutCountGroups',
                    create: '../Inventory/api/CountGroup/PostCountGroups',
                    destroy: '../Inventory/api/CountGroup/DeleteCountGroups'
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