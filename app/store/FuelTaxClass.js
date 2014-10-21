/**
 * Created by LZabala on 10/1/2014.
 */
Ext.define('Inventory.store.FuelTaxClass', {
    extend: 'Ext.data.Store',
    alias: 'store.inventoryfueltaxclass',

    requires: [
        'Inventory.model.FuelTaxClass'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.FuelTaxClass',
            storeId: 'FuelTaxClass',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/FuelTaxClass/GetFuelTaxClasses',
                    update: '../Inventory/api/FuelTaxClass/PutFuelTaxClasses',
                    create: '../Inventory/api/FuelTaxClass/PostFuelTaxClasses',
                    destroy: '../Inventory/api/FuelTaxClass/DeleteFuelTaxClasses'
                },
                reader: {
                    type: 'json',
                    rootProperty: 'data',
                    messageProperty: 'message'
                },
                writer: {
                    type: 'json',
                    allowSingle: false
                }
            }
        }, cfg)]);
    }
});