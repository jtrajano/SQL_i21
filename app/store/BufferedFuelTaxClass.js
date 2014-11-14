/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedFuelTaxClass', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.inventorybufferedfueltaxclass',

    requires: [
        'Inventory.model.FuelTaxClass'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.FuelTaxClass',
            storeId: 'BufferedFuelTaxClass',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/FuelTaxClass/GetFuelTaxClasses'
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