Ext.define('Inventory.view.CategoryViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.iccategory',

    requires: [
        'Inventory.store.BufferedUnitMeasure',
        'Inventory.store.BufferedCompactItem',
        //'Inventory.store.BufferedLineOfBusiness',
        'Inventory.store.BufferedCategoryLocation',
        'Inventory.store.BufferedCategoryUOM',
        'EntityManagement.store.VendorBuffered',
        'i21.store.CompanyLocationBuffered',
        'i21.store.TaxClassBuffered',
        'Store.store.SubCategoryBuffered',
        'GeneralLedger.store.BufAccountCategoryGroup',
        'i21.store.LineOfBusinessBuffered'
    ],

    stores: {
        inventoryTypes: {
            autoLoad: true,
            data: [
                {
                    strType: 'Bundle'
                },
                {
                    strType: 'Inventory'
                },
                {
                    strType: 'Kit'
                },
                {
                    strType: 'Finished Good'
                },
                {
                    strType: 'Non-Inventory'
                },
                {
                    strType: 'Other Charge'
                },
                {
                    strType: 'Raw Material'
                },
                {
                    strType: 'Service'
                },
                {
                    strType: 'Software'
                }
                ,
                {
                    strType: 'Comment'
                }
            ],
            fields: [
                {
                    name: 'strType'
                }
            ]
        },
        linesOfBusiness: {
            //type: 'icbufferedlineofbusiness'
            type: 'smlineofbusinessbuffered'
        },
        costingMethods: {
            autoLoad: true,
            data: [
                {
                    intCostingMethodId: '1',
                    strDescription: 'AVG'
                },
                {
                    intCostingMethodId: '2',
                    strDescription: 'FIFO'
                },
                {
                    intCostingMethodId: '3',
                    strDescription: 'LIFO'
                }
            ],
            fields: [
                {
                    name: 'intCostingMethodId',
                    type: 'int'
                },
                {
                    name: 'strDescription'
                }
            ]
        },
        materialFees: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'No'
                },{
                    strDescription: 'Yes'
                },{
                    strDescription: 'Unit'
                }
            ],
            fields: {
                name: 'strDescription'
            }
        },

        inventoryTrackings: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Item Level'
                },
                {
                    strDescription: 'Category Level'
                },
                {
                    strDescription: 'Lot Level'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },
        standardUOM: {
            type: 'icbufferedcategoryuom'
        },
        uomUnitMeasure:{
            type: 'icbuffereduom'
        },
        uomConversion: {
            autoLoad: true,
            type: 'icbuffereduom'
        },
        unitMeasures:{
            type: 'icbuffereduom'
        },
        materialItem:{
            type: 'icbufferedcompactitem'
        },
        freightItem:{
            type: 'icbufferedcompactitem'
        },
        accountCategory: {
            type: 'glbufaccountcategorygroup'
        },
        accountCategoryList: {
            autoLoad: true,
            type: 'glbufaccountcategorygroup'
        },
        location: {
            type: 'icbufferedcategorylocation'
        },
        vendorSellClass: {
            type: 'stsubcategorybuffered'
        },
        vendorOrderClass: {
            type: 'stsubcategorybuffered'
        },
        vendorFamily: {
            type: 'stsubcategorybuffered'
        },
        vendor: {
            type: 'emvendorbuffered'
        },
        taxClass: {
            type: 'smtaxclassbuffered'
        }
    },

    formulas: {
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
        },

        checkMaterialFee: function(get){
            if (iRely.Functions.isEmpty(get('current.strMaterialFee')) || get('current.strMaterialFee') === 'No'){
                this.data.current.set('intMaterialItemId', null);
                return true;
            }
            else{
                return false;
            }
        },
        checkAutoCalculateFreight: function(get){
            if (!get('current.ysnAutoCalculateFreight')){
                this.data.current.set('intFreightItemId', null);
                return true;
            }
            else{
                return false;
            }
        }
    }

});