/*
 * File: app/view/InventoryReceiptViewModel.js
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

Ext.define('Inventory.view.InventoryReceiptViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.inventoryreceipt',

    requires: [
        'Inventory.store.BufferedCompactItem',
        'Inventory.store.BufferedItemUnitMeasure',
        'Inventory.store.BufferedPackType',
        'AccountsPayable.store.VendorBuffered',
        'i21.store.CompanyLocationBuffered',
        'i21.store.CountryBuffered',
        'i21.store.CurrencyBuffered',
        'i21.store.FreightTermsBuffered',
    ],

    stores: {
        receiptTypes: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Contract'
                },{
                    strDescription: 'Purchase Order'
                },{
                    strDescription: 'Transfer Order'
                },{
                    strDescription: 'Direct'
                }
            ],
            fields: {
                name: 'strDescription'
            }
        },
        allocateFreights: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Weight'
                },{
                    strDescription: 'Cost'
                },{
                    strDescription: 'No'
                }
            ],
            fields: {
                name: 'strDescription'
            }
        },
        freightBilledBys: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Vendor'
                },{
                    strDescription: 'Outside Carrier'
                },{
                    strDescription: 'No'
                }
            ],
            fields: {
                name: 'strDescription'
            }
        },
        calculationBasis: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Per Unit'
                },{
                    strDescription: 'Per Ton'
                },{
                    strDescription: 'Per Miles'
                },{
                    strDescription: 'Flat Rate'
                }
            ],
            fields: {
                name: 'strDescription'
            }
        },
        sealStatuses: {
            autoLoad: true,
            data: [
                {
                    strDescription: '01 - Intact'
                },{
                    strDescription: '02 - Broken'
                },{
                    strDescription: '03 - Missing'
                },{
                    strDescription: '04 - Replaced'
                }
            ],
            fields: {
                name: 'strDescription'
            }
        },
        items: {
            type: 'inventorybufferedcompactitem'
        },
        itemUOM: {
            type: 'inventorybuffereditemunitmeasure'
        },
        itemPackType: {
            type: 'inventorybufferedpacktype'
        },
        vendor: {
            type: 'vendorbuffered'
        },
        location: {
            type: 'companylocationbuffered'
        },
        currency: {
            type: 'currencybuffered'
        },
        country: {
            type: 'countrybuffered'
        },
        freightTerm: {
            type: 'FreightTermsBuffered'
        }
    }

});