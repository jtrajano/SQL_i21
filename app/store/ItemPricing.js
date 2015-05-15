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
                    read: '../Inventory/api/ItemPricing/Get',
                    update: '../Inventory/api/ItemPricing/Put',
                    create: '../Inventory/api/ItemPricing/Post',
                    destroy: '../Inventory/api/ItemPricing/Delete'
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