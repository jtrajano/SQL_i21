/**
 * Created by rnkumashi on 19-09-2014.
 */
Ext.define('Inventory.store.FactoryUnitType', {
    extend: 'Ext.data.Store',

    requires: [
        'Inventory.model.FactoryUnitType'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.FactoryUnitType',
            storeId: 'FactoryUnitType',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/StorageUnitType/GetStorageUnitTypes',
                    update: '../Inventory/api/StorageUnitType/PutStorageUnitTypes',
                    create: '../Inventory/api/StorageUnitType/PostStorageUnitTypes',
                    destroy: '../Inventory/api/StorageUnitType/DeleteStorageUnitTypes'
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
