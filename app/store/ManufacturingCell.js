/**
 * Created by LZabala on 10/1/2014.
 */
Ext.define('Inventory.store.ManufacturingCell', {
    extend: 'Ext.data.Store',
    alias: 'store.icmanufacturingcell',

    requires: [
        'Inventory.model.ManufacturingCell'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ManufacturingCell',
            storeId: 'ManufacturingCell',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/manufacturingcell/getmanufacturingcells',
                    update: './inventory/api/manufacturingcell/putmanufacturingcells',
                    create: './inventory/api/manufacturingcell/postmanufacturingcells',
                    destroy: './inventory/api/manufacturingcell/deletemanufacturingcells'
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