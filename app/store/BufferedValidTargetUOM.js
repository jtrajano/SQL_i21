Ext.define('Inventory.store.BufferedValidTargetUOM', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseBufferedStore',
    alias: 'store.icbufferedvalidtargetuom',

    requires: [
        'Inventory.model.UnitMeasure'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.UnitMeasure',
            storeId: 'BufferedUnitMeasure',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/unitmeasure/getvalidtargetuom'
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
