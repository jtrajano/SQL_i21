/*
 * File: app/view/InventoryUOMViewModel.js
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

Ext.define('Inventory.view.InventoryUOMViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icinventoryuom',

    requires: [
        'Inventory.store.BufferedUnitMeasure'
    ],

    stores: {
        unitTypes: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Area'
                },{
                    strDescription: 'Length'
                },{
                    strDescription: 'Quantity'
                },{
                    strDescription: 'Time'
                },{
                    strDescription: 'Volume'
                },{
                    strDescription: 'Weight'
                },{
                    strDescription: 'Packed'
                }
            ],
            fields: {
                name: 'strDescription'
            }
        },
        unitMeasure: {
            type: 'icbuffereduom',
            proxy: {
                type: 'rest',
                api: {
                    read: '{getReadUOMApi}'
                },
                reader: {
                    type: 'json',
                    rootProperty: 'data',
                    messageProperty: 'message'
                }
            }
        }
    },

    formulas: {
        getReadUOMApi: function(get) {
            switch(get('current.strUnitType')){
                case 'Area':
                case 'Length':
                    return '../Inventory/api/UnitMeasure/GetAreaLengthUOMs';
                    break;
                case 'Quantity':
                case 'Volume':
                case 'Weight':
                case 'Packed':
                    return '../Inventory/api/UnitMeasure/GetQuantityVolumeWeightPackedAreaUOMs';
                    break;
                case 'Time':
                    return '../Inventory/api/UnitMeasure/GetTimeUOMs';
                    break;
            };
        }
    }

});