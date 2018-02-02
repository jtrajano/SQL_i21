/**
 * Created by marahman on 16-09-2014.
 */
Ext.define('Inventory.store.InventoryTag', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    alias: 'store.ictag',

    requires: [
        'Inventory.model.InventoryTag'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.InventoryTag',
            storeId: 'Tag',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/tag/get',
                    update: './inventory/api/tag/put',
                    create: './inventory/api/tag/post',
                    destroy: './inventory/api/tag/delete'
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
