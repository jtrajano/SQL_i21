/**
 * Created by rnkumashi on 22-09-2014.
 */

Ext.define('Inventory.store.UnitMeasure', {
    extend: 'Ext.data.Store',
    alias: 'store.inventoryuom',

    requires: [
        'Inventory.model.UnitMeasure'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.UnitMeasure',
            storeId: 'UnitMeasure',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/UnitMeasure/GetUnitMeasures',
                    update: '../Inventory/api/UnitMeasure/PutUnitMeasures',
                    create: '../Inventory/api/UnitMeasure/PostUnitMeasures',
                    destroy: '../Inventory/api/UnitMeasure/DeleteUnitMeasures'
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
