Ext.define('Inventory.store.BufferedItemAccountView', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbuffereditemaccountview',

    requires: [
        'Inventory.model.ItemAccountView'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ItemAccountView',
            storeId: 'BufferedItemAccountView',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/item/searchitemaccounts'
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