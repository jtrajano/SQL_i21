/**
 * Created by LZabala on 10/29/2014.
 */
Ext.define('Inventory.store.BufferedUnitMeasure', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbuffereduom',

    requires: [
        'Inventory.model.UnitMeasure'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.UnitMeasure',
            storeId: 'BufferedUnitMeasure',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
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
