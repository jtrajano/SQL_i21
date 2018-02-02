/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedLineOfBusiness', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    alias: 'store.icbufferedlineofbusiness',

    requires: [
        'Inventory.model.LineOfBusiness'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.LineOfBusiness',
            storeId: 'BufferedLineOfBusiness',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/lineofbusiness/search'
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