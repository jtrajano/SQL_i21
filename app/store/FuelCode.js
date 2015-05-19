/**
 * Created by marahman on 18-09-2014.
 */
Ext.define('Inventory.store.FuelCode', {
    extend: 'Ext.data.Store',
    alias: 'store.icfuelcode',

    requires: [
        'Inventory.model.FuelCode'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.FuelCode',
            storeId: 'FuelCode',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/FuelCode/Get',
                    update: '../Inventory/api/FuelCode/Put',
                    create: '../Inventory/api/FuelCode/Post',
                    destroy: '../Inventory/api/FuelCode/Delete'
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
