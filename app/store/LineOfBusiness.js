/**
 * Created by LZabala on 10/30/2014.
 */
Ext.define('Inventory.store.LineOfBusiness', {
    extend: 'Ext.data.Store',
    alias: 'store.iclineofbusiness',

    requires: [
        'Inventory.model.LineOfBusiness'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.LineOfBusiness',
            storeId: 'LineOfBusiness',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/lineofbusiness/get',
                    update: './inventory/api/lineofbusiness/put',
                    create: './inventory/api/lineofbusiness/post',
                    destroy: './inventory/api/lineofbusiness/delete'
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