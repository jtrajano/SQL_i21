/**
 * Created by LZabala on 10/29/2014.
 */
Ext.define('Inventory.store.BufferedUnitMeasure', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseBufferedStore',
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
                extraParams: { include: 'tblICUnitMeasureConversions.StockUnitMeasure, vyuICGetUOMConversions' },
                type: 'rest',
                api: {
                    read: './inventory/api/unitmeasure/search'
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
