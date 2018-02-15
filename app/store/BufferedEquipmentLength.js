/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedEquipmentLength', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseBufferedStore',
    alias: 'store.icbufferedequipmentlength',

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
                    read: './inventory/api/equipmentlength/search'
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