/*
 * File: app/view/ItemLocationViewController.js
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

Ext.define('Inventory.view.ItemLocationViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icitemlocation',

    config: {
        helpURL: '/display/DOC/How+to+Setup+Item+Location',
        binding: {
            cboLocation: {
                value: '{current.intLocationId}',
                store: '{location}'
            },
            cboDefaultVendor: {
                value: '{current.intVendorId}',
                store: '{vendor}'
            },
            cboCostingMethod: {
                value: '{current.intCostingMethod}',
                store: '{costingMethods}'
            },
            cboPaymentOn: {
                value: '{current.intPaymentOn}',
                store: '{paymentOn}'
            },
            txtDescription: '{current.strDescription}',
            cboSubLocation: {
                value: '{current.intSubLocationId}',
                store: '{subLocation}',
                defaultFilters: [{
                    column: 'intCompanyLocationId',
                    value: '{current.intLocationId}',
                    conjunction: 'and'
                },{
                    column: 'strClassification',
                    value: 'Inventory',
                    conjunction: 'and'
                }]
            },
            cboStorageLocation: {
                value: '{current.intStorageLocationId}',
                store: '{storageLocation}',
                defaultFilters: [{
                    column: 'intLocationId',
                    value: '{current.intLocationId}',
                    conjunction: 'and'
                },{
                    column: 'intSubLocationId',
                    value: '{current.intSubLocationId}',
                    conjunction: 'and'
                }]
            },
            cboIssueUom: {
                value: '{current.intIssueUOMId}',
                store: '{issueUOM}',
                defaultFilters: [{
                    column: 'intItemId',
                    value: '{current.intItemId}'
                }]
            },
            cboReceiveUom: {
                value: '{current.intReceiveUOMId}',
                store: '{receiveUOM}',
                defaultFilters: [{
                    column: 'intItemId',
                    value: '{current.intItemId}',
                    conjunction: 'and'
                },{
                    column: 'ysnAllowPurchase',
                    value: true,
                    conjunction: 'and'
                }]
            },
            cboFamily: {
                value: '{current.intFamilyId}',
                store: '{family}',
                defaultFilters: [{
                    column: 'strSubcategoryType',
                    value: 'F',
                    conjunction: 'and'
                }]
            },
            cboClass: {
                value: '{current.intClassId}',
                store: '{class}',
                defaultFilters: [{
                    column: 'strSubcategoryType',
                    value: 'C',
                    conjunction: 'and'
                }]
            },
            cboProductCode: {
                value: '{current.intProductCodeId}',
                store: '{productCode}',
                defaultFilters: [{
                    column: 'intCompanyLocationId',
                    value: '{current.intLocationId}',
                    conjunction: 'and'
                }]
            },
            txtPassportFuelId1: '{current.strPassportFuelId1}',
            txtPassportFuelId2: '{current.strPassportFuelId2}',
            txtPassportFuelId3: '{current.strPassportFuelId3}',
            chkTaxFlag1: '{current.ysnTaxFlag1}',
            chkTaxFlag2: '{current.ysnTaxFlag2}',
            chkTaxFlag3: '{current.ysnTaxFlag3}',
            chkTaxFlag4: '{current.ysnTaxFlag4}',
            chkPromotionalItem: '{current.ysnPromotionalItem}',
            cboMixMatchCode: {
                value: '{current.intMixMatchId}',
                store: '{mixMatchCode}'
            },
            chkDepositRequired: '{current.ysnDepositRequired}',
            cboDepositPLU: {
                value: '{current.intDepositPLUId}',
                store: '{itemUPC}'
            },
            txtBottleDepositNo: '{current.intBottleDepositNo}',
            chkSaleable: '{current.ysnSaleable}',
            chkQuantityRequired: '{current.ysnQuantityRequired}',
            chkScaleItem: '{current.ysnScaleItem}',
            chkFoodStampable: '{current.ysnFoodStampable}',
            chkReturnable: '{current.ysnReturnable}',
            chkPrePriced: '{current.ysnPrePriced}',
            chkOpenPricePlu: '{current.ysnOpenPricePLU}',
            chkLinkedItem: '{current.ysnLinkedItem}',
            txtVendorCategory: '{current.strVendorCategory}',
            chkCountbySerialNumber: '{current.ysnCountBySINo}',
            txtSerialNumberBegin: '{current.strSerialNoBegin}',
            txtSerialNumberEnd: '{current.strSerialNoEnd}',
            chkIdRequiredLiqour: '{current.ysnIdRequiredLiquor}',
            chkIdRequiredCigarettes: '{current.ysnIdRequiredCigarette}',
            txtMinimumAge: '{current.intMinimumAge}',
            chkApplyBlueLaw1: '{current.ysnApplyBlueLaw1}',
            chkApplyBlueLaw2: '{current.ysnApplyBlueLaw2}',
            chkCarWash: '{current.ysnCarWash}',
            cboItemTypeCode: {
                value: '{current.intItemTypeCode}',
                store: '{itemTypeCode}'
            },
            txtItemTypeSubcode: '{current.intItemTypeSubCode}',
            chkAutoCalculateFreight: '{current.ysnAutoCalculateFreight}',
            cboFreightMethod: {
                value: '{current.intFreightMethodId}',
                store: '{freightTerm}'
            },
            txtFreightRate: '{current.dblFreightRate}',
            cboShipVia: {
                value: '{current.intShipViaId}',
                store: '{shipVia}'
            },
            cboNegativeInventory: {
                value: '{current.intAllowNegativeInventory}',
                store: '{negativeInventory}'
            },
            txtReorderPoint: '{current.dblReorderPoint}',
            txtMinOrder: '{current.dblMinOrder}',
            txtSuggestedQty: '{current.dblSuggestedQty}',
            txtLeadTime: '{current.dblLeadTime}',
            cboCounted: {
                value: '{current.strCounted}',
                store: '{counteds}'
            },
            cboInventoryGroupField: {
                value: '{current.intCountGroupId}',
                store: '{countGroup}'
            },
            chkCountedDaily: '{current.ysnCountedDaily}'
        }
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.ItemLocation', { pageSize: 1 });


        win.context = Ext.create('iRely.mvvm.Engine', {
            window : win,
            store  : store,
            binding: me.config.binding,
            createRecord: {
                fn: me.createRecord,
                scope: me
            }
        });

        var filter = [{ dataIndex: 'intItemId', value: options.itemId, condition: 'eq' }];
        var cboIssueUom = win.down('#cboIssueUom');
        var cboReceiveUom = win.down('#cboReceiveUom');
        cboIssueUom.defaultFilters = filter;
        cboReceiveUom.defaultFilters = filter;

        return win.context;
    },

    show : function(config) {
        "use strict";

        var me = this,
            win = this.getView();

        if (config) {
            win.show();

            var context = me.setupContext( { window : win } );
            me.intItemId = config.param.itemId;
            me.defaultUOM = config.param.defaultUOM;
            if (config.action === 'new') {
                context.data.addRecord();
            } else {
                var filter = [{
                    column: 'intItemId',
                    value: me.intItemId,
                    conjunction: 'and'
                },{
                    column: 'intItemLocationId',
                    value: config.param.locationId,
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
        var record = Ext.create('Inventory.model.ItemLocation');
        record.set('intItemId', me.intItemId);
        if (app.DefaultLocation > 0)
            record.set('intLocationId', app.DefaultLocation);
        record.set('intCostingMethod', 1);
        record.set('intAllowNegativeInventory', 3);
        if (iRely.Functions.isEmpty(me.defaultUOM) === false) {
            record.set('intIssueUOMId', me.defaultUOM.get('intItemUOMId'));
            record.set('intReceiveUOMId', me.defaultUOM.get('intItemUOMId'));
        }
        record.set('intPaymentOn', 1);
        action(record);
    },

    onVendorDrilldown: function(combo) {
        var win = combo.up('window');
        var current = win.viewModel.data.current;
        
        if (iRely.Functions.isEmpty(combo.getValue())) {
            iRely.Functions.openScreen('EntityManagement.view.Entity:searchEntityVendor', { action: 'new', viewConfig: { modal: true }});
        }
        else {
             iRely.Functions.openScreen('EntityManagement.view.Entity:searchEntityVendor', {
                action: 'view',
                filters: [
                    {
                        column: 'intEntityId',
                        value: current.get('intVendorId')
                    }
                ],
                 
                 viewConfig: { modal: true }
            });
        }
    },

    onLocationDrilldown: function(combo) {
        var win = combo.up('window');
        
        if (iRely.Functions.isEmpty(combo.getValue())) {
            iRely.Functions.openScreen('i21.view.CompanyLocation', { action: 'new', viewConfig: { modal: true }});
        }
        
        else {
            iRely.Functions.openScreen('i21.view.CompanyLocation', { 
                filters: [
                    {
                        column: 'strLocationName',
                        value: combo.getRawValue()
                    }
                ],
                viewConfig: { modal: true } 
            });
        }
    },

    onStorageLocationDrilldown: function(combo) {
        var win = combo.up('window');
        
        if (iRely.Functions.isEmpty(combo.getValue())) {
            iRely.Functions.openScreen('Inventory.view.StorageUnit', { action: 'new', viewConfig: { modal: true }});
        }
        
        else {
            iRely.Functions.openScreen('Inventory.view.StorageUnit', { 
                filters: [
                    {
                        column: 'strName',
                        value: combo.getRawValue()
                    }
                ],
                viewConfig: { modal: true } 
            });
        }
    },

    onCountGroupDrilldown: function(combo) {
        var win = combo.up('window');
        
        if (iRely.Functions.isEmpty(combo.getValue())) {
            iRely.Functions.openScreen('Inventory.view.InventoryCountGroup', { action: 'new', viewConfig: { modal: true }});
        }
        
        else {
            iRely.Functions.openScreen('Inventory.view.InventoryCountGroup', { 
                filters: [
                    {
                        column: 'strCountGroup',
                        value: combo.getRawValue()
                    }
                ],
                viewConfig: { modal: true } 
            });
        }
    },

    onSubCategoryDrilldown: function(combo) {
        var win = combo.up('window');
        
        if (iRely.Functions.isEmpty(combo.getValue())) {
            iRely.Functions.openScreen('Store.view.SubCategory', { action: 'new', viewConfig: { modal: true }});
        }
        
        else {
            iRely.Functions.openScreen('Store.view.SubCategory', { 
                filters: [
                    {
                        column: 'strSubcategoryId',
                        value: combo.getRawValue()
                    }
                ],
                viewConfig: { modal: true } 
            });
        }
    },

    onProductCodeDrilldown: function(combo) {
        var win = combo.up('window');
        var current = win.viewModel.data.current;
        
        if (iRely.Functions.isEmpty(combo.getValue())) {
            iRely.Functions.openScreen('Store.view.Store', { 
                activeTab: 'Register Product',
                action: 'new',
            });
        }
        
        else {      
            iRely.Functions.openScreen('Store.view.Store', { 
                activeTab: 'Register Product',
                filters: [
                    {
                         column: 'intStoreNo',
                         value: combo.getValue(),
                         conjunction: 'and'
                    },
                    {
                         column: 'intCompanyLocationId',
                         value: current.get('intLocationId'),
                         conjunction: 'and'
                    }  
                ],
                
            });
        }
    },

    onPromotionalDrilldown: function(combo) {
        var win = combo.up('window');
        
        if (iRely.Functions.isEmpty(combo.getValue())) {
            iRely.Functions.openScreen('Store.view.PromotionSales', { action: 'new', viewConfig: { modal: true }});
        }
        
        else {
            iRely.Functions.openScreen('Store.view.PromotionSales', { 
                filters: [
                    {
                        column: 'intPromoSalesId',
                        value: combo.getRawValue()
                    }
                ],
                viewConfig: { modal: true } 
            });
        }
    },

    onDepositPLUDrilldown: function(combo) {
        i21.ModuleMgr.Inventory.showScreen(combo.getRawValue(), 'DepositPLU');
    },

    onLocationSelect: function (combo, records) {
        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) {
            current.set('intSubLocationId', null);
            current.set('intStorageLocationId', null);
        }
    },
   
    onCostingMethodSelect: function(combo, records)
    {
        var win = combo.up('window');
        var current = win.viewModel.data.current;
        
        
        Ext.Ajax.request({
        url: '../Inventory/api/ItemLocation/CheckCostingMethod?ItemId=' + current.get('intItemId') + 
            '&ItemLocationId=' + current.get('intItemLocationId') +
            '&CostingMethod=' + current.get('intCostingMethod'),
        method: 'post',
        success: function (response) {
                    var jsonData = Ext.decode(response.responseText);
                    if (!jsonData.success) 
                    {
                        iRely.Functions.showErrorDialog(jsonData.message.statusText);
                    }
                },
        failure: function(response)
            {
                var jsonData = Ext.decode(response.responseText);
                iRely.Functions.showErrorDialog(jsonData.ExceptionMessage);
            }
        
        }); 

    },

    init: function(application) {
        this.control({
            "#cboLocation": {
                drilldown: this.onLocationDrilldown,
                select: this.onLocationSelect
            },
            "#cboDefaultVendor": {
                drilldown: this.onVendorDrilldown
            },
            "#cboStorageLocation": {
                drilldown: this.onStorageLocationDrilldown
            },
            "#cboFamily": {
                drilldown: this.onSubCategoryDrilldown
            },
            "#cboClass": {
                drilldown: this.onSubCategoryDrilldown
            },
            "#cboProductCode": {
                drilldown: this.onProductCodeDrilldown
            },
            "#cboMixMatchCode": {
                drilldown: this.onPromotionalDrilldown
            },
            "#cboDepositPLU": {
                drilldown: this.onDepositPLUDrilldown
            },
            "#cboInventoryGroupField": {
                drilldown: this.onCountGroupDrilldown
            },
            "#cboCostingMethod": {
                select: this.onCostingMethodSelect
            }
        });
    }

});
