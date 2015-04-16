/**
 * Created by LZabala on 10/1/2014.
 */
Ext.define('Inventory.store.BuildAssembly', {
    extend: 'Ext.data.Store',
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
                    read: '../Inventory/api/BuildAssembly/GetBuildAssemblies',
                    update: '../Inventory/api/BuildAssembly/PutBuildAssemblies',
                    create: '../Inventory/api/BuildAssembly/PostBuildAssemblies',
                    destroy: '../Inventory/api/BuildAssembly/DeleteBuildAssemblies'
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