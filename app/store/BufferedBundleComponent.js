/**
 * Created by LZabala on 10/15/2015.
 */
Ext.define('Inventory.store.BufferedBundleComponent', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbufferedbundlecomponent',

    requires: [
        'Inventory.model.BundleComponent'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.BundleComponent',
            storeId: 'BufferedBundleComponent',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Item/SearchBundleComponents'
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