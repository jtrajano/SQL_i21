/**
 * Created by LZabala on 10/24/2014.
 */
Ext.define('Inventory.store.ItemPricing', {
    extend: 'Ext.data.Store',
    alias: 'store.icitempricing',

    requires: [
        'Inventory.model.ItemPricing'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ItemPricing',
            storeId: 'ItemPricing',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/itempricing/get',
                    update: './inventory/api/itempricing/put',
                    create: './inventory/api/itempricing/post',
                    destroy: './inventory/api/itempricing/delete'
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