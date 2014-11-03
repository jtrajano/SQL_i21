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
        'GeneralLedger.store.BufAccountId'
    ],

    stores: {
        linesOfBusiness: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Agronomy'
                },{
                    strDescription: 'Feed'
                },{
                    strDescription: 'Petroleum'
                },{
                    strDescription: 'Retail'
                },{
                    strDescription: 'Grain'
                },{
                    strDescription: 'Oil & Grease'
                }
            ],
            fields: {
                name: 'strDescription'
            }
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
        unitMeasures:{
            type: 'inventorybuffereduom'
        },
        materialItem:{
            type: 'inventorybufferedcompactitem'
        },
        freightItem:{
            type: 'inventorybufferedcompactitem'
        },
        glAccount: {
            type: 'bufAccountid'
        }
    }

});