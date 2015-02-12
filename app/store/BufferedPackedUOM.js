/**
 * Created by LZabala on 2/9/2015.
 */
Ext.define('Inventory.store.BufferedPackedUOM', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbufferedpackeduom',

    requires: [
        'Inventory.model.PackedUOM'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.PackedUOM',
            storeId: 'BufferedPackedUOM',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            defaultFilters: [{
                column: 'strUnitType',
                value: 'Packed'
            }],
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/UnitMeasure/GetPackedUOMs'
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