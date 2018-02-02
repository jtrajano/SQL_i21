Ext.define('Inventory.store.BufferedItemMotorFuelTax', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
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
                    read: './inventory/api/item/getitemmotorfueltax'
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
