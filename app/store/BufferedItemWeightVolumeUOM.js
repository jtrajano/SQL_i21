/**
 * Created by LZabala on 7/22/2015.
 */
Ext.define('Inventory.store.BufferedItemWeightVolumeUOM', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseBufferedStore',
    alias: 'store.icbuffereditemweightvolumeuom',

    requires: [
        'Inventory.model.ItemUOM'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ItemUOM',
            storeId: 'BufferedItemWeightVolumeUOM',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/itemuom/searchweightvolumeuoms'
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