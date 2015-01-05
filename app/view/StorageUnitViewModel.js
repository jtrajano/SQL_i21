/*
 * File: app/view/StorageUnitViewModel.js
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

Ext.define('Inventory.view.StorageUnitViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icstorageunit',

    requires: [
        'Inventory.store.BufferedUnitMeasure',
        'Inventory.store.BufferedCategory',
        'Inventory.store.BufferedFactoryUnitType',
        'Inventory.store.BufferedCommodity',
        'Inventory.store.BufferedRestriction',
        'Inventory.store.BufferedMeasurement',
        'Inventory.store.BufferedReadingPoint',
        'i21.store.CompanyLocationBuffered',
    ],

    stores: {
        location: {
            type: 'companylocationbuffered'
        },
        batchSizeUOM: {
            type: 'icbuffereduom'
        },
        categoryAllowed: {
            type: 'icbufferedcategory'
        },
        storageUnitType: {
            type: 'icbufferedfactoryunittype'
        },
        commodity: {
            type: 'icbufferedcommodity'
        },
        restriction: {
            type: 'icbufferedrestriction'
        },
        measurement: {
            type: 'icbufferedmeasurement'
        },
        readingPoint: {
            type: 'icbufferedreadingpoint'
        }
    }

});