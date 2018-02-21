/**
 * Created by LZabala on 11/3/2014.
 */
Ext.define('Inventory.store.CategoryLocation', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
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
                    read: './inventory/api/categorylocation/getcategorylocation',
                    update: './inventory/api/categorylocation/put',
                    create: './inventory/api/categorylocation/post',
                    destroy: './inventory/api/categorylocation/delete'
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