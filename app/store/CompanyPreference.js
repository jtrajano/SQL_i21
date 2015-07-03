/**
 * Created by LZabala on 7/3/2015.
 */
Ext.define('Inventory.store.CompanyPreference', {
    extend: 'Ext.data.Store',
    alias: 'store.iccompanypreference',

    requires: [
        'Inventory.model.CompanyPreference'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.CompanyPreference',
            storeId: 'CompanyPreference',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/CompanyPreference/Get',
                    update: '../Inventory/api/CompanyPreference/Put',
                    create: '../Inventory/api/CompanyPreference/Post',
                    destroy: '../Inventory/api/CompanyPreference/Delete'
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