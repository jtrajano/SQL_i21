/**
 * Created by LZabala on 11/24/2014.
 */
Ext.define('Inventory.store.BufferedMeasurement', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbufferedmeasurement',

    requires: [
        'Inventory.model.Measurement'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.Measurement',
            storeId: 'BufferedMeasurement',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Measurement/GetMeasurements'
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