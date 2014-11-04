/**
 * Created by LZabala on 11/4/2014.
 */
Ext.define('Inventory.store.Catalog', {
    extend: 'Ext.data.TreeStore',
    alias: 'store.inventorycatalog',

    requires: [
        'Inventory.model.Catalog'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.Catalog',
            storeId: 'Catalog',
            proxy: {
                type: 'ajax',
                api: {
                    read: '../Inventory/api/Catalog/GetCatalogsByParentId',
                    update: '../Inventory/api/Catalog/PutCatalogs',
                    create: '../Inventory/api/Catalog/PostCatalogs',
                    destroy: '../Inventory/api/Catalog/DeleteCatalogs'
                },
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8'
                },
                reader: {
                    type: 'json',
                    rootProperty: 'children'
                },
                writer: {
                    type: 'json',
                    allowSingle: false
                },
                listeners: {
                    nodebeforeappend: {
                        fn: me.onTreeStoreNodeBeforeAppend,
                        scope: me
                    }
                }
            }
        }, cfg)]);
    },

    onTreeStoreNodeBeforeAppend: function(nodeinterface, node, eOpts) {
        console.log('test');
    }
});