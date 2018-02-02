/**
 * Created by LZabala on 10/2/2014.
 */
Ext.define('Inventory.store.Commodity', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
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
                    read: './inventory/api/commodity/get',
                    update: './inventory/api/commodity/put',
                    create: './inventory/api/commodity/post',
                    destroy: './inventory/api/commodity/delete'
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