/**
 * Created by marahman on 18-09-2014.
 */
Ext.define('Inventory.store.FuelCategory', {
    extend: 'Ext.data.Store',
    alias: 'store.icfuelcategory',

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
                    read: '../Inventory/api/FuelCategory/GetFuelCategories',
                    update: '../Inventory/api/FuelCategory/PutFuelCategories',
                    create: '../Inventory/api/FuelCategory/PostFuelCategories',
                    destroy: '../Inventory/api/FuelCategory/DeleteFuelCategories'
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
