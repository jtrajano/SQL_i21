/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedEquipmentLength', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.inventorybufferedequipmentlength',

    requires: [
        'Inventory.model.EquipmentLength'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.EquipmentLength',
            storeId: 'BufferedEquipmentLength',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/EquipmentLength/GetEquipmentLengths'
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