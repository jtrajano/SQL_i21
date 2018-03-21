Ext.define('Inventory.store.UnitMeasure', {
    extend: 'Ext.data.Store',
    alias: 'store.icuom',

    requires: [
        'Inventory.model.UnitMeasure',
        'Inventory.model.UnitMeasureConversion',
        'Ext.data.proxy.Rest',
        'Ext.data.reader.Json',
        'Ext.data.writer.Json'        
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
                    read: './inventory/api/unitmeasure/get',
                    update: './inventory/api/unitmeasure/put',
                    create: './inventory/api/unitmeasure/post',
                    destroy: './inventory/api/unitmeasure/delete'
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
