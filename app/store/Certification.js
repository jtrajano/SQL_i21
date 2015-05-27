/**
 * Created by LZabala on 10/22/2014.
 */
Ext.define('Inventory.store.Certification', {
    extend: 'Ext.data.Store',
    alias: 'store.iccertification',

    requires: [
        'Inventory.model.Certification'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.Certification',
            storeId: 'Certification',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Certification/Get',
                    update: '../Inventory/api/Certification/Put',
                    create: '../Inventory/api/Certification/Post',
                    destroy: '../Inventory/api/Certification/Delete'
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