Ext.define('Inventory.view.CategoryViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.iccategory',

    requires: [
        'Inventory.store.BufferedUnitMeasure',
        'Inventory.store.BufferedCompactItem',
        'Inventory.store.BufferedLineOfBusiness',
        'Inventory.store.BufferedCategoryLocation',
        'GeneralLedger.store.BufAccountId',
        'AccountsPayable.store.VendorBuffered',
        'i21.store.CompanyLocationBuffered',
        'Inventory.store.Class',
        'Inventory.store.Family',
        'GeneralLedger.store.BufAccountCategory'
    ],

    stores: {
        linesOfBusiness: {
            type: 'icbufferedlineofbusiness'
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
        unitMeasures:{
            type: 'icbuffereduom'
        },
        materialItem:{
            type: 'icbufferedcompactitem'
        },
        freightItem:{
            type: 'icbufferedcompactitem'
        },
        glAccount: {
            type: 'glbufaccountid'
        },
        location: {
            type: 'icbufferedcategorylocation'
        },
        vendorSellClass: {
            type: 'storeclass'
        },
        vendorOrderClass: {
            type: 'storeclass'
        },
        vendorFamily: {
            type: 'storefamily'
        },
        vendor: {
            type: 'vendorbuffered'
        }
    },

    formulas: {
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