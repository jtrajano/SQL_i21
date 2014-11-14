/*
 * File: app/view/FactoryUnitTypeViewModel.js
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

Ext.define('Inventory.view.FactoryUnitTypeViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.factoryunittype',

    requires: [
        'Inventory.store.BufferedUnitMeasure'
    ],

    stores: {
        internalCodes: {
            data: [
                {
                    strInternalCode: 'PROD_STAGING'
                },
                {
                    strInternalCode: 'STAGING'
                },
                {
                    strInternalCode: 'STORAGE'
                },
                {
                    strInternalCode: 'WH_AISLE'
                },
                {
                    strInternalCode: 'WH_ASN_LOCATION'
                },
                {
                    strInternalCode: 'WH_BUILDING'
                },
                {
                    strInternalCode: 'WH_BULK'
                },
                {
                    strInternalCode: 'WH_CASE_PICK'
                },
                {
                    strInternalCode: 'WH_DOCK_DOOR'
                },
                {
                    strInternalCode: 'WH_FG_STORAGE'
                },
                {
                    strInternalCode: 'WH_FLOOR_RESERVE'
                },
                {
                    strInternalCode: 'WH_INVOICE_LOCATION'
                },
                {
                    strInternalCode: 'WH_KIT_CONSTRUCTION'
                },
                {
                    strInternalCode: 'WH_RACK_RESERVE'
                },
                {
                    strInternalCode: 'WH_RESERVED_BY_SYSTEM'
                },
                {
                    strInternalCode: 'WH_RESTRICTED'
                },
                {
                    strInternalCode: 'WH_RM_STORAGE'
                },
                {
                    strInternalCode: 'WH_ROOM'
                },
                {
                    strInternalCode: 'WH_Staging'
                },
                {
                    strInternalCode: 'WH_TRANSPORT'
                }
            ],
            fields: [
                {
                    name: 'strInternalCode'
                }
            ]
        },
        capacityUOM: {
            type: 'inventorybuffereduom'
        },
        dimensionUOM: {
            type: 'inventorybuffereduom'
        }
    }

});