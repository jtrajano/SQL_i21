/**
 * Created by LZabala on 10/1/2014.
 */
Ext.define('Inventory.store.MaterialNMFC', {
    extend: 'Ext.data.Store',
    alias: 'store.icmaterialnmfc',

    requires: [
        'Inventory.model.MaterialNMFC'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.MaterialNMFC',
            storeId: 'MaterialNMFC',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/materialnmfc/getmaterialnmfcs',
                    update: './inventory/api/materialnmfc/putmaterialnmfcs',
                    create: './inventory/api/materialnmfc/postmaterialnmfcs',
                    destroy: './inventory/api/materialnmfc/deletematerialnmfcs'
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