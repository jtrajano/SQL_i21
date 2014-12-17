/**
 * Created by LZabala on 10/28/2014.
 */
Ext.define('Inventory.store.CompactItem', {
    extend: 'Ext.data.Store',
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
                    read: '../Inventory/api/Item/GetCompactItems'
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