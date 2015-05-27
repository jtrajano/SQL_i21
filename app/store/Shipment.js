/**
 * Created by LZabala on 10/1/2014.
 */
Ext.define('Inventory.store.Shipment', {
    extend: 'Ext.data.Store',
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
                    read: '../Inventory/api/InventoryShipment/Get',
                    update: '../Inventory/api/InventoryShipment/Put',
                    create: '../Inventory/api/InventoryShipment/Post',
                    destroy: '../Inventory/api/InventoryShipment/Delete'
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