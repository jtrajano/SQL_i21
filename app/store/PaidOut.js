/**
 * Created by LZabala on 11/4/2014.
 */
Ext.define('Inventory.store.PaidOut', {
    extend: 'Ext.data.Store',
    alias: 'store.storepaidout',

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            fields: [
                { name: 'intPaidOutId', type: 'int'},
                { name: 'intStoreId', type: 'int'},
                { name: 'strPaidOutId', type: 'boolean'},
                { name: 'strDescription', type: 'boolean'},
                { name: 'intAccountId', type: 'int'},
                { name: 'intPaymentMethodId', type: 'int'}
            ],
            storeId: 'PaidOut',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/PaidOut/GetPaidOuts'
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