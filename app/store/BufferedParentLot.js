/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedParentLot', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbufferedparentlot',

    requires: [
        'Inventory.model.ParentLot'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ParentLot',
            storeId: 'BufferedParentLot',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/parentlot/search'
                },
                reader: {
                    type: 'json',
                    rootProperty: 'data',
                    messageProperty: 'message'
                }
            }
        }, cfg)]);
    }
});