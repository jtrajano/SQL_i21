Ext.define('Inventory.view.CategoryViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.iccategory',

    config: {
        searchConfig: {
            title: 'Search Category',
            type: 'Inventory.Category',
            api: {
                read: '../Inventory/api/Category/Search'
            },
            columns: [
                {dataIndex: 'intCategoryId', text: "Category Id", flex: 1, defaultSort: true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strCategoryCode', text: 'Category Code', flex: 1, dataType: 'string'},
                {dataIndex: 'strDescription', text: 'Description', flex: 1, dataType: 'string'},
                {dataIndex: 'strInventoryType', text: 'Inventory Type', flex: 1, dataType: 'string'}
            ]
        },
        binding: {
            bind: {
                title: 'Category - {current.strCategoryCode}'
            },
            txtCategoryCode: '{current.strCategoryCode}',
            txtDescription: '{current.strDescription}',
            cboLineOfBusiness: {
                value: '{current.intLineOfBusinessId}',
                store: '{linesOfBusiness}'
            },
            cboCostingMethod: {
                value: '{current.intCostingMethod}',
                store: '{costingMethods}'
            },
            cboInventoryValuation: {
                value: '{current.strInventoryTracking}',
                store: '{inventoryTrackings}'
            },
            txtStandardQty: '{current.dblStandardQty}',
            cboStandardUOM: {
                value: '{current.intUOMId}',
                store: '{standardUOM}',
                defaultFilters: [{
                    column: 'intCategoryId',
                    value: '{current.intCategoryId}',
                    conjunction: 'and'
                }]
            },

            txtGlDivisionNumber: '{current.strGLDivisionNumber}',
            chkSalesAnalysisByTon: '{current.ysnSalesAnalysisByTon}',
            cboMaterialFee: {
                value: '{current.strMaterialFee}',
                store: '{materialFees}'
            },
            cboMaterialItem: {
                value: '{current.intMaterialItemId}',
                store: '{materialItem}',
                readOnly: '{checkMaterialFee}'
            },
            chkAutoCalculateFreight: '{current.ysnAutoCalculateFreight}',
            cboFreightItem: {
                value: '{current.intFreightItemId}',
                store: '{freightItem}',
                readOnly: '{checkAutoCalculateFreight}'
            },
            cboInventoryType: {
                value: '{current.strInventoryType}',
                store: '{inventoryTypes}'
            },

            grdUnitOfMeasure: {
                colDetailUnitMeasure: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{uomUnitMeasure}'
                    }
                },
                colDetailUnitQty: {
                    dataIndex: 'dblUnitQty'
                },
                colStockUnit: 'ysnStockUnit',
                colAllowSale: 'ysnAllowSale',
                colAllowPurchase: 'ysnAllowPurchase',
                colDefault: 'ysnDefault'
            },

            grdLocation: {
                colLocationId: 'strLocationName',
                colLocationCashRegisterDept: 'intRegisterDepartmentId',
                colLocationTargetGrossProfit: 'dblTargetGrossProfit',
                colLocationTargetInventoryCost: 'dblTargetInventoryCost',
                colLocationCostInventoryBOM: 'dblCostInventoryBOM'
            },

            grdGlAccounts: {
                colAccountCategory: {
                    dataIndex: 'strAccountCategory',
                    editor: {
                        store: '{accountCategory}',
                        defaultFilters: [{
                            column: 'strAccountCategoryGroupCode',
                            value: 'INV'
                        }]
                    }
                },
                colAccountId: {
                    dataIndex: 'strAccountId',
                    editor: {
                        store: '{glAccount}',
                        defaultFilters: [{
                            column: 'intAccountCategoryId',
                            value: '{grdGlAccounts.selection.intAccountCategoryId}'
                        }]
                    }
                },
                colAccountDescription: 'strDescription'
            },

            grdVendorCategoryXref: {
                colVendorLocation: {
                    dataIndex: 'strLocationName',
                    editor: {
                        origValueField: 'intCategoryLocationId',
                        origUpdateField: 'intCategoryLocationId',
                        store: '{location}',
                        defaultFilters: [{
                            column: 'intCategoryId',
                            value: '{current.intCategoryId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colVendorId: {
                    dataIndex: 'strVendorId',
                    editor: {
                        origValueField: 'intEntityVendorId',
                        origUpdateField: 'intVendorId',
                        store: '{vendor}'
                    }
                },
                colVendorDepartment: 'strVendorDepartment',
                colVendorAddOrderUPC: 'ysnAddOrderingUPC',
                colVendorUpdateExisting: 'ysnUpdateExistingRecords',
                colVendorAddNew: 'ysnAddNewRecords',
                colVendorUpdatePrice: 'ysnUpdatePrice',
                colVendorFamily: {
                    dataIndex: 'strFamilyId',
                    editor: {
                        origValueField: 'intSubcategoryId',
                        origUpdateField: 'intFamilyId',
                        store: '{vendorFamily}',
                        defaultFilters: [{
                            column: 'strSubcategoryType',
                            value: 'F',
                            conjunction: 'and'
                        }]
                    }
                },
                colVendorSellClass: {
                    dataIndex: 'strSellClassId',
                    editor: {
                        origValueField: 'intSubcategoryId',
                        origUpdateField: 'intSellClassId',
                        store: '{vendorSellClass}',
                        defaultFilters: [{
                            column: 'strSubcategoryType',
                            value: 'C',
                            conjunction: 'and'
                        }]
                    }
                },
                colVendorOrderClass: {
                    dataIndex: 'strOrderClassId',
                    editor: {
                        origValueField: 'intSubcategoryId',
                        origUpdateField: 'intOrderClassId',
                        store: '{vendorOrderClass}',
                        defaultFilters: [{
                            column: 'strSubcategoryType',
                            value: 'C',
                            conjunction: 'and'
                        }]
                    }
                },
                colVendorComments: 'strComments'
            },

            txtERPItemClass: '{current.strERPItemClass}',
            txtLifeTime: '{current.dblLifeTime}',
            txtBOMItemShrinkage: '{current.dblBOMItemShrinkage}',
            txtBOMItemUpperTolerance: '{current.dblBOMItemUpperTolerance}',
            txtBOMItemLowerTolerance: '{current.dblBOMItemLowerTolerance}',
            chkScaled: '{current.ysnScaled}',
            chkOutputItemMandatory: '{current.ysnOutputItemMandatory}',
            txtConsumptionMethod: '{current.strConsumptionMethod}',
            txtBOMItemType: '{current.strBOMItemType}',
            txtShortName: '{current.strShortName}',
            imgReceipt: '{current.imgReceiptImage}',
            imgWIP: '{current.imgWIPImage}',
            imgFG: '{current.imgFGImage}',
            imgShip: '{current.imgShipImage}',
            txtLaborCost: '{current.dblLaborCost}',
            txtOverHead: '{current.dblOverHead}',
            txtPercentage: '{current.dblPercentage}',
            txtCostDistributionMethod: '{current.strCostDistributionMethod}',
            chkSellable: '{current.ysnSellable}',
            chkYieldAdjustment: '{current.ysnYieldAdjustment}',
            chkTrackedInWarehouse: '{current.ysnWarehouseTracked}'
        }
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Category', { pageSize: 1 });

        win.context = Ext.create('iRely.mvvm.Engine', {
            window : win,
            store  : store,
            include: 'tblICCategoryAccounts.tblGLAccount, ' +
                'tblICCategoryAccounts.tblGLAccountCategory, ' +
                'tblICCategoryLocations.tblSMCompanyLocation, ' +
                'tblICCategoryVendors.vyuAPVendor, ' +
                'tblICCategoryVendors.Family, ' +
                'tblICCategoryVendors.SellClass, ' +
                'tblICCategoryVendors.OrderClass, ' +
                'tblICCategoryVendors.tblICCategoryLocation.tblSMCompanyLocation, ' +
                'tblICCategoryUOMs.tblICUnitMeasure',
            createRecord : me.createRecord,
            binding: me.config.binding,
            details: [
                {
                    key: 'tblICCategoryAccounts',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: win.down('#grdGlAccounts'),
                        deleteButton : win.down('#btnDeleteGlAccounts')
                    })
                },
                {
                    key: 'tblICCategoryLocations',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: win.down('#grdLocation'),
                        deleteButton : win.down('#btnDeleteLocation'),
                        position: 'none'
                    })
                },
                {
                    key: 'tblICCategoryVendors',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: win.down('#grdVendorCategoryXref'),
                        deleteButton : win.down('#btnDeleteVendorCategoryXref')
                    })
                },
                {
                    key: 'tblICCategoryUOMs',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: win.down('#grdUnitOfMeasure'),
                        deleteButton : win.down('#btnDeleteUom')
                    })
                }
            ]
        });

        var filter = [{ dataIndex: 'strType', value: 'Other Charge', condition: 'eq' }];
        var cboMaterialItem = win.down('#cboMaterialItem');
        var cboFreightItem = win.down('#cboFreightItem');
        cboMaterialItem.defaultFilters = filter;
        cboFreightItem.defaultFilters = filter;

        return win.context;
    },

    show : function(config) {
        "use strict";

        var me = this,
            win = this.getView();

        if (config) {
            win.show();

            var context = me.setupContext( {window : win} );

            if (config.action === 'new') {
                context.data.addRecord();
            } else {
                if (config.id) {
                    config.filters = [{
                        column: 'intCategoryId',
                        value: config.id
                    }];
                }
                context.data.load({
                    filters: config.filters
                });
            }
        }
    },

    onAccountSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepAccount');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colAccountId')
        {
            current.set('intAccountId', records[0].get('intAccountId'));
            current.set('strDescription', records[0].get('strDescription'));
            current.set('strAccountGroup', records[0].get('strAccountGroup'));
        }
        else if (combo.column.itemId === 'colAccountCategory')
        {
            current.set('intAccountCategoryId', records[0].get('intAccountCategoryId'));
        }
    },

    onbtnAddLocationClick: function(button, e, eOpts) {
        var win = button.up('window');
        var me = win.controller;
        var vm = win.getViewModel();

        if (vm.data.current.phantom === true) {
            win.context.data.saveRecord({ successFn: function(batch, eOpts){
                me.openCategoryLocationScreen('new', win);
            } });
        }
        else {
            win.context.data.validator.validateRecord({ window: win }, function(valid) {
                if (valid) {
                    me.openCategoryLocationScreen('new', win);
                }
            });
        }
    },

    onbtnEditLocationClick: function(button, e, eOpts) {
        var win = button.up('window');
        var me = win.controller;
        var vm = win.getViewModel();

        if (vm.data.current.phantom === true) {
            win.context.data.saveRecord({ successFn: function(batch, eOpts){
                me.openCategoryLocationScreen('edit', win);
            } });
        }
        else {
            win.context.data.validator.validateRecord({ window: win }, function(valid) {
                if (valid) {
                    me.openCategoryLocationScreen('edit', win);
                }
            });
        }
    },

    openCategoryLocationScreen: function (action, window) {
        var win = window;
        var me = win.controller;
        var screenName = 'Inventory.view.CategoryLocation';

        Ext.require([
                screenName,
                screenName + 'ViewModel',
                screenName + 'ViewController'
        ], function() {
            var screen = 'ic' + screenName.substring(screenName.indexOf('view.') + 5, screenName.length);
            var view = Ext.create(screenName, { controller: screen.toLowerCase(), viewModel : { type: screen.toLowerCase() } });
            view.on('destroy', me.onDestroyCategoryLocationScreen, me, { window: win });

            var controller = view.getController();
            var current = win.getViewModel().data.current;
            controller.show({ id: current.get('intCategoryId'), action: action });
        });
    },

    onDestroyCategoryLocationScreen: function(win, eOpts) {
        var me = eOpts.window.getController();
        var win = eOpts.window;
        var grdLocation = win.down('#grdLocation');
        var vm = win.getViewModel();
        var categoryId = vm.data.current.get('intCategoryId');
        var filterItem = grdLocation.store.filters.items[0];

        filterItem.setValue(categoryId);
        filterItem.config.value = categoryId;
        filterItem.initialConfig.value = categoryId;
        grdLocation.store.getProxy().setExtraParams({include:'tblSMCompanyLocation'});
        grdLocation.store.load();
    },

    onUOMUnitMeasureSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var win = combo.up('window');
        var plugin = grid.getPlugin('cepDetailUOM');
        var current = plugin.getActiveRecord();
        var uomConversion = win.viewModel.storeInfo.uomConversion;

        if (combo.column.itemId === 'colDetailUnitMeasure')
        {
            current.set('intUnitMeasureId', records[0].get('intUnitMeasureId'));
            current.set('ysnAllowSale', true);
            current.set('ysnAllowPurchase', true);
            current.set('tblICUnitMeasure', records[0]);

            var uoms = grid.store.data.items;
            var exists = Ext.Array.findBy(uoms, function (row) {
                if (row.get('ysnStockUnit') === true) {
                    return true;
                }
            });
            if (exists) {
                if (uomConversion) {
                    var index = uomConversion.data.findIndexBy(function (row) {
                        if (row.get('intUnitMeasureId') === exists.get('intUnitMeasureId')) {
                            return true;
                        }
                    });
                    if (index >= 0) {
                        var stockUOM = uomConversion.getAt(index);
                        var conversions = stockUOM.data.vyuICGetUOMConversions;
                        if (conversions) {
                            var selectedUOM = Ext.Array.findBy(conversions, function (row) {
                                if (row.intUnitMeasureId === current.get('intUnitMeasureId')) {
                                    return true;
                                }
                            });
                            if (selectedUOM) {
                                current.set('dblUnitQty', selectedUOM.dblConversionToStock);
                            }
                        }
                    }
                }
            }
        }
    },

    onUOMStockUnitCheckChange: function (obj, rowIndex, checked, eOpts) {
        if (obj.dataIndex === 'ysnStockUnit'){
            var grid = obj.up('grid');
            var win = obj.up('window');
            var current = grid.view.getRecord(rowIndex);
            var uomConversion = win.viewModel.storeInfo.uomConversion;

            if (checked === true){
                var uoms = grid.store.data.items;
                if (uoms) {
                    uoms.forEach(function(uom){
                        if (uom === current){
                            current.set('dblUnitQty', 1);
                        }
                        if (uom !== current){
                            uom.set('ysnStockUnit', false);
                            if (uomConversion) {
                                var index = uomConversion.data.findIndexBy(function (row) {
                                    if (row.get('intUnitMeasureId') === current.get('intUnitMeasureId')) {
                                        return true;
                                    }
                                });
                                if (index >= 0) {
                                    var stockUOM = uomConversion.getAt(index);
                                    var conversions = stockUOM.data.vyuICGetUOMConversions;
                                    if (conversions) {
                                        var selectedUOM = Ext.Array.findBy(conversions, function (row) {
                                            if (row.intUnitMeasureId === uom.get('intUnitMeasureId')) {
                                                return true;
                                            }
                                        });
                                        if (selectedUOM) {
                                            uom.set('dblUnitQty', selectedUOM.dblConversionToStock);
                                        }
                                    }
                                }
                            }
                        }
                    });
                }
            }
            else {
                if (current){
                    current.set('dblUnitQty', 1);
                }
            }
        }
    },

    onUOMDefaultCheckChange: function (obj, rowIndex, checked, eOpts) {
        if (obj.dataIndex === 'ysnDefault'){
            var grid = obj.up('grid');
            var current = grid.view.getRecord(rowIndex);

            if (checked === true){
                var uoms = grid.store.data.items;
                if (uoms) {
                    uoms.forEach(function(uom){
                        if (uom !== current){
                            uom.set('ysnDefault', false);
                        }
                    });
                }
            }
        }
    },

    init: function(application) {
        this.control({
            "#cboDetailUnitMeasure": {
                select: this.onUOMUnitMeasureSelect
            },
            "#cboAccountId": {
                select: this.onAccountSelect
            },
            "#cboAccountCategory": {
                select: this.onAccountSelect
            },
            "#btnAddLocation": {
                click: this.onbtnAddLocationClick
            },
            "#btnEditLocation": {
                click: this.onbtnEditLocationClick
            },
            "#colStockUnit": {
                beforecheckchange: this.onUOMStockUnitCheckChange
            },
            "#colDefault": {
                beforecheckchange: this.onUOMDefaultCheckChange
            }
        });
    }
});
