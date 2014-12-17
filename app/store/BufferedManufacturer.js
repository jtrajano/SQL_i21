/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedManufacturer', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbufferedmanufacturer',

    requires: [
        'Inventory.model.Manufacturer'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.Manufacturer',
            storeId: 'BufferedManufacturer',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Manufacturer/GetManufacturers'
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