/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedBrand', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.inventorybufferedbrand',

    requires: [
        'Inventory.model.Brand'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.Brand',
            storeId: 'BufferedBrand',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Brand/GetBrands'
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