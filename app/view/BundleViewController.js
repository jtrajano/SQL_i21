Ext.define('Inventory.view.BundleViewController', {
    extend: 'Inventory.view.InventoryBaseViewController',
    alias: 'controller.icbundle',

    config: {
        helpURL: '/display/DOC/Bundle',
        binding: {
            bind: {
                title: 'Bundle - {current.strItemNo}'
            },

            //-----------//
            //Details Tab//
            //-----------//
            txtItemNo: '{current.strItemNo}',
            txtDescription: {
                value: '{current.strDescription}'
            },
            cboBundleType: {
                value: '{current.strBundleType}',
                store: '{bundleTypes}'
            },
            txtShortName: {
                value: '{current.strShortName}'
            },
            cboManufacturer: {
                value: '{current.strManufacturer}',
                origValueField: 'intManufacturerId',
                store: '{manufacturer}',
                readOnly: '{readOnlyForOtherCharge}'
            },
            cboBrand: {
                value: '{current.strBrand}',
                origValueField: 'intBrandId',
                store: '{brand}',
                readOnly: '{readOnlyForOtherCharge}'
            },
            cboStatus: {
                value: '{current.strStatus}',
                store: '{itemStatuses}'
            },
            cboCategory: {
                value: '{current.strCategory}',                
                origValueField: 'intCategoryId',
                store: '{itemCategory}',
                defaultFilters: [{
                    column: 'strInventoryType',
                    value: '{current.strType}',
                    conjunction: 'and'
                }]
            },
            cboCommodity: {
                readOnly: '{readOnlyCommodity}',
                origValueField: 'intCommodityId',
                value: '{current.strCommodityCode}',
                store: '{commodity}'
            },
            chkListBundleSeparately: '{current.ysnListBundleSeparately}',

            grdUnitOfMeasure: {
                colDetailUnitMeasure: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{uomUnitMeasure}'
                    }
                },
                colDetailUnitQty: 'dblUnitQty',
                colBaseUnit: 'ysnStockUnit',
                colStockUOM: 'ysnStockUOM',
                colAllowSale: 'ysnAllowSale',
                colAllowPurchase: 'ysnAllowPurchase',
                colDetailShortUPC: {
                    dataIndex: 'strUpcCode',
                    hidden: '{readOnlyForOtherCharge}'
                },
                colDetailUpcCode: {
                    dataIndex: 'strLongUPCCode',
                    hidden: '{readOnlyForOtherCharge}'
                }
            }, 

            //------------------//
            // Bundle Items     //
            //------------------//
            grdBundle: {
                colBundleItem: {
                    dataIndex: 'strComponentItemNo',
                    editor: {
                        origValueField: 'strItemNo',
                        origUpdateField: 'strComponentItemNo',
                        store: '{bundleItem}',
                        defaultFilters: [{
                            inner: [
                                {
                                    column: 'strType',
                                    value: 'Inventory',
                                    conjunction: 'or'
                                }
                                // {
                                //     column: 'strType',
                                //     value: 'Other Charge',
                                //     conjunction: 'or'
                                // }
                            ],
                            conjunction: 'and'
                        }, 
                        {
                            column: 'intCommodityId',
                            value: '{current.intCommodityId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colBundleQuantity: {
                    dataIndex: 'dblQuantity',
                    editor: {
                        readOnly: '{current.isOptionType}'
                    }  
                },
                colBundleDescription: 'strDescription',
                colBundleUOM: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{bundleUOM}',
                        origValueField: 'intItemUOMId',
                        origUpdateField: 'intItemUnitMeasureId',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdBundle.selection.intBundleItemId}',
                            conjunction: 'or'
                        }]
                    }
                },
                colBundleMarkUpOrDown: {
                    dataIndex: 'dblMarkUpOrDown',
                    editor: {
                        readOnly: '{readOnlyOnKitType}'
                    }                    
                },
                colBundleBeginDate: {
                    dataIndex: 'dtmBeginDate',
                    editor: {
                        readOnly: '{readOnlyOnKitType}'
                    }                    
                },
                colBundleEndDate: {
                    dataIndex: 'dtmEndDate',
                    editor: {
                        readOnly: '{readOnlyOnKitType}'
                    }                    
                }
            },

            //------------------//
            // Add Ons          //
            //------------------//
            grdAddOn: {
                colAddOnItem: {
                    dataIndex: 'strAddOnItemNo',
                    editor: {
                        origValueField: 'strItemNo',
                        origUpdateField: 'strAddOnItemNo',
                        store: '{bundleItem}',
                        defaultFilters: [{
                            inner: [
                                {
                                    column: 'strType',
                                    value: 'Inventory',
                                    conjunction: 'or'
                                },
                                {
                                    column: 'strType',
                                    value: 'Other Charge',
                                    conjunction: 'or'
                                }
                            ],
                            conjunction: 'and'
                        }, 
                        {
                            column: 'intCommodityId',
                            value: '{current.intCommodityId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colAddOnDescription: 'strDescription',
                colAddOnQuantity: {
                    dataIndex: 'dblQuantity'
                },
                colAddOnUOM: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{bundleUOM}',
                        origValueField: 'intItemUOMId',
                        origUpdateField: 'intItemUOMId',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdAddOn.selection.intAddOnItemId}',
                            conjunction: 'or'
                        }]
                    }
                }
            }
        }
    },

    deleteMessage: function() {
        var win = Ext.WindowMgr.getActive();
        var itemNo = win.down("#txtItemNo").value;
        var msg = "Are you sure you want to delete this bundle, <b>" + Ext.util.Format.htmlEncode(itemNo) + "</b>?";
        return msg;
    },

    setupContext : function(options){
        var me = this,
            win = me.getView(),
            store = Ext.create('Inventory.store.Item', { pageSize: 1 });

        var grdUOM = win.down('#grdUnitOfMeasure'),
            grdBundle = win.down('#grdBundle'),
            grdAddOn = win.down('#grdAddOn');

        win.context = Ext.create('iRely.Engine', {
            window : win,
            store  : store,
            createRecord : me.createRecord,
            validateRecord : me.validateRecord,
            deleteMsg: me.deleteMessage,
            binding: me.config.binding,
            fieldTitle: 'strItemNo',
            enableAudit: true,
            enableCustomTab: true,


            enableActivity: true,
            createTransaction: Ext.bind(me.createTransaction, me),

            include: 'vyuICGetCompactItem',
            details: [
                {
                    key: 'tblICItemUOMs',
                    lazy: true, 
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdUOM,
                        deleteButton : grdUOM.down('#btnDeleteUom')
                    })
                },
                {
                    key: 'tblICItemBundles',
                    lazy: true, 
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdBundle,
                        deleteButton : grdBundle.down('#btnDeleteBundle'),
                        createRecord: me.onBundleItemCreateRecord
                    })
                },
                {
                    key: 'tblICItemAddOns',
                    lazy: true, 
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdAddOn,
                        deleteButton : grdAddOn.down('#btnDeleteAddOn'),
                        createRecord: me.onAddOnCreateRecord
                    })
                }                
            ]
        });

        return win.context;
    },

    createTransaction: function(config, action) {
        var me = this,
            current = me.getViewModel().get('current');

        action({
            strTransactionNo: current.get('strItemNo'), //Unique field
            intEntityId: current.get('intEntityId'), //Entity Associated
            dtmDate: current.get('dtmDate') // Date
        })
    },

    onBundleItemCreateRecord: function(config, action) {
        var record = Ext.create('Inventory.model.ItemBundle');
        //record.set('ysnAllowPurchase', true);
        //record.set('ysnAllowSale', true);
        action(record);
    },

    onAddOnCreateRecord: function(config, action) {
        var record = Ext.create('Inventory.model.ItemAddOn');
        action(record);
    },
    

    createRecord: function(config, action) {
        var me = this;
        var record = Ext.create('Inventory.model.Item');
        record.set('strStatus', 'Active');
        record.set('strM2MComputation', 'No');
        record.set('intM2MComputationId', 1);
        record.set('strType', 'Bundle');
        record.set('strLotTracking', 'No');
        record.set('strInventoryTracking', 'Item Level');
        record.set('ysnListBundleSeparately', false);
        record.set('strBundleType', 'Kit');
        action(record);
    },

    show : function(config) {
        "use strict";

        var me = this,
            win = this.getView();

        if (config) {
            win.show();
            var context = win.context ? win.context.initialize() : me.setupContext();

            if (config.action === 'new') {
                context.data.addRecord();
            } else {
                if (config.id) {
                    config.filters = [{
                        column: 'intItemId',
                        value: config.id
                    }];
                }
                context.data.load({
                    filters: config.filters
                });
            }
        }
    },

    validateRecord: function(config, action) {
        var win = config.window,
            current = win.viewModel.data.current;

        // scope of 'this' here is the iRely.data.Validator. 
        this.validateRecord(config, function (result){
            if (!result) return;

            var itemType = current.get('strType'); 

            // Validate the Unit of Measure. 
            // Make sure Unit Qty value of 1 is only used once.  
            var uomStore = config.viewModel.data.current.tblICItemUOMs();   
            var pricingLevelStore = config.viewModel.data.current.tblICItemPricingLevels();
            var stockKeepingTypes = ['Inventory', 'Finished Good', 'Raw Material'];     
            if(uomStore) {
                if (stockKeepingTypes.includes(itemType))
                {
                    // Validate Unique Unit Qty == 1
                    var duplicateCount = 0;
                    for (var i = 0; i < uomStore.data.items.length; i++) {
                        var u = uomStore.data.items[i];
                        duplicateCount += (!u.dummy && u.data.dblUnitQty == 1) ? 1 : 0; 
                        if (duplicateCount > 1) break; 
                    }

                    if (duplicateCount > 1){
                        iRely.Msg.showError('Please check the Unit of Measure. Only one Unit with Unit Qty equals to one is allowed.', Ext.MessageBox.OK, win);
                        action(false);
                        return;
                    }

                    // Show duplicates of Unit Qty where Unit Qty <> 1.                     
                    for (var i = 0; i < uomStore.data.items.length; i++) {
                        duplicateCount = 1; // In each iteration, initialize the duplicate counter as 1. 
                        var u = uomStore.data.items[i];
                        for (var ii = i + 1; (!u.dummy && ii < uomStore.data.items.length); ii++){
                            var uu = uomStore.data.items[ii];
                            duplicateCount += (!uu.dummy && u.data.dblUnitQty == uu.data.dblUnitQty) ? 1 : 0; 
                            if (duplicateCount > 1) {
                                var msgAction = function (button) {
                                    if (button === 'no') {
                                        action(false);
                                    }
                                    else {
                                        action(true);
                                    }
                                };
                                var msg = 'Is it intended for ' + u.get('strUnitMeasure') + " and " + uu.get('strUnitMeasure') + ' to be the same Unit Qty?'
                                iRely.Functions.showCustomDialog('question', 'yesno', msg, msgAction);
                                return;
                            }
                        }
                    }
                }
            }
            
            if(pricingLevelStore.count() > 0) {
                //Validate effective date duplicates
                for (var i = 0; i < pricingLevelStore.count(); i++){
                    var p = pricingLevelStore.data.items[i],
                        duplicateCount = 1;
                    for(var ii = i + 1; (!p.dummy && ii < pricingLevelStore.count()); ii++){
                        var pp = pricingLevelStore.data.items[ii];
                        duplicateCount += (!pp.dummy && Ext.Date.isEqual(p.data.dtmEffectiveDate, pp.data.dtmEffectiveDate)) ? 1: 0;
                        if(duplicateCount > 1) {
                            iRely.Msg.showError('Pricing levels cannot have the same effective date.', Ext.MessageBox.OK, win);
                            action(false);
                            return;
                        }
                    }
                }
            }
            action(true);                    
        });        
    },

    onInventoryTypeSelect: function(combo, record) {
        if (record.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) {

            if (record.get('strType') == 'Bundle') {
                if (current.tblICItemUOMs()) {
                    Ext.Array.each(current.tblICItemUOMs().data.items, function (uom) {
                        if (!uom.dummy) {
                            uom.set('ysnAllowPurchase', !record.get('ysnIsBasket'));
                        }
                    });
                }

                if(!current.get('ysnIsBasket')) {
                    current.set('intCommodityId', null);
                    current.set('strCommodityCode', null);
                }
            }
        }
    },

    onUOMUnitMeasureSelect: function (combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var win = grid.up('window');
        var plugin = grid.getPlugin('cepDetailUOM');
        var currentItem = win.viewModel.data.current;
        var current = plugin.getActiveRecord();
        var me = this;

        if (combo.column.itemId === 'colDetailUnitMeasure') {
            current.set('intUnitMeasureId', records[0].get('intUnitMeasureId'));
            if (currentItem.get('strType') === 'Bundle') {
                current.set('ysnAllowPurchase', !records[0].get('ysnIsBasket'));
            }
            current.set('ysnAllowSale', true);
            current.set('tblICUnitMeasure', records[0]);
        }
    },

    beforeSave: function(win){
        if (!win) return; 
        var current = win.viewModel.data.current;

        // var stockUnitExist = true; 
        // if(current){                        
        //     if (current.tblICItemUOMs()) {
        //         if (
        //             current.get('strType') != 'Other Charge'
        //             && current.get('strType') != 'Non-Inventory'
        //             && current.get('strType') != 'Service'
        //             && current.get('strType') != 'Software'
        //             && current.get('strType') != 'Comment'
        //         )
        //         {
        //             Ext.Array.each(current.tblICItemUOMs().data.items, function (itemStock) {                    
        //                 if (!itemStock.dummy) {
        //                     stockUnitExist = false;
        //                     if(itemStock.get('ysnStockUnit')){
        //                         stockUnitExist = true;
        //                         return false; 
        //                     }                            
        //                 }
        //             });
        //             if (stockUnitExist == false){
        //                 iRely.Functions.showErrorDialog("Unit of Measure setup needs to have a Stock Unit.");
        //                 return false;
        //             }            
        //         }                
        //     }        
        // }
    },


    onBundleSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepBundle');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colBundleUOM'){
            current.set('dblUnit', records[0].get('dblUnitQty'));
        }
        else if (combo.column.itemId === 'colBundleItem'){
            current.set('strDescription', records[0].get('strDescription'));
            current.set('intBundleItemId', records[0].get('intItemId'));
            current.set('strComponentItemNo', records[0].get('strItemNo'))
        }

    },

    onAddOnSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepAddOn');
        var current = plugin.getActiveRecord();
        
        if (combo.column.itemId === 'colAddOnItem'){
            current.set('strDescription', records[0].get('strDescription'));
            current.set('intAddOnItemId', records[0].get('intItemId'));
            current.set('strAddOnItemNo', records[0].get('strItemNo'));
            current.set('intItemUOMId', records[0].get('intCostUOMId'));
            current.set('strUnitMeasure', records[0].get('strCostUOM'));            
        }

        else if (combo.column.itemId === 'colAddOnUOM'){
            current.set('strUnitMeasure', records[0].get('strUnitMeasure'));
            current.set('intItemUOMId', records[0].get('intItemUOMId'));
        }

    },

    onDuplicateClick: function(button) {
        var win = button.up('window');
        var context = win.context;
        var current = win.viewModel.data.current;

        if (current) {
            iRely.Msg.showWait('Duplicating item...');
            ic.utils.ajax({
                timeout: 120000,
                url: './Inventory/api/Item/DuplicateItem',
                params: {
                    ItemId: current.get('intItemId')
                },
                method: 'Get'  
            })
            .finally(function() { iRely.Msg.close(); })
            .subscribe(
                function (successResponse) {
				    var jsonData = Ext.decode(successResponse.responseText);
                    context.configuration.store.addFilter([{ column: 'intItemId', value: jsonData.message.id }]);
                    context.configuration.paging.moveFirst();
				},
				function (failureResponse) {
                    var jsonData = Ext.decode(failureResponse.responseText);
                    iRely.Functions.showErrorDialog(jsonData.ExceptionMessage);
				}
            );
        }
    },

    onCommoditySelect: function(combo, record) {
        this.loadUOM(combo);
    },

    loadUOM: function(combo) {
        var win = combo.up('window');
        var current = win.viewModel.data.current;
        var grid = win.down('#grdUnitOfMeasure');

        if (current) {
            if (!iRely.Functions.isEmpty(current.get('intCommodityId')) && grid.getStore().data.length <= 1) {
                var cbo = win.down('#cboCommodity');
                var store = cbo.getStore();
                if (store) {
                    var commodity = store.findRecord(cbo.valueField, cbo.getValue());
                    if (commodity) {
                        var uoms = commodity.get('tblICCommodityUnitMeasures');
                        if (uoms) {
                            if (uoms.length > 0) {
                                current.tblICItemUOMs().removeAll();
                                uoms.forEach(function(uom){
                                    var newItemUOM = Ext.create('Inventory.model.ItemUOM', {
                                        intItemId : current.get('intItemId'),
                                        strUnitMeasure: uom.strUnitMeasure,
                                        intUnitMeasureId : uom.intUnitMeasureId,
                                        // dblUnitQty : uom.dblUnitQty,
                                        // ysnStockUnit : uom.ysnStockUnit,
                                        ysnAllowPurchase : true,
                                        ysnAllowSale : true,
                                        dblLength : 0.00,
                                        dblWidth : 0.00,
                                        dblHeight : 0.00,
                                        dblVolume : 0.00,
                                        dblMaxQty : 0.00,
                                        intSort : uom.intSort
                                    });
                                    current.tblICItemUOMs().add(newItemUOM);
                                });
                                grid.gridMgr.newRow.add();
                            }
                        }
                    }
                }
            }
        }
    },

    onManufacturerDrilldown: function(combo) {
        iRely.Functions.openScreen('Inventory.view.Manufacturer', {viewConfig: { modal: true }});
    },

    onBrandDrilldown: function(combo) {
        iRely.Functions.openScreen('Inventory.view.Brand', {viewConfig: { modal: true }});
    },

    onCommodityDrilldown: function(combo) {
        if (!combo) return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;
        var commodityId = current ? current.get('intCommodityId') : null; 

        if (!commodityId) {
            iRely.Functions.openScreen('Inventory.view.Commodity', { action: 'new', viewConfig: { modal: true }});
        }
        else {
            iRely.Functions.openScreen('Inventory.view.Commodity', commodityId);
        }
    },

    onCategoryDrilldown: function(combo) {
        if (!combo) return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;
        var categoryId = current ? current.get('intCategoryId') : null; 

        if (!categoryId) {
            iRely.Functions.openScreen('Inventory.view.Category', { action: 'new', viewConfig: { modal: true }});
        }
        else {
            iRely.Functions.openScreen('Inventory.view.Category', categoryId);
        }
    },


    onUPCEnterTab: function(field, e, eOpts) {
        var win = field.up('window');
        var grd = field.up('grid');
        var plugin = grd.getPlugin('cepDetailUOM');
        var record = plugin.getActiveRecord();

        if(win) {
            if (e.getKey() == e.ENTER || e.getKey() == e.TAB) {
               var task = new Ext.util.DelayedTask(function(){
                     if(field.itemId === 'txtShortUPCCode') {
                         record.set('strLongUPCCode', i21.ModuleMgr.Inventory.getFullUPCString(record.get('strUpcCode')));
                     }
                     else if(field.itemId === 'txtFullUPCCode') {
                        record.set('strUpcCode', i21.ModuleMgr.Inventory.getShortUPCString(record.get('strLongUPCCode')));
                        if(record.get('strUpcCode') !== null) {
                            record.set('strLongUPCCode', i21.ModuleMgr.Inventory.getFullUPCString(record.get('strUpcCode')));
                        }
                     }
                });

                task.delay(10);
            }
        }
    },

    onUPCShortKeyDown: function(txtfield, e, eOpts){
        if(e.keyCode >= 65 && e.keyCode <= 90){
            e.preventDefault();
            return;
        }
    },

    onStatusSelect: function(combo, records, eOpts) {
        var win = combo.up('window');
        var viewModel = win.getViewModel();
        var status = viewModel.get('current').get('strStatus');

        if(status === 'Discontinued') {
            var grid = win.down("#grdContractItem");
            Ext.each(grid.store.data.items, function(record) {
                record.set('strStatus', 'Discontinued');
            });
        }
    },

    onUOMHeaderClick: function(menu, column) {
        var grid = column.$initParent.grid;

        i21.ModuleMgr.Inventory.showScreenFromHeaderDrilldown('Inventory.view.InventoryUOM', grid, 'intUnitMeasureId');
    },    

    onBundleItemHeaderClick: function (menu, column) {
        var grid = column.$initParent.grid;

        i21.ModuleMgr.Inventory.showScreenFromHeaderDrilldown('Inventory.view.Item', grid, 'intBundleItemId');
    },

    init: function(application) {
        this.control({
            "#cboType": {
                select: this.onInventoryTypeSelect
            },
            "#cboDetailUnitMeasure": {
                select: this.onUOMUnitMeasureSelect
            },
            "#cboBundleUOM": {
                select: this.onBundleSelect
            },         
            "#txtShortUPCCode": {
                specialKey: this.onUPCEnterTab,
                keydown: this.onUPCShortKeyDown
            },
            "#txtFullUPCCode": {
                specialKey: this.onUPCEnterTab
            },
            "#btnDuplicate": {
                click: this.onDuplicateClick
            },
            "#cboBundleItem": {
                select: this.onBundleSelect
            },
            "#cboManufacturer": {
                drilldown: this.onManufacturerDrilldown
            },
            "#cboBrand": {
                drilldown: this.onBrandDrilldown
            },
            "#cboCategory": {
                drilldown: this.onCategoryDrilldown
            },
            "#cboCommodity": {
                drilldown: this.onCommodityDrilldown,
                select: this.onCommoditySelect
            },
            "#cboStatus": {
                select: this.onStatusSelect
            }, 
            "#cboAddOnItem": {
                select: this.onAddOnSelect
            },
            "#cboAddOnUOM": {
                select: this.onAddOnSelect
            }
        });
    }
});
