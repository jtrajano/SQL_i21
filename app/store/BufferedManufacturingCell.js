/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedManufacturingCell', {
    extend: 'Ext.data.BufferedStore',
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
                    read: '../Inventory/api/ManufacturingCell/GetManufacturingCells'
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