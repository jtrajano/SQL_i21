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
                value: '{current.strLocationName}',
                store: '{location}'
            },
            cboDefaultVendor: {
                value: '{current.strVendorName}',
                origUpdateField: 'intVendorId',
                origValueField: 'intEntityId',
                store: '{vendor}'
            },
            cboCostingMethod: {
                value: '{current.intCostingMethod}',
                store: '{costingMethods}'
            },
            txtDescription: '{current.strDescription}',
            cboSubLocation: {
                value: '{current.strSubLocationName}',
                origValueField: 'intCompanyLocationSubLocationId',
                origUpdateField: 'intSubLocationId',
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
                value: '{current.strStorageLocationName}',
                origValueField: 'intStorageLocationId',
                origUpdateField: 'intStorageLocationId',
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
            cboGrossUOM: {
                value: '{current.strGrossUOM}',
                origValueField: 'intItemUOMId',
                origUpdateField: 'intGrossUOMId',
                store: '{grossUOM}',
                defaultFilters: [{
                    column: 'intItemId',
                    value: '{current.intItemId}'
                }]
            },
            cboIssueUom: {
                value: '{current.strIssueUOM}',
                origValueField: 'intItemUOMId',
                origUpdateField: 'intIssueUOMId',
                store: '{issueUOM}',
                defaultFilters: [{
                    column: 'intItemId',
                    value: '{current.intItemId}'
                }]
            },
            cboReceiveUom: {
                value: '{current.strReceiveUOM}',
                origValueField: 'intItemUOMId',
                origUpdateField: 'intReceiveUOMId',
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
                value: '{current.strFamily}',
                origValueField: 'intSubcategoryId',
                origUpdateField: 'intFamilyId',
                store: '{family}',
                defaultFilters: [{
                    column: 'strSubcategoryType',
                    value: 'F',
                    conjunction: 'and'
                }]
            },
            cboClass: {
                value: '{current.strClass}',
                origValueField: 'intSubCategoryId',
                origUpdateField: 'intClassId',
                store: '{class}',
                defaultFilters: [{
                    column: 'strSubcategoryType',
                    value: 'C',
                    conjunction: 'and'
                }]
            },
            cboProductCode: {
                value: '{current.strProductCode}',
                origValueField: 'strRegProdCode',
                origUpdateField: 'strProductCode',
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
                value: '{current.strPromoItemListId}',
                origValueField: 'strPromoSalesDescription',
                origUpdateField: 'strPromoItemListId',
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
                value: '{current.strCountGroup}',
                origUpdateField: 'intCountGroupId',
                origValueField: 'intCountGroupId',
                store: '{countGroup}'
            },
            chkCountedDaily: '{current.ysnCountedDaily}'
        }
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.ItemLocation', { pageSize: 1 });


        win.context = Ext.create('iRely.Engine', {
            window : win,
            store  : store,
            binding: me.config.binding,
            include: 'vyuICGetItemLocation',
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
        var defaultLocation = iRely.Configuration.Application.CurrentLocation; 

        var newRecord = Ext.create('Inventory.model.ItemLocation');
        newRecord.set('intItemId', me.intItemId);

        // Set the default company location. 
        if (defaultLocation){
            newRecord.set('intLocationId', defaultLocation);

            // Get the display value for the company location. 
            Ext.create('i21.store.CompanyLocationBuffered', {
                storeId: 'icItemLocationCompanyLocation',
                autoLoad: {
                    filters: [
                        {
                            dataIndex: 'intCompanyLocationId',
                            value: defaultLocation,
                            condition: 'eq'
                        }
                    ],
                    params: {
                        columns: 'strLocationName:intCompanyLocationId:'
                    },
                    callback: function(records, operation, success){
                        var record; 
                        if (records && records.length > 0) {
                            record = records[0];
                        }

                        if(success && record){
                            newRecord.set('strLocationName', record.get('strLocationName'));
                            newRecord.set('intLocationId', record.get('intCompanyLocationId'));
                        }
                    }
                }
            });            
        }  

        // Set the default Issue and Receive UOM
        if (me.defaultUOM && me.defaultUOM.intItemUOMId) {
            newRecord.set('intIssueUOMId', me.defaultUOM.intItemUOMId);
            newRecord.set('intReceiveUOMId', me.defaultUOM.intItemUOMId);
            
            // Get the display value. 
            Ext.create('Inventory.store.BufferedItemUnitMeasure', {
                storeId: 'icItemLocationUOM',
                autoLoad: {
                    filters: [
                        {
                            dataIndex: 'intItemUOMId',
                            value: me.defaultUOM.intItemUOMId,
                            condition: 'eq'
                        }
                    ],
                    params: {
                        columns: 'strUnitMeasure:intItemUOMId:'
                    },
                    callback: function(records, operation, success){
                        var record; 
                        if (records && records.length > 0) {
                            record = records[0];
                        }

                        if(success && record){
                            newRecord.set('intIssueUOMId', record.get('intItemUOMId'));
                            newRecord.set('intReceiveUOMId', record.get('intItemUOMId'));
                            newRecord.set('strIssueUOM', record.get('strUnitMeasure'));
                            newRecord.set('strReceiveUOM', record.get('strUnitMeasure'));
                            
                        }
                    }
                }
            }); 
        }

        newRecord.set('intCostingMethod', 1); // Default Costing method is AVG. 
        newRecord.set('intAllowNegativeInventory', 3); // Default to 'No'. 

        action(newRecord);
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
            var record = records ? records[0] : {};
            current.set('intLocationId', record.get('intCompanyLocationId'));
            current.set('intSubLocationId', null);
            current.set('intStorageLocationId', null);
        }
    },

    onDefaultVendorSelect: function (combo, records) {
        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) {
            var record = records ? records[0] : {};
            current.set('intVendorId', record.get('intEntityId'));
        }
    },

    onSubLocationSelect: function (combo, records) {
        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) {
            var record = records ? records[0] : {};
            current.set('intSubLocationId', record.get('intCompanyLocationSubLocationId'));
        }
    },    

    onStorageLocationSelect: function (combo, records) {
        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) {
            var record = records ? records[0] : {};
            current.set('intStorageLocationId', record.get('intStorageLocationId'));
        }
    },   

    onIssueUOMSelect: function (combo, records) {
        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) {
            var record = records ? records[0] : {};
            current.set('intIssueUOMId', record.get('intItemUOMId'));
        }
    },     

    onReceiveUOMSelect: function (combo, records) {
        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) {
            var record = records ? records[0] : {};
            current.set('intReceiveUOMId', record.get('intItemUOMId'));
        }
    },         
   
    onCostingMethodSelect: function(combo, records)
    {
        var win = combo.up('window');
        var current = win.viewModel.data.current;
        
        ic.utils.ajax({
            url: '../Inventory/api/ItemLocation/CheckCostingMethod',
            method: 'POST',
            params: {
                ItemId: current.get('intItemId'),
                ItemLocationId: current.get('intItemLocationId'),
                CostingMethod: current.get('intCostingMethod')
            }
        })
        .subscribe(
            function(response) {
                var jsonData = Ext.decode(response.responseText);
                if (!jsonData.success) 
                {
                    iRely.Functions.showErrorDialog(jsonData.message.statusText);
                }
            },
            function(response) {
                var jsonData = Ext.decode(response.responseText);
                if(response.status === 404)
                    iRely.Functions.showErrorDialog(jsonData.Message);
                else    
                    iRely.Functions.showErrorDialog(jsonData.ExceptionMessage);
            }
        );
    },

    onFamilySelect: function (combo, records) {
        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) {
            var record = records ? records[0] : {};
            current.set('intFamilyId', record.get('intSubcategoryId'));
        }
    },    

    onClassSelect: function (combo, records) {
        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) {
            var record = records ? records[0] : {};
            current.set('intClassId', record.get('intSubcategoryId'));
        }
    },           

    onCountGroupSelect: function (combo, records) {
        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) {
            var record = records ? records[0] : {};
            current.set('intCountGroupId', record.get('intCountGroupId'));
        }
    },    

    onPromotionItemSelect: function (combo, records) {
        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) {
            var record = records ? records[0] : {};
            current.set('intMixMatchId', record.get('intPromoSalesListId'));
        }
    },       

    onProductCodeSelect: function (combo, records) {
        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) {
            var record = records ? records[0] : {};
            current.set('intProductCodeId', record.get('intRegProdId'));
            current.set('strProductCode', record.get('strRegProdCode'));
        }
    },       

    init: function(application) {
        this.control({
            "#cboLocation": {
                drilldown: this.onLocationDrilldown,
                select: this.onLocationSelect
            },
            "#cboDefaultVendor": {
                drilldown: this.onVendorDrilldown,
                select: this.onDefaultVendorSelect
            },
            "#cboSubLocation": {
                select: this.onSubLocationSelect
            },
            "#cboStorageLocation": {
                drilldown: this.onStorageLocationDrilldown,
                select: this.onStorageLocationSelect
            },
            "#cboIssueUom": {
                select: this.onIssueUOMSelect 
            },
            "#cboReceiveUom": {
                select: this.onReceiveUOMSelect
            },
            "#cboFamily": {
                drilldown: this.onSubCategoryDrilldown,
                select: this.onFamilySelect
            },
            "#cboClass": {
                drilldown: this.onSubCategoryDrilldown,
                select: this.onClassSelect
            },
            "#cboProductCode": {
                drilldown: this.onProductCodeDrilldown,
                select: this.onProductCodeSelect
            },
            "#cboMixMatchCode": {
                drilldown: this.onPromotionalDrilldown,
                select: this.onPromotionItemSelect
            },
            "#cboDepositPLU": {
                drilldown: this.onDepositPLUDrilldown
            },
            "#cboInventoryGroupField": {
                drilldown: this.onCountGroupDrilldown,
                select: this.onCountGroupSelect
            },
            "#cboCostingMethod": {
                select: this.onCostingMethodSelect
            }
        });
    }

});
