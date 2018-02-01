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
        'Inventory.store.BufferedCategory',
        'Inventory.store.BufferedItemLocation',
        'Inventory.store.BufferedCommodity',
        'GeneralLedger.store.BufAccountCategoryGroup',
        'i21.store.CompanyLocationSubLocationBuffered',
        'i21.store.CompanyLocationPricingLevelBuffered',
        'i21.store.CurrencyBuffered'
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
        },

        accountCategory: {
            type: 'glbufaccountcategorygroup'
        },

        copyLocation: {
            type: 'icbuffereditemlocation'
        },

        subLocations: {
            type: 'smcompanylocationsublocationbuffered'
        },

        commodityList: {
            autoLoad: true,
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

        pricingLocation: {
            type: 'icbuffereditemlocation'
        },        

        pricingPricingMethods: {
            data: [
                {
                    strDescription: 'None'
                },
                {
                    strDescription: 'Fixed Dollar Amount'
                },
                {
                    strDescription: 'Markup Standard Cost'
                },
                {
                    strDescription: 'Percent of Margin'
                }
                // {
                //     strDescription: 'Markup Last Cost'
                // },
                // {
                //     strDescription: 'Markup Avg Cost'
                // }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },

        pricingLevelLocation: {
            type: 'icbuffereditemlocation'
        },      
        
        pricingLevel: {
            type: 'smcompanylocationpricinglevelbuffered'
        },
        
        pricingLevelUOM: {
            type: 'icbuffereditemunitmeasure'
        },

        pricingMethods: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'None'
                },
                {
                    strDescription: 'Fixed Dollar Amount'
                },
                {
                    strDescription: 'Markup Standard Cost'
                },
                {
                    strDescription: 'Percent of Margin'
                },
                {
                    strDescription: 'Discount Retail Price'
                },
                {
                    strDescription: 'MSRP Discount'
                },
                {
                    strDescription: 'Percent of Margin (MSRP)'
                }
                // {
                //     strDescription: 'Markup Last Cost'
                // },
                // {
                //     strDescription: 'Markup Avg Cost'
                // }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },        
        
        commissionsOn:{
            autoLoad: true,
            data: [
                {
                    strDescription: 'Percent'
                },{
                    strDescription: 'Units'
                },{
                    strDescription: 'Amount'
                },{
                    strDescription: 'Gross Profit'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },        

        currency: {
            type: 'currencybuffered'
        },

        specialPricingLocation: {
            type: 'icbuffereditemlocation'
        },
        
        promotionTypes:{
            autoLoad: true,
            data: [
                {
                    strDescription: 'Rebate'
                },{
                    strDescription: 'Discount'
                },{
                    strDescription: 'Vendor Discount'
                },{
                    strDescription: 'Terms Discount'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },

        specialPricingUOM: {
            type: 'icbuffereditemunitmeasure'
        },

        discountsBy:{
            autoLoad: true,
            data: [
                {
                    strDescription: 'Percent'
                },{
                    strDescription: 'Amount'
                },{
                    strDescription: 'Terms Rate'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },

        
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
        },

        accountCategoryFilter: function(get) {
            var category = get('grdGlAccounts.selection.strAccountCategory');
            switch(category) {
                case 'AP Clearing':
                case 'Inventory':
                case 'Work In Progress':
                case 'Inventory In-Transit':
                    return category;
                default:
                    return 'General|^|' + category;
            }
        }        

    }

});