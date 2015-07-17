/*
 * File: app/view/ItemLocationViewModel.js
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

Ext.define('Inventory.view.ItemLocationViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icitemlocation',

    requires: [
        'i21.store.CompanyLocationBuffered',
        'i21.store.FreightTermsBuffered',
        'i21.store.CompanyLocationSubLocationBuffered',
        'EntityManagement.store.VendorBuffered',
        'EntityManagement.store.ShipViaBuffered',
        'Inventory.store.BufferedItemUnitMeasure',
        'Inventory.store.BufferedCountGroup',
        'Inventory.store.BufferedStorageLocation',
        'Inventory.store.BufferedItemUPC',
        'Store.store.SubCategoryBuffered',
        'Store.store.SubcategoryRegProdBuffered',
        'Store.store.PromotionSalesBuffered'
    ],

    stores: {

        location: {
            type: 'companylocationbuffered'
        },
        subLocation: {
            type: 'smcompanylocationsublocationbuffered'
        },
        vendor: {
            type: 'emvendorbuffered'
        },
        costingMethods: {
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
                    type: 'int',
                    name: 'intCostingMethodId'
                },
                {
                    name: 'strDescription'
                }
            ]
        },
        storageLocation: {
            type: 'icbufferedstoragelocation'
        },
        issueUOM: {
            type: 'icbuffereditemunitmeasure'
        },
        receiveUOM: {
            type: 'icbuffereditemunitmeasure'
        },
        family: {
            type: 'stsubcategorybuffered'
        },
        class: {
            type: 'stsubcategorybuffered'
        },
        productCode: {
            type: 'stsubcategoryregprodbuffered'
        },
        mixMatchCode: {
            type: 'stpromotionsalesbuffered'
        },
        itemUPC: {
            type: 'icbuffereditemupc'
        },

        freightTerm: {
            type: 'FreightTermsBuffered'
        },
        shipVia: {
            type: 'emshipviabuffered'
        },
        negativeInventory: {
            data: [
                {
                    intNegativeInventoryId: '1',
                    strDescription: 'Yes'
                },
                {
                    intNegativeInventoryId: '2',
                    strDescription: 'Yes with Auto Write-Off'
                },
                {
                    intNegativeInventoryId: '3',
                    strDescription: 'No'
                }
            ],
            fields: [
                {
                    type: 'int',
                    name: 'intNegativeInventoryId'
                },
                {
                    name: 'strDescription'
                }
            ]
        },
        counteds: {
            data: [
                {
                    strDescription: 'Counted'
                },
                {
                    strDescription: 'Not Counted'
                },
                {
                    strDescription: 'Obsolete'
                },
                {
                    strDescription: 'Blended'
                },
                {
                    strDescription: 'Automatic Blend'
                },
                {
                    strDescription: 'Special Order'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },
        countGroup: {
            type: 'icbufferedcountgroup'
        }
    }

});