/**
 * Created by marahman on 19-09-2014.
 */
Ext.define('Inventory.store.ProductionProcess', {
    extend: 'Ext.data.Store',
    alias: 'store.icproductionprocess',

    requires: [
        'Inventory.model.ProductionProcess'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ProductionProcess',
            storeId: 'ProductionProcess',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/processcode/get',
                    update: './inventory/api/processcode/put',
                    create: './inventory/api/processcode/post',
                    destroy: './inventory/api/processcode/delete'
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
