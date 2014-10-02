/**
 * Created by LZabala on 10/2/2014.
 */
Ext.define('Inventory.store.Commodity', {
    extend: 'Ext.data.Store',

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
                    read: '../Inventory/api/Commodity/GetCommodities',
                    update: '../Inventory/api/Commodity/PutCommodities',
                    create: '../Inventory/api/Commodity/PostCommodities',
                    destroy: '../Inventory/api/Commodity/DeleteCommodities'
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