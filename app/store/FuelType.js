/**
 * Created by marahman on 16-09-2014.
 */
Ext.define('Inventory.store.FuelType', {
    extend: 'Ext.data.Store',
    alias: 'store.inventoryfueltype',

    requires: [
        'Inventory.model.FuelType'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.FuelType',
            storeId: 'Tag',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/FuelType/GetFuelTypes',
                    update: '../Inventory/api/FuelType/PutFuelTypes',
                    create: '../Inventory/api/FuelType/PostFuelTypes',
                    destroy: '../Inventory/api/FuelType/DeleteFuelTypes'
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
