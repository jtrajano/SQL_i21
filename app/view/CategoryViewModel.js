/*
 * File: app/view/CategoryViewModel.js
 *
 * This file was generated by Sencha Architect version 3.1.0.
 * http://www.sencha.com/products/architect/
 *
 * This file requires use of the Ext JS 5.0.x library, under independent license.
 * License of Sencha Architect does not include license for Ext JS 5.0.x. For more
 * details see http://www.sencha.com/license or contact license@sencha.com.
 *
 * This file will be auto-generated each and everytime you save your project.
 *
 * Do NOT hand edit this file.
 */

Ext.define('Inventory.view.CategoryViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.category',

    requires: [
        'Inventory.store.BufferedUnitMeasure',
        'Inventory.store.BufferedCompactItem',
        'Inventory.store.BufferedLineOfBusiness',
        'GeneralLedger.store.BufAccountId',
        'AccountsPayable.store.VendorBuffered',
        'i21.store.CompanyLocationBuffered',
        'Inventory.store.Class',
        'Inventory.store.Family'
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
        accountDescriptions: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Sales'
                },
                {
                    strDescription: 'Purchase'
                },
                {
                    strDescription: 'Variance'
                },
                {
                    strDescription: 'COGS'
                },
                {
                    strDescription: 'Expenses'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },
        inventoryTrackings: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Item Level'
                },
                {
                    strDescription: 'Category Level'
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
            type: 'bufAccountid'
        },
        location: {
            type: 'companylocationbuffered'
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