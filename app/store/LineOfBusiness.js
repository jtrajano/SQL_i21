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
                    read: '../Inventory/api/LineOfBusiness/Get',
                    update: '../Inventory/api/LineOfBusiness/Put',
                    create: '../Inventory/api/LineOfBusiness/Post',
                    destroy: '../Inventory/api/LineOfBusiness/Delete'
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