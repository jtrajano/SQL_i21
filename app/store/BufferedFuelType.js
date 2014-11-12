/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedFuelType', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.inventorybufferedfueltype',

    requires: [
        'Inventory.model.FuelType'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.FuelType',
            storeId: 'BufferedFuelType',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/FuelType/GetFuelTypes'
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
