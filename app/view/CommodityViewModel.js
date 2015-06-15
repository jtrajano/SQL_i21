/*
 * File: app/view/CommodityViewModel.js
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

Ext.define('Inventory.view.CommodityViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.iccommodity',

    requires: [
        'Inventory.store.BufferedPatronageCategory',
        'Inventory.store.BufferedUnitMeasure',
        'Inventory.store.BufferedStorageType',
        'GeneralLedger.store.BufAccountId',
        'GeneralLedger.store.BufAccountCategoryGroup',
        'i21.store.CompanyLocationBuffered',
        'RiskManagement.store.FutureMarketBuffered'
    ],

    stores: {
        states: {
            autoLoad: true,
            data: [
                { strState: 'Alabama', strCode: 'AL' },
                { strState: 'Alaska', strCode: 'AK' },
                { strState: 'Arizona', strCode: 'AZ' },
                { strState: 'Arkansas', strCode: 'AR' },
                { strState: 'California', strCode: 'CA' },
                { strState: 'Colorado', strCode: 'CO' },
                { strState: 'Connecticut', strCode: 'CT' },
                { strState: 'Delaware', strCode: 'DE' },
                { strState: 'Florida', strCode: 'FL' },
                { strState: 'Georgia', strCode: 'GA' },
                { strState: 'Hawaii', strCode: 'HI' },
                { strState: 'Idaho', strCode: 'ID' },
                { strState: 'Illinois', strCode: 'IL' },
                { strState: 'Indiana', strCode: 'IN' },
                { strState: 'Iowa', strCode: 'IA' },
                { strState: 'Kansas', strCode: 'KS' },
                { strState: 'Kentucky', strCode: 'KY' },
                { strState: 'Louisiana', strCode: 'LA' },
                { strState: 'Maine', strCode: 'ME' },
                { strState: 'Maryland', strCode: 'MD' },
                { strState: 'Massachusetts', strCode: 'MA' },
                { strState: 'Michigan', strCode: 'MI' },
                { strState: 'Minnesota', strCode: 'MN' },
                { strState: 'Mississippi', strCode: 'MS' },
                { strState: 'Missouri', strCode: 'MO' },
                { strState: 'Montana', strCode: 'MT' },
                { strState: 'Nebraska', strCode: 'NE' },
                { strState: 'Nevada', strCode: 'NV' },
                { strState: 'New Hampshire', strCode: 'NH' },
                { strState: 'New Jersey', strCode: 'NJ' },
                { strState: 'New Mexico', strCode: 'NM' },
                { strState: 'New York', strCode: 'NY' },
                { strState: 'North Carolina', strCode: 'NC' },
                { strState: 'North Dakota', strCode: 'ND' },
                { strState: 'Ohio', strCode: 'OH' },
                { strState: 'Oklahoma', strCode: 'OK' },
                { strState: 'Oregon', strCode: 'OR' },
                { strState: 'Pennsylvania', strCode: 'PA' },
                { strState: 'Rhode Island', strCode: 'RI' },
                { strState: 'South Carolina', strCode: 'SC' },
                { strState: 'South Dakota', strCode: 'SD' },
                { strState: 'Tennessee', strCode: 'TN' },
                { strState: 'Texas', strCode: 'TX' },
                { strState: 'Utah', strCode: 'UT' },
                { strState: 'Vermont', strCode: 'VT' },
                { strState: 'Virginia', strCode: 'VA' },
                { strState: 'Washington', strCode: 'WA' },
                { strState: 'West Virginia', strCode: 'WV' },
                { strState: 'Wisconsin', strCode: 'WI' },
                { strState: 'Wyoming', strCode: 'WY' }
            ],
            fields: [
                {
                    name: 'strState'
                },
                {
                    name: 'strCode'
                }
            ]
        },
        futureMarket: {
            type: 'rkfuturemarketbuffered'
        },
        accountCategory: {
            type: 'glbufaccountcategorygroup'
        },
        patronageCategory: {
            type: 'icbufferedpatronagecategory'
        },
        directPatronageCategory: {
            type: 'icbufferedpatronagecategory'
        },
        unitMeasure: {
            type: 'icbuffereduom'
        },
        uomConversion: {
            autoLoad: true,
            type: 'icbuffereduom'
        },
        glAccount: {
            type: 'glbufaccountid'
        },
        location: {
            type: 'companylocationbuffered'
        },
        autoScaleDist: {
            type: 'icbufferedstoragetype'
        }
    }

});