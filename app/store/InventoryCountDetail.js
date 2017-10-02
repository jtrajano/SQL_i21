Ext.define('Inventory.store.InventoryCountDetail', {
    extend: 'Ext.data.Store',
    alias: 'store.icinventorycountdetail',

    requires: [
        'Inventory.model.InventoryCountDetail'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.InventoryCountDetail',
            storeId: 'InventoryCountDetail',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/inventorycountdetail/get',
                    update: './inventory/api/inventorycountdetail/put',
                    create: './inventory/api/inventorycountdetail/post',
                    destroy: './inventory/api/inventorycountdetail/delete'
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