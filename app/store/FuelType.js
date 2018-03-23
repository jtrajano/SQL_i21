/**
 * Created by marahman on 16-09-2014.
 */
Ext.define('Inventory.store.FuelType', {
    extend: 'Ext.data.Store',
    alias: 'store.icfueltype',

    requires: [
        'Inventory.model.FuelType'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.FuelType',
            storeId: 'FuelType',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/fueltype/get',
                    update: './inventory/api/fueltype/put',
                    create: './inventory/api/fueltype/post',
                    destroy: './inventory/api/fueltype/delete'
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
