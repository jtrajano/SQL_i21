/**
 * Created by LZabala on 11/4/2014.
 */
Ext.define('Inventory.store.Product', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.storeproduct',

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            fields: [
                { name: 'intRegProdId', type: 'int'},
                { name: 'intStoreId', type: 'int'},
                { name: 'strRegProdCode', type: 'boolean'},
                { name: 'strRegProdDesc', type: 'boolean'},
                { name: 'strRegProdComment ', type: 'boolean'},
                { name: 'intConcurrencyID', type: 'int'},
            ],
            storeId: 'Product',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/SubcategoryRegProd/GetSubcategoryRegProds'
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