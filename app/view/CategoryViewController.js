Ext.define('Inventory.view.CategoryViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.iccategory',

    config: {
        searchConfig: {
            title: 'Search Category',
            type: 'Inventory.Category',
            api: {
                read: '../Inventory/api/Category/SearchCategories'
            },
            columns: [
                {dataIndex: 'intCategoryId', text: "Category Id", flex: 1, defaultSort: true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strCategoryCode', text: 'Category Code', flex: 1, dataType: 'string'},
                {dataIndex: 'strDescription', text: 'Description', flex: 1, dataType: 'string'}
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
            cboCatalogGroup: '{current.intCatalogGroupId}',
            cboCostingMethod: {
                value: '{current.intCostingMethod}',
                store: '{costingMethods}'
            },
            cboInventoryValuation: {
                value: '{current.strInventoryTracking}',
                store: '{inventoryTrackings}'
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
                colDetailSellQty: {
                    dataIndex: 'dblSellQty'
                },
                colDetailWeight: {
                    dataIndex: 'dblWeight'
                },
                colDetailWeightUOM: {
                    dataIndex: 'strWeightUOM',
                    editor: {
                        store: '{weightUOM}',
                        defaultFilters: [{
                            column: 'strUnitType',
                            value: 'Weight',
                            conjunction: 'and'
                        }]
                    }
                },
                colDetailDescription: 'strDescription',
                colDetailUpcCode: 'strUpcCode',
                colStockUnit: 'ysnStockUnit',
                colAllowSale: 'ysnAllowSale',
                colAllowPurchase: 'ysnAllowPurchase',
                colConvertToStock: 'dblConvertToStock',
                colConvertFromStock: 'dblConvertFromStock',
                colDetailLength: 'dblLength',
                colDetailWidth: 'dblWidth',
                colDetailHeight: 'dblHeight',
                colDetailDimensionUOM: {
                    dataIndex: 'strDimensionUOM',
                    editor: {
                        store: '{dimensionUOM}',
                        defaultFilters: [{
                            column: 'strUnitType',
                            value: '',
                            conjunction: 'and'
                        }]
                    }
                },
                colDetailVolume: 'dblVolume',
                colDetailVolumeUOM: {
                    dataIndex: 'strVolumeUOM',
                    editor: {
                        store: '{volumeUOM}',
                        defaultFilters: [{
                            column: 'strUnitType',
                            value: 'Volume',
                            conjunction: 'and'
                        }]
                    }
                },
                colDetailMaxQty: 'dblMaxQty'
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
                        defaultFilters: i21.ModuleMgr.Inventory.getICAccountCategories()
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
                        store: '{location}'
                    }
                },
                colVendorId: {
                    dataIndex: 'strVendorId',
                    editor: {
                        store: '{vendor}'
                    }
                },
                colVendorDepartment: 'strVendorDepartment',
                colVendorAddOrderUPC: 'ysnAddOrderingUPC',
                colVendorUpdateExisting: 'ysnUpdateExistingRecords',
                colVendorAddNew: 'ysnAddNewRecords',
                colVendorUpdatePrice: 'ysnUpdatePrice',
                colVendorFamily: {
                    dataIndex: 'intFamilyId',
                    editor: {
                        store: '{vendorFamily}'
                    }
                },
                colVendorSellClass: {
                    dataIndex: 'intSellClassId',
                    editor: {
                        store: '{vendorSellClass}'
                    }
                },
                colVendorOrderClass: {
                    dataIndex: 'intOrderClassId',
                    editor: {
                        store: '{vendorOrderClass}'
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
            chkYieldAdjustment: '{current.ysnYieldAdjustment}'
        }
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Category', { pageSize: 1 });

        win.context = Ext.create('iRely.mvvm.Engine', {
            window : win,
            store  : store,
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

    onVendorXRefSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepVendor');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colVendorLocation')
        {
            current.set('intCategoryLocationId', records[0].get('intCategoryLocationId'));
        }
        else if (combo.column.itemId === 'colVendorId')
        {
            current.set('intVendorId', records[0].get('intVendorId'));
        }
        else if (combo.column.itemId === 'colVendorFamily')
        {
            current.set('intFamilyId', records[0].get('intFamilyId'));
        }
        else if (combo.column.itemId === 'colVendorSellClass')
        {
            current.set('intSellClassId', records[0].get('intClassId'));
        }
        else if (combo.column.itemId === 'colVendorOrderClass')
        {
            current.set('intOrderClassId', records[0].get('intClassId'));
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

        grdLocation.store.load();
    },

    onUOMUnitMeasureSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepDetailUOM');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colDetailUnitMeasure')
        {
            current.set('intUnitMeasureId', records[0].get('intUnitMeasureId'));
        }
        else if (combo.column.itemId === 'colDetailWeightUOM')
        {
            current.set('intWeightUOMId', records[0].get('intUnitMeasureId'));
        }
        else if (combo.column.itemId === 'colDetailDimensionUOM')
        {
            current.set('intDimensionUOMId', records[0].get('intUnitMeasureId'));
        }
        else if (combo.column.itemId === 'colDetailVolumeUOM')
        {
            current.set('intVolumeUOMId', records[0].get('intUnitMeasureId'));
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
            "#cboVendorLocation": {
                select: this.onVendorXRefSelect
            },
            "#cboVendorId": {
                select: this.onVendorXRefSelect
            },
            "#cboVendorFamily": {
                select: this.onVendorXRefSelect
            },
            "#cboVendorSellClass": {
                select: this.onVendorXRefSelect
            },
            "#cboVendorOrderClass": {
                select: this.onVendorXRefSelect
            }
        });
    }
});
