/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedFuelCode', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    alias: 'store.icbufferedfuelcode',

    requires: [
        'Inventory.model.FuelCode'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.FuelCode',
            storeId: 'BufferedFuelCode',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/fuelcode/search'
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
