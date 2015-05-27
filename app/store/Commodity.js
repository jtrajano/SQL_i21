/**
 * Created by LZabala on 10/2/2014.
 */
Ext.define('Inventory.store.Commodity', {
    extend: 'Ext.data.Store',
    alias: 'store.iccommodity',

    requires: [
        'Inventory.model.Commodity'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.Commodity',
            storeId: 'Commodity',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Commodity/Get',
                    update: '../Inventory/api/Commodity/Put',
                    create: '../Inventory/api/Commodity/Post',
                    destroy: '../Inventory/api/Commodity/Delete'
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