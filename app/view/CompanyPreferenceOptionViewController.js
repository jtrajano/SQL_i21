/*
 * File: app/view/CompanyPreferenceOptionViewController.js
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

Ext.define('Inventory.view.CompanyPreferenceOptionViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.iccompanypreferenceoption',
    requires: [
        "Inventory.controller.Inventory",
        "i21.controller.ModuleManager"
    ],

    config: {
        binding: {
          /*  cboInheritSetup: {
                value: '{current.intInheritSetup}',
                store: '{inheritSetups}'
            },*/
            
            cboReceiptOrderType: {
                value: '{current.strReceiptType}',
                store: '{receiptOrderType}'
            },
            
            cboReceiptSourceType: {
                value: '{current.intReceiptSourceType}',
                store: '{receiptSourceType}'
            },
            
            cboShipmentOrderType: {
                value: '{current.intShipmentOrderType}',
                store: '{shipmentOrderType}'
            },
            
            cboShipmentSourceType: {
                value: '{current.intShipmentSourceType}',
                store: '{shipmentSourceType}'
            },
            
            cboLotCondition: {
                value: '{current.strLotCondition}',
                store: '{lotCondition}'
            }, 

            cboIRUnpostMode: {
                value: '{current.strIRUnpostMode}',
                store: '{inventoryReceiptUnpostMode}'                
            }

        }
    },

    setupData: function() {
        var me = this,
            win = me.getView();

        me.data = Ext.create('iRely.data.Manager', {
            window: win,
            store: i21.ModuleMgr.Inventory.companyPreferenceStore
        });
        
        me.audit = Ext.create('iRely.audit.Manager', { window: win });
    }
});
