/*
 * File: app/view/ItemPricingViewController.js
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

Ext.define('Inventory.view.ItemPricingViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icitempricing',

    config: {
        binding: {
            cboLocation: {
                value: '{current.intLocationId}',
                store: '{Location}'
            },
            cboUnitMeasure: {
                value: '{current.intItemUnitMeasureId}',
                store: '{itemUOM}',
                defaultFilters: [{
                    column: 'intItemId',
                    value: '{current.intItemId}'
                }]
            },
            txtUPC: '{current.strUPC}',
            txtSalePrice: '{current.dblSalePrice}',
            txtRetailPrice: '{current.dblRetailPrice}',
            txtWholesalePrice: '{current.dblWholesalePrice}',
            txtLargeVolumePrice: '{current.dblLargeVolumePrice}',
            txtMsrp: '{current.dblMSRPPrice}',
            cboPricingMethod: {
                value: '{current.strPricingMethod}',
                store: '{PricingMethods}'
            },
            txtAmountPercent: {
                value: '{current.dblAmountPercent}',
                fieldLabel: '{getAmountPercentLabel}',
                readOnly: '{getAmountPercentReadOnly}'
            },
            txtLastCost: '{current.dblLastCost}',
            txtStandardCost: '{current.dblStandardCost}',
            txtAverageCost: '{current.dblMovingAverageCost}',
            txtEndofMonthCost: '{current.dblEndMonthCost}',
            dtpBeginDate: '{current.dtmBeginDate}',
            dtpEndDate: '{current.dtmEndDate}'
        }
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.ItemPricing', { pageSize: 1 });


        win.context = Ext.create('iRely.mvvm.Engine', {
            window : win,
            store  : store,
            binding: me.config.binding,
            createRecord: {
                fn: me.createRecord,
                scope: me
            },
            validateRecord: me.validateRecord
        });

        return win.context;
    },

    show : function(config) {
        "use strict";

        var me = this,
            win = this.getView();

        if (config) {
            win.show();

            var context = me.setupContext( { window : win } );
            me.intItemId = config.itemId;
            me.priceId = config.priceId;
            me.pricingTable = config.table;
            me.defaultLocation = config.defaultLocation;

            if (config.action === 'new') {
                me.uomId = config.uomId;
                context.data.addRecord();
            } else {
                var filter = [{
                        column: 'intItemId',
                        value: config.itemId,
                        conjunction: 'and'
                    },{
                        column: 'intItemPricingId',
                        value: config.priceId,
                        conjunction: 'and'
                    }
                ];
                context.data.load({
                    filters: filter
                });
            }
        }
    },

    createRecord: function(config, action) {
        var me = this;
        var record = Ext.create('Inventory.model.ItemPricing');
        record.set('intItemId', me.intItemId);
        record.set('ysnActive', true);
        if (me.defaultLocation > 0)
            record.set('intLocationId', me.defaultLocation);
        if (me.uomId)
            record.set('intItemUnitMeasureId', me.uomId);
        record.set('dtmBeginDate', i21.ModuleMgr.Inventory.getTodayDate());
        action(record);
    },

    validateRecord: function (config, action) {
       this.validateRecord(config, function(result) {
           if (result) {
               var pricingTable = config.controller.pricingTable;
               var priceId = config.controller.priceId;
               var vm = config.window.viewModel;
               var current = vm.data.current;
               var locationUOM = [];
               var isValid = true;

               if (priceId){
                   Ext.Array.each(pricingTable.items, function(row) {
                       var dtmBeginDate = row.get('dtmBeginDate');
                       var dtmEndDate = row.get('dtmEndDate');
                       var exists = Ext.Array.findBy(locationUOM, function(record) {
                           if ((record.intLocationId === row.get('intLocationId')) && (record.intItemUOMId === row.get('intItemUOMId'))){
                               return true;
                           }
                           else { return false; }
                       });

                       if (row.get('intItemPricingId') === priceId){
                           row.set('dtmBeginDate', current.get('dtmBeginDate'));
                           row.set('dtmEndDate', current.get('dtmEndDate'));
                       }

                       if (exists){
                           exists.children.push(row);
                       }
                       else
                       {
                           var loc = {
                               intLocationId: row.get('intLocationId'),
                               intItemUOMId: row.get('intItemUOMId'),
                               children: []
                           };
                           loc.children.push(row);
                           locationUOM.push(loc);
                       }
                   });
                   isValid = config.controller.iteratePricingCheck(locationUOM);
               }
               else {
                   Ext.Array.each(pricingTable.items, function(row) {
                       var dtmBeginDate = row.get('dtmBeginDate');
                       var dtmEndDate = row.get('dtmEndDate');
                       var exists = Ext.Array.findBy(locationUOM, function(record) {
                           if ((record.intLocationId === row.get('intLocationId')) && (record.intItemUOMId === row.get('intItemUOMId'))){
                               return true;
                           }
                           else { return false; }
                       });
                       if (exists){
                           exists.children.push(row);
                       }
                       else
                       {
                           var loc = {
                               intLocationId: row.get('intLocationId'),
                               intItemUOMId: row.get('intItemUOMId'),
                               children: []
                           };
                           loc.children.push(row);
                           locationUOM.push(loc);
                       }
                   });
                   var exists = Ext.Array.findBy(locationUOM, function(record) {
                       if ((record.intLocationId === current.get('intLocationId')) && (record.intItemUOMId === current.get('intItemUOMId'))){
                           return true;
                       }
                       else { return false; }
                   });
                   if (exists){
                       exists.children.push(current);
                   }
                   else
                   {
                       var loc = {
                           intLocationId: current.get('intLocationId'),
                           intItemUOMId: current.get('intItemUOMId'),
                           children: []
                       };
                       loc.children.push(current);
                       locationUOM.push(loc);
                   }
                   isValid = config.controller.iteratePricingCheck(locationUOM);
               }

               if (!isValid){
                   iRely.Functions.showErrorDialog('Begin Date overlaps another previously configured Pricing.');
               }

               action(isValid);
           }
       });
    },

    onUOMSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;
        current.set('strUPC', records[0].get('strUpcCode'));
    },

    iteratePricingCheck: function(locationUOM) {
        var isValid = true;
        Ext.Array.each(locationUOM, function(row) {
            if (row.children.length > 1){
                Ext.Array.each(row.children, function(mainRow) {
                    var exists = Ext.Array.findBy(row.children, function(checkRow) {
                        if (mainRow.id !== checkRow.id){
                            if (iRely.Functions.isEmpty(mainRow.get('dtmEndDate'))){
                                if (iRely.Functions.isEmpty(checkRow.get('dtmEndDate'))){
                                    return true;
                                }
                                else {
                                    if ((mainRow.get('dtmBeginDate') > checkRow.get('dtmBeginDate')) && (mainRow.get('dtmBeginDate') > checkRow.get('dtmEndDate'))){
                                        return false;
                                    }
                                    else { return true; }
                                }
                            }
                            else if (iRely.Functions.isEmpty(checkRow.get('dtmEndDate'))){
                                if ((checkRow.get('dtmBeginDate') > mainRow.get('dtmBeginDate')) && (checkRow.get('dtmBeginDate') > mainRow.get('dtmEndDate'))){
                                    return false;
                                }
                                else { return true; }
                            }
                            else {
                                if ((mainRow.get('dtmBeginDate') > checkRow.get('dtmBeginDate')) && (mainRow.get('dtmBeginDate') > checkRow.get('dtmEndDate'))){
                                    return false;
                                }
                                else if ((mainRow.get('dtmBeginDate') < checkRow.get('dtmBeginDate')) && (mainRow.get('dtmBeginDate') < checkRow.get('dtmEndDate'))){
                                    return false;
                                }
                                else { return true; }
                            }
                        }
                        else { return false; }
                    });
                    if (exists) isValid = false;
                });
            }
        });
        return isValid;
    },

    init: function(application) {
        this.control({
            "#cboUnitMeasure": {
                select: this.onUOMSelect
            }
        })
    }
});
