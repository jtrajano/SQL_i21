/**
 * Created by LZabala on 10/1/2014.
 */
Ext.define('Inventory.store.Adjustment', {
    extend: 'Ext.data.Store',
    alias: 'store.icadjustment',

    requires: [
        'Inventory.model.Adjustment'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.Adjustment',
            storeId: 'Adjustment',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Adjustment/GetAdjustments',
                    update: '../Inventory/api/Adjustment/PutAdjustments',
                    create: '../Inventory/api/Adjustment/PostAdjustments',
                    destroy: '../Inventory/api/Adjustment/DeleteAdjustments'
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