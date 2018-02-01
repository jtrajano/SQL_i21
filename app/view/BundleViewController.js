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
            }, 

            //--------------//
            //GL Account Tab//
            //--------------//
            grdGlAccounts: {
                colGLAccountCategory: {
                    dataIndex: 'strAccountCategory',
                    editor: {
                        store: '{accountCategory}',
                        defaultFilters: [{
                            column: 'strAccountCategoryGroupCode',
                            value: 'INV'
                        },
                        {
                            column: 'strAccountCategory',
                            value: 'Write-Off Sold',
                            conjunction: 'and',
                            condition: 'noteq'
                        },
                        {
                            column: 'strAccountCategory',
                            value: 'Revalue Sold',
                            conjunction: 'and',
                            condition: 'noteq'
                        }]
                    }
                },
                colGLAccountId: {
                    dataIndex: 'strAccountId',
                    editor: {
                        defaultFilters: [
                            {
                                column: 'strAccountCategory',
                                value: '{accountCategoryFilter}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colDescription: 'strDescription'
            },

            //-------------//
            //Location Tab //
            //-------------//
            btnEditLocation: {
                hidden: true
            },

            cboCopyLocation: {
                store: '{copyLocation}',
                defaultFilters: [{
                    column: 'intItemId',
                    value: '{current.intItemId}'
                }]
            },            

            grdLocationStore: {
                colLocationLocation: 'strLocationName',
                colLocationPOSDescription: 'strDescription',
                colLocationVendor: 'strVendorId',
                colLocationCostingMethod: 'strCostingMethod'
            },  
            
            grdItemSubLocations: {
                colsubSubLocationName: {
                    dataIndex: 'strSubLocationName',
                    editor: {
                        store: '{subLocations}',
                        origValueField: 'intCompanyLocationSubLocationId',
                        origUpdateField: 'intSubLocationId',
                        defaultFilters: [
                            {
                                column: 'intCompanyLocationId',
                                value: '{grdLocationStore.selection.intCompanyLocationId}',
                                conjunction: 'and'
                            }
                        ]
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
            grdAddOn = win.down('#grdAddOn'),
            grdGlAccounts = win.down('#grdGlAccounts'),
            grdLocationStore = win.down('#grdLocationStore'),
            grdItemSubLocations = win.down('#grdItemSubLocations');


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
                    key: 'tblICItemLocations',
                    lazy: true, 
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdLocationStore,
                        deleteButton : grdLocationStore.down('#btnDeleteLocation'),
                        position: 'none'
                    }),
                    details: [
                        {
                            key: 'tblICItemSubLocations',
                            lazy: true, 
                            component: Ext.create('iRely.grid.Manager', {
                                grid: grdItemSubLocations,
                                deleteButton : grdItemSubLocations.down('#btnDeleteItemSubLocation')
                            })
                        }
                    ]
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
                },
                {
                    key: 'tblICItemAccounts',
                    lazy: true, 
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdGlAccounts,
                        deleteButton : grdGlAccounts.down('#btnDeleteGlAccounts')
                    })
                }
            ]
        });

        var colLocationLocation = grdLocationStore.columns[0];
        colLocationLocation.renderer = function(value, opt, record) {
            return '<a style="color: #005FB2;text-decoration: none;" onMouseOut="this.style.textDecoration=\'none\'" onMouseOver="this.style.textDecoration=\'underline\'" href="javascript:void(0);">' + value + '</a>';
        };

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
                                        intItemId: current.get('intItemId'),
                                        strUnitMeasure: uom.strUnitMeasure,
                                        intUnitMeasureId: uom.intUnitMeasureId,
                                        dblUnitQty: uom.dblUnitQty,
                                        ysnStockUnit: uom.ysnStockUnit,
                                        ysnStockUOM: uom.ysnStockUOM, 
                                        ysnAllowPurchase: true,
                                        ysnAllowSale: true,
                                        dblLength: 0.00,
                                        dblWidth: 0.00,
                                        dblHeight: 0.00,
                                        dblVolume: 0.00,
                                        dblMaxQty: 0.00,
                                        intSort: uom.intSort
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

    onGLAccountSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepAccount');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colGLAccountId') {
            current.set('intAccountId', records[0].get('intAccountId'));
            current.set('strDescription', records[0].get('strDescription'));
        }
        else if (combo.column.itemId === 'colGLAccountCategory') {
            current.set('intAccountCategoryId', records[0].get('intAccountCategoryId'));
            current.set('intAccountId', null);
            current.set('strAccountId', null);
            current.set('strDescription', null);
        }
    },

    getDefaultUOMFromCommodity: function(win) {
        var vm = win.getViewModel();
        var current = win.viewModel.data.current;
        var intCommodityId = current ? current.get('intCommodityId') : null;

        if (intCommodityId) {
            var commodity = vm.storeInfo.commodityList.findRecord('intCommodityId', intCommodityId);
            if (commodity) {
                var uoms = commodity.data.tblICCommodityUnitMeasures;
                if(uoms && uoms.length > 0) {
                    var defUom = _.findWhere(uoms, { ysnDefault: true });
                    if(defUom) {
                        var itemUOMs = _.map(vm.data.current.tblICItemUOMs().data.items, function(rec) { return rec.data; });
                        var defaultUOM = _.findWhere(itemUOMs, { intUnitMeasureId: defUom.intUnitMeasureId });
                        if (defaultUOM) {
                            win.defaultUOM = defaultUOM;
                        }
                    }
                }
            }
        }
    },

    getDefaultUOM: function(win) {
        return this.getDefaultUOMFromCommodity(win);
    },

    openItemLocationScreen: function (action, window, record) {
        var win = window;
        var screenName = 'Inventory.view.ItemLocation';

        var current = win.getViewModel().data.current;
        if (action === 'edit'){
            iRely.Functions.openScreen(screenName, {
                viewConfig: {
                    listeners: {
                        close: function() {
                            var grdLocation = win.down('#grdLocationStore');
                            var vm = win.getViewModel();
                            var itemId = vm.data.current.get('intItemId');
                            var filterItem = grdLocation.store.filters.items[0];

                            filterItem.setValue(itemId);
                            filterItem.config.value = itemId;
                            filterItem.initialConfig.value = itemId;
                            grdLocation.store.load({
                                scope: win,
                                callback: function(result) {
                                    if (result) {
                                        var me = this;
                                        Ext.Array.each(result, function (location) {
                                            var prices = me.getViewModel().data.current.tblICItemPricings().data.items;
                                            var exists = Ext.Array.findBy(prices, function (row) {
                                                if (location.get('intItemLocationId') === row.get('intItemLocationId')) {
                                                    return true;
                                                }
                                            });
                                            if (!exists) {
                                                var newPrice = Ext.create('Inventory.model.ItemPricing', {
                                                    intItemId : location.get('intItemId'),
                                                    intItemLocationId : location.get('intItemLocationId'),
                                                    strLocationName : location.get('strLocationName'),
                                                    dblAmountPercent : 0.00,
                                                    dblSalePrice : 0.00,
                                                    dblMSRPPrice : 0.00,
                                                    strPricingMethod : 'None',
                                                    dblLastCost : 0.00,
                                                    dblStandardCost : 0.00,
                                                    dblAverageCost : 0.00,
                                                    dblEndMonthCost : 0.00,
                                                    intSort : location.get('intSort')
                                                });
                                                me.getViewModel().data.current.tblICItemPricings().add(newPrice);
                                            }
                                        });
                                    }
                                }
                            });
                        }
                    }
                },
                itemId: current.get('intItemId'),
                locationId: record.get('intItemLocationId'),
                action: action
            });
        }
        else if (action === 'new') {
            iRely.Functions.openScreen(screenName, {
                viewConfig: {
                    listeners: {
                        close: function() {
                            var grdLocation = win.down('#grdLocationStore');
                            var vm = win.getViewModel();
                            var itemId = vm.data.current.get('intItemId');
                            var filterItem = grdLocation.store.filters.items[0];

                            filterItem.setValue(itemId);
                            filterItem.config.value = itemId;
                            filterItem.initialConfig.value = itemId;
                            grdLocation.store.load({
                                scope: win,
                                callback: function(result) {
                                    if (result) {
                                        var me = this;
                                        Ext.Array.each(result, function (location) {
                                            var prices = me.getViewModel().data.current.tblICItemPricings().data.items;
                                            var exists = Ext.Array.findBy(prices, function (row) {
                                                if (location.get('intItemLocationId') === row.get('intItemLocationId')) {
                                                    return true;
                                                }
                                            });
                                            if (!exists) {
                                                var newPrice = Ext.create('Inventory.model.ItemPricing', {
                                                    intItemId : location.get('intItemId'),
                                                    intItemLocationId : location.get('intItemLocationId'),
                                                    strLocationName : location.get('strLocationName'),
                                                    dblAmountPercent : 0.00,
                                                    dblSalePrice : 0.00,
                                                    dblMSRPPrice : 0.00,
                                                    strPricingMethod : 'None',
                                                    dblLastCost : 0.00,
                                                    dblStandardCost : 0.00,
                                                    dblAverageCost : 0.00,
                                                    dblEndMonthCost : 0.00,
                                                    intSort : location.get('intSort')
                                                });
                                                me.getViewModel().data.current.tblICItemPricings().add(newPrice);
                                            }
                                        });
                                    }
                                }
                            });
                        }
                    }
                },
                itemId: current.get('intItemId'),
                defaultUOM: win.defaultUOM,
                action: action
            });
        }
    },    

    onAddLocationClick: function(button, e, eOpts) {
        var win = button.up('window');
        var me = win.controller;
        var vm = win.getViewModel();

        me.getDefaultUOM(win);

        if (vm.data.current.phantom === true) {
            me.saveRecord(
                win, 
                function(batch, eOpts){
                    me.openItemLocationScreen('new', win);
                    return;
                }            
            );

        }
        else {
            win.context.data.validator.validateRecord(win.context.data.configuration, function(valid) {
                if (valid) {
                    me.openItemLocationScreen('new', win);
                    return;
                }
            });
        }
    },

    onAddMultipleLocationClick: function(button, e, eOpts) {
        var win = button.up('window');
        var me = win.controller;
        var vm = win.getViewModel();
        var defaultFilters = '';

        Ext.Array.each(vm.data.current.tblICItemLocations().data.items, function(location) {
            defaultFilters += '&intLocationId<>' + location.get('intLocationId');
        });

        me.getDefaultUOM(win);

        var showAddScreen = function() {
            iRely.Functions.openScreen('GlobalComponentEngine.view.FloatingSearch',{
                searchSettings: {
                    type: 'Inventory.view.Item',
                    url: './i21/api/companylocation/search',
                    title: 'Add Item Locations',
                    controller: me,
                    scope: me,
                    showNew: false,
                    openButtonText: 'Add',
                    columns: [
                            { dataIndex : 'intCompanyLocationId', text: 'Location Id', dataType: 'numeric', defaultSort : true, hidden : true, key : true},
                            { dataIndex : 'strLocationName',text: 'Location Name', dataType: 'string', flex: 1 },
                            { dataIndex : 'strLocationType',text: 'Location Type', dataType: 'string', flex: 1 }
                    ],
                    buttons: [
                        {
                            text: 'Select All',
                            iconCls: 'select-all',
                            customControlPosition: 'start',
                            clickHandler: 'onSelectAllClick'
                        },
                        {
                            text: 'Unselect All',
                            customControlPosition: 'start',
                            clickHandler: 'onUnselectAllClick'
                        }
                    ]
                },
                viewConfig: {
                    listeners: {
                        scope: me,
                        openselectedclick: function(button, e, result) {
                            var currentVM = this.getViewModel().data.current;
                            var win = this.getView();
                    
                            Ext.each(result, function(location) {
                                var exists = Ext.Array.findBy(currentVM.tblICItemLocations().data.items, function (row) {
                                    if (location.get('intCompanyLocationId') === row.get('intCompanyLocationId')) {
                                        return true;
                                    }
                                });
                                if (!exists) {
                                    var defaultUOMId = null;
                                    if (win.defaultUOM) {
                                        defaultUOMId = win.defaultUOM.intItemUOMId;
                                    }
                                    var newRecord = {
                                        intItemId: location.data.intItemId,
                                        intLocationId: location.data.intCompanyLocationId,
                                        intIssueUOMId: defaultUOMId,
                                        intReceiveUOMId: defaultUOMId,
                                        strLocationName: location.data.strLocationName,
                                        intAllowNegativeInventory: 3,
                                        intCostingMethod: 1,
                                    };
                                    currentVM.tblICItemLocations().add(newRecord);
                    
                                    var prices = currentVM.tblICItemPricings().data.items;
                                    var exists = Ext.Array.findBy(prices, function (row) {
                                        if (newRecord.intItemLocationId === row.get('intItemLocationId')) {
                                            return true;
                                        }
                                    });
                                    if (!exists) {
                                        var newPrice = Ext.create('Inventory.model.ItemPricing', {
                                            intItemId: newRecord.intItemId,
                                            intItemLocationId: newRecord.intItemLocationId,
                                            strLocationName: newRecord.strLocationName,
                                            dblAmountPercent: 0.00,
                                            dblSalePrice: 0.00,
                                            dblMSRPPrice: 0.00,
                                            strPricingMethod: 'None',
                                            dblLastCost: 0.00,
                                            dblStandardCost: 0.00,
                                            dblAverageCost: 0.00,
                                            dblEndMonthCost: 0.00,
                                            intAllowNegativeInventory: newRecord.intAllowNegativeInventory,
                                            intCostingMethod: newRecord.intCostingMethod,
                                            intSort: newRecord.intSort
                                        });
                                        currentVM.tblICItemPricings().add(newPrice);
                                    }
                                }
                            });
                        }
                    }
                }
            });
        };

        me.saveRecord(
            win, 
            function(batch, eOpts){
                // After save
            },
            function(valid, message) {
                if(valid) {
                    showAddScreen();
                }
            }
        );        
    },    

    onLocationDoubleClick: function(view, record, item, index, e, eOpts){
        var win = view.up('window');
        var me = win.controller;
        var vm = win.getViewModel();

        if (!record){
            iRely.Functions.showErrorDialog('Please select a location to edit.');
            return;
        }

        if (vm.data.current.phantom === true) {
            me.saveRecord(
                win, 
                function(batch, eOpts){
                    me.openItemLocationScreen('edit', win, record);
                    return;
                }            
            );

        }
        else {
            win.context.data.validator.validateRecord(win.context.data.configuration, function(valid) {
                if (valid) {
                    me.openItemLocationScreen('edit', win, record);
                    return;
                }
            });
        }
    },    

    onLocationCellClick: function(view, cell, cellIndex, record, row, rowIndex, e) {
        var linkClicked = (e.target.tagName == 'A');
        var clickedDataIndex =
            view.panel.headerCt.getHeaderAtIndex(cellIndex).dataIndex;

        if (linkClicked && clickedDataIndex == 'strLocationName') {
            var win = view.up('window');
            var me = win.controller;
            var vm = win.getViewModel();

            if (!record){
                iRely.Functions.showErrorDialog('Please select a location to edit.');
                return;
            }

            if (vm.data.current.dirty === true) {
                win.context.data.saveRecord({ successFn: function(batch, eOpts){
                    me.openItemLocationScreen('edit', win, record);
                    return;
                } });

                // me.saveRecord(
                //     win, 
                //     function(batch, eOpts){
                //         me.openItemLocationScreen('edit', win, record);
                //     }
                // );                
            }
            else {
                win.context.data.validator.validateRecord(win.context.data.configuration, function(valid) {
                    if (valid) {
                        me.openItemLocationScreen('edit', win, record);
                        return;
                    }
                });
            }
        }
    },
    
    onEditLocationClick: function(button, e, eOpts) {
        var win = button.up('window');
        var me = win.controller;
        var vm = win.getViewModel();
        var grd = button.up('grid');
        var selection = grd.getSelectionModel().getSelection();

        if (selection.length <= 0){
            iRely.Functions.showErrorDialog('Please select a location to edit.');
            return;
        }

        if (vm.data.current.phantom === true) {
            // win.context.data.saveRecord({ successFn: function(batch, eOpts){
            //     me.openItemLocationScreen('edit', win, selection[0]);
            // } });
            me.saveRecord(
                win, 
                function(batch, eOpts){
                    me.openItemLocationScreen('edit', win, selection[0]);
                }            
            );               
        }
        else {
            win.context.data.validator.validateRecord(win.context.data.configuration, function(valid) {
                if (valid) {
                    me.openItemLocationScreen('edit', win, selection[0]);
                }
            });
        }
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
            },
            "#cboGLAccountId": {
                select: this.onGLAccountSelect
            },
            "#cboAccountCategory": {
                select: this.onGLAccountSelect
            },
            "#btnAddLocation": {
                click: this.onAddLocationClick
            },
            "#btnAddMultipleLocation": {
                click: this.onAddMultipleLocationClick
            },
            "#cboCopyLocation": {
                select: this.onCopyLocationSelect
            },
            "#grdLocationStore": {
                itemdblclick: this.onLocationDoubleClick,
                cellclick: this.onLocationCellClick,
            },
            "#btnEditLocation": {
                click: this.onEditLocationClick
            },

        });
    }
});
