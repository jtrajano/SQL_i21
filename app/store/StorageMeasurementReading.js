/**
 * Created by LZabala on 10/1/2015.
 */

Ext.define('Inventory.store.StorageMeasurementReading', {
    extend: 'Ext.data.Store',
    alias: 'store.icstoragemeasurementreading',

    requires: [
        'Inventory.model.StorageMeasurementReading'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.StorageMeasurementReading',
            storeId: 'StorageMeasurementReading',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/storagemeasurementreading/get',
                    update: './inventory/api/storagemeasurementreading/put',
                    create: './inventory/api/storagemeasurementreading/post',
                    destroy: './inventory/api/storagemeasurementreading/delete'
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