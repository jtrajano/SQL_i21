Ext.define('Inventory.view.BundleViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icbundle',

    requires: [
        'Inventory.store.BufferedCompactItem',
        'Inventory.store.BufferedManufacturer',
        'Inventory.store.BufferedCategory',
        'Inventory.store.BufferedItemUnitMeasure',
        'Inventory.store.BufferedUnitMeasure',
        'Inventory.store.BufferedBrand',
        'Inventory.store.BufferedCommodity',
        'Inventory.store.BufferedCategory'
    ],

    stores: {
        bundleTypes: {
            autoLoad: true,
            data: [
                {
                    strBundleType: 'Kit'
                },
                {
                    strBundleType: 'Option'
                },
                {
                    strBundleType: 'Substitute'
                }
            ],
            fields: [
                {
                    name: 'strBundleType'
                }
            ]
        },
        manufacturer: {
            type: 'icbufferedmanufacturer'
        },
        brand: {
            type: 'icbufferedbrand'
        },
        itemStatuses: {
            autoLoad: true,
            data: [
                {
                    strStatus: 'Active'
                },
                {
                    strStatus: 'Phased Out'
                },
                {
                    strStatus: 'Discontinued'
                }
            ],
            fields: [
                {
                    name: 'strStatus'
                }
            ]
        },
        itemCategory: {
            type: 'icbufferedcategory',
            proxy: {
                extraParams: {
                    include: 'tblICCategoryUOMs.tblICUnitMeasure, tblICCategoryAccounts.tblGLAccount, tblICCategoryAccounts.tblGLAccountCategory'
                },
                type: 'rest',
                api: {
                    read: './Inventory/api/Category/Search'
                },
                reader: {
                    type: 'json',
                    rootProperty: 'data',
                    messageProperty: 'message'
                }
            }
        },

        uomUnitMeasure: {
            type: 'icbuffereduom'
        },

        commodity: {
            type: 'icbufferedcommodity',
            proxy: {
                extraParams: {
                    include: 'tblICCommodityUnitMeasures.tblICUnitMeasure, tblICCommodityAccounts.tblGLAccount, tblICCommodityAccounts.tblGLAccountCategory'
                },
                type: 'rest',
                api: {
                    read: './Inventory/api/Commodity/Search'
                },
                reader: {
                    type: 'json',
                    rootProperty: 'data',
                    messageProperty: 'message'
                }
            }
        },

        bundleItem: {
            type: 'icbufferedcompactitem'
        },
        
        bundleUOM: {
            type: 'icbuffereditemunitmeasure'
        }
    },    

    formulas: {
        isSubstituteBundleType: function (get){
            return get('current.strBundleType') == 'Substitute';
        },

        isKitType: function (get){
            return get('current.strBundleType') == 'Kit';
        },

        isOptionType: function (get){
            return get('current.strBundleType') == 'Option';
        },

        readOnlyOnKitType: function (get){
            return get('current.strBundleType') == 'Kit';
        }
        

    }

});