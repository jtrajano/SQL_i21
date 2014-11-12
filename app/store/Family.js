/**
 * Created by LZabala on 11/4/2014.
 */
Ext.define('Inventory.store.Family', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.storefamily',

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            fields: [
                { name: 'intFamilyId', type: 'int'},
                { name: 'strFamilyId', type: 'boolean'},
                { name: 'strFamilyDesc', type: 'boolean'},
                { name: 'strFamilyComment', type: 'boolean'},
                { name: 'intConcurrencyID', type: 'int'},
            ],
            storeId: 'Family',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/SubcategoryFamily/GetSubcategoryFamilies'
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