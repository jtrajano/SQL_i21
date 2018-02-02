/**
 * Created by LZabala on 10/1/2014.
 */
Ext.define('Inventory.store.BuildAssembly', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    alias: 'store.icbuildassembly',

    requires: [
        'Inventory.model.BuildAssembly'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.BuildAssembly',
            storeId: 'BuildAssembly',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/buildassembly/get',
                    update: './inventory/api/buildassembly/put',
                    create: './inventory/api/buildassembly/post',
                    destroy: './inventory/api/buildassembly/delete'
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