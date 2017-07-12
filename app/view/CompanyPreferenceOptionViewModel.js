/*
 * File: app/view/CompanyPreferenceOptionViewModel.js
 *
 * This file was generated by Sencha Architect version 3.2.0.
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

Ext.define('Inventory.view.CompanyPreferenceOptionViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.iccompanypreferenceoption',

    stores: {
       /* inheritSetups: {
            data: [
                { intInheritSetup: 1, strInheritSetup: 'Category' },
                { intInheritSetup: 2, strInheritSetup: 'Commodity' }
            ],
            fields: [
                {
                    name: 'intInheritSetup'
                },
                {
                    name: 'strInheritSetup'
                }
            ]
        },*/
        lotCondition: {
            data: [
                { strLotCondition: 'Sound/Full', intLotCondition: 1 },
                { strLotCondition: 'Slack', intLotCondition: 2 },
                { strLotCondition: 'Damaged', intLotCondition: 3 },
                { strLotCondition: 'Clean Wgt', intLotCondition: 4 }
            ],
            fields: {
                name: 'strLotCondition',
                name: 'intLotCondition'
            }
            
        },
        
        receiptOrderType: {
            data: [
                { strReceiptType: 'Purchase Contract', intReceiptType: 1 },
                { strReceiptType: 'Purchase Order', intReceiptType: 2 },
                { strReceiptType: 'Transfer Order', intReceiptType: 3 },
                { strReceiptType: 'Direct', intReceiptType: 4 }
            ],
            fields: {
                name: 'strReceiptType',
                name: 'intReceiptType'
            }
            
        },
        
         receiptSourceType: {
            data: [
                { strDescription: 'None', intReceiptSourceType: 0 },
                { strDescription: 'Scale', intReceiptSourceType: 1 },
                { strDescription: 'Inbound Shipment', intReceiptSourceType: 2 },
                { strDescription: 'Transport', intReceiptSourceType: 3 }
            ],
            fields: {
                name: 'strDescription',
                name: 'intReceiptSourceType'
            },  
        },
        
        shipmentOrderType: {
            data: [
                { strDescription: 'Sales Contract', intShipmentOrderType: 1 },
                { strDescription: 'Sales Order', intShipmentOrderType: 2 },
                { strDescription: 'Transfer Order', intShipmentOrderType: 3 },
                { strDescription: 'Direct', intShipmentOrderType: 4 }
            ],
            fields: {
                name: 'strDescription',
                name: 'intShipmentOrderType'
            } 
        },
        
        shipmentSourceType: {
            data: [
                { strDescription: 'None', intShipmentSourceType: 0 },
                { strDescription: 'Scale', intShipmentSourceType: 1 },
                { strDescription: 'Inbound Shipment', intShipmentSourceType: 2 },
                { strDescription: 'Pick Lot', intShipmentSourceType: 3 }
            ],
            fields: {
                name: 'strDescription',
                name: 'intShipmentSourceType'
            }
        },

        inventoryReceiptUnpostMode: {
            data: [
                { strDescription: 'Unpost all from the receipt.', strIRUnpostMode: 'Default' },
                { strDescription: 'Unpost the receipt and synchronize the contracts. Keep everything else, like stock quantities, as posted.', strIRUnpostMode: 'Force Purchase Contract Unpost' },
            ],
            fields: {
                name: 'strDescription',
                name: 'strIRUnpostMode'
            }
        },        
    },

     formulas: {
        
       setInitialDefaultValues: function(get) { 
            if (get('current.strLotCondition') === null ||  get('current.strLotCondition') === '') {
               this.data.current.set('strLotCondition', 'Sound/Full');
            }
            
            if(get('current.strReceiptType') === null || get('current.strReceiptType') === '') {
                this.data.current.set('strReceiptType', 'Purchase Contract');
            }
            
            if(get('current.intShipmentOrderType') === null || get('current.intShipmentOrderType') === 0) {
                this.data.current.set('intShipmentOrderType', 1);
            }
           
           if(get('current.intReceiptSourceType') === null) {
                this.data.current.set('intReceiptSourceType', 0);
            }
           
           if(get('current.intShipmentSourceType') === null) {
                this.data.current.set('intShipmentSourceType', 0);
            }
            
           if(get('current.intInheritSetup') === null || get('current.intInheritSetup') === 0) {
                this.data.current.set('intInheritSetup', 1);
            }
           
           if(get('current.intSort') === null) {
                this.data.current.set('intSort', 0);
            }
        }
    }
});