/**
 * Created by LZabala on 1/8/2015.
 */
Ext.define('Inventory.store.BufferedItemFactoryManufacturingCell', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    alias: 'store.icbuffereditemfactorymanufacturingcell',

    requires: [
        'Inventory.model.CompactItemFactoryManufacturingCell'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.CompactItemFactoryManufacturingCell',
            storeId: 'BufferedItemFactoryManufacturingCell',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/itemfactory/searchitemfactorymanufacturingcells'
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