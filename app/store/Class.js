/**
 * Created by LZabala on 11/4/2014.
 */
Ext.define('Inventory.store.Class', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.storeclass',

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            fields: [
                { name: 'intClassId', type: 'int'},
                { name: 'strClassId', type: 'boolean'},
                { name: 'strClassDesc', type: 'boolean'},
                { name: 'strClassComment', type: 'boolean'},
                { name: 'intConcurrencyID', type: 'int'},
            ],
            storeId: 'Class',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/SubcategoryClass/GetSubcategoryClasses'
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