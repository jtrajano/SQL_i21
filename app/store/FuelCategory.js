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
                    read: '../Inventory/api/FuelCategory/Get',
                    update: '../Inventory/api/FuelCategory/Put',
                    create: '../Inventory/api/FuelCategory/Post',
                    destroy: '../Inventory/api/FuelCategory/Delete'
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
