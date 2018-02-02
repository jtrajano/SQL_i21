/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedManufacturingCell', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    alias: 'store.icbufferedmanufacturingcell',

    requires: [
        'Inventory.model.ManufacturingCell'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ManufacturingCell',
            storeId: 'BufferedManufacturingCell',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/manufacturingcell/search'
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