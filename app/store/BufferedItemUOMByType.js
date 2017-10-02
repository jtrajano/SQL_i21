Ext.define('Inventory.store.BufferedItemUOMByType', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbuffereditemuombytype',

    // requires: [
    //     'Inventory.model.Category'
    // ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: Ext.create('Ext.data.Model', {
                idProperty: 'id',
                fields: [
                    { name: 'intUnitMeasureId', type: 'int' },
                    { name: 'strUnitMeasure', type: 'string' },
                    { name: 'strUnitType', type: 'string' },
                    { name: 'strSymbol', type: 'string' }
                ]
            }),
            storeId: 'BufferedItemUOMByType',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/item/getitemuomsbytype'
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