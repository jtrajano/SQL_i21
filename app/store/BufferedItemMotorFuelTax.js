Ext.define('Inventory.store.BufferedItemMotorFuelTax', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbuffereditemmotorfueltax',

    requires: [
        'Inventory.model.BufferedItemMotorFuelTax'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ItemMotorFuelTax',
            storeId: 'BufferedItemMotorFuelTax',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Item/GetItemMotorFuelTax'
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
