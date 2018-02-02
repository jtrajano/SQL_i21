/**
 * Created by LZabala on 10/28/2014.
 */
Ext.define('Inventory.store.CompactItem', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    alias: 'store.iccompactitem',

    requires: [
        'Inventory.model.CompactItem'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.CompactItem',
            storeId: 'CompactItem',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/item/searchcompactitems'
                },
                reader: {
                    type: 'json',
                    rootProperty: 'data',
                    messageProperty: 'message'
                }
            }
        }, cfg)]);
    }
});