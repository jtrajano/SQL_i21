Ext.define('Inventory.view.BuildAssemblyBlendViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icbuildassemblyblend',

    requires: [
        'Inventory.store.BufferedAssemblyItem',
        'Inventory.store.BufferedItemUnitMeasure',
        'Inventory.store.BufferedItemStockUOMView',
        'i21.store.CompanyLocationBuffered',
        'i21.store.CompanyLocationSubLocationBuffered'
    ],

    stores: {
        item: {
            type: 'icbufferedassemblyitem',
            proxy: {
                extraParams: {
                    include: 'tblICItemAssemblies.vyuICGetAssemblyItem'
                },
                type: 'rest',
                api: {
                    read: '../Inventory/api/Item/SearchAssemblyItems'
                },
                reader: {
                    type: 'json',
                    rootProperty: 'data',
                    messageProperty: 'message'
                }
            }
        },
        itemUOM:{
            type: 'icbuffereditemunitmeasure'
        },
        location:{
            type: 'companylocationbuffered'
        },
        subLocation: {
            type: 'smcompanylocationsublocationbuffered'
        },
        itemSubLocation: {
            type: 'smcompanylocationsublocationbuffered'
        },
        stockUOM: {
            type: 'icbuffereditemstockuomview'
        },
        stockUOMList: {
            autoLoad: true,
            type: 'icbuffereditemstockuomview'
        }
    },

    formulas: {
        getPostButtonText: function(get) {
            if (get('current.ysnPosted')) {
                return 'UnPost';
            }
            else {
                return 'Post';
            }
        },
        getPostButtonIcon: function(get) {
            if (get('current.ysnPosted')) {
                return 'large-unpost';
            }
            else {
                return 'large-post';
            }
        }
    }

});