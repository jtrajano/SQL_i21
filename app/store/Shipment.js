/**
 * Created by LZabala on 10/1/2014.
 */
Ext.define('Inventory.store.Shipment', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    alias: 'store.icshipment',

    requires: [
        'Inventory.model.Shipment'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.Shipment',
            storeId: 'Shipment',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/inventoryshipment/get',
                    update: './inventory/api/inventoryshipment/put',
                    create: './inventory/api/inventoryshipment/post',
                    destroy: './inventory/api/inventoryshipment/delete'
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