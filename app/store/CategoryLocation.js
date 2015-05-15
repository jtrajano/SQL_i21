/**
 * Created by LZabala on 11/3/2014.
 */
Ext.define('Inventory.store.CategoryLocation', {
    extend: 'Ext.data.Store',
    alias: 'store.iccategorylocation',

    requires: [
        'Inventory.model.CategoryLocation'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.CategoryLocation',
            storeId: 'CategoryLocation',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/CategoryLocation/Get',
                    update: '../Inventory/api/CategoryLocation/Put',
                    create: '../Inventory/api/CategoryLocation/Post',
                    destroy: '../Inventory/api/CategoryLocation/Delete'
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