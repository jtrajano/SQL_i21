/**
 * Created by marahman on 18-09-2014.
 */
Ext.define('Inventory.store.FuelCategory', {
    extend: 'Ext.data.Store',
    alias: 'store.inventoryfuelcategory',

    requires: [
        'Inventory.model.FuelCategory'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.FuelCategory',
            storeId: 'FuelCategory',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/RinFuelType/GetRinFuelTypes',
                    update: '../Inventory/api/RinFuelType/PutRinFuelTypes',
                    create: '../Inventory/api/RinFuelType/PostRinFuelTypes',
                    destroy: '../Inventory/api/RinFuelType/DeleteRinFuelTypes'
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
