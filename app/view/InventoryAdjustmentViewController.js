Ext.define('Inventory.view.InventoryAdjustmentViewController', {
    extend: 'Inventory.view.InventoryBaseViewController',
    alias: 'controller.icinventoryadjustment',
    requires: [
        'CashManagement.common.Text',
        'CashManagement.common.BusinessRules'
    ],

    config: {
        binding: {
            bind: {
                title: 'Inventory Adjustment - {current.strAdjustmentNo}'
            },
            btnPost: {
                hidden: '{current.ysnPosted}'
            },
            btnUnpost: {
                hidden: '{!current.ysnPosted}'
            },
            btnSave: {
                disabled: '{current.ysnPosted}'
            },
            btnDelete: {
                disabled: '{current.ysnPosted}'
            },
            btnUndo: {
                disabled: '{current.ysnPosted}'
            },
            btnAddItem: {
                disabled: '{current.ysnPosted}'
            },
            btnRemoveItem: {
                disabled: '{current.ysnPosted}'
            },
            cboLocation: {
                value: '{current.strLocationName}',
                origValueField: 'intCompanyLocationId',
                origUpdateField: 'intLocationId',
                store: '{location}',
                readOnly: '{current.ysnPosted}'
            },
            dtmDate: {
                value: '{current.dtmAdjustmentDate}',
                readOnly: '{current.ysnPosted}'
            },
            cboAdjustmentType: {
                value: '{current.intAdjustmentType}',
                store: '{adjustmentTypes}',
                readOnly: '{current.ysnPosted}'
            },
            txtAdjustmentNumber: '{current.strAdjustmentNo}',
            txtDescription: {
                value: '{current.strDescription}',
                readOnly: '{current.ysnPosted}'
            },
            grdInventoryAdjustment: {
                readOnly: '{current.ysnPosted}',

                colItemNumber: {
                    dataIndex: 'strItemNo',
                    editor: {
                        store: '{item}',
                        defaultFilters: [
                            {
                                column: 'intLocationId',
                                value: '{current.intLocationId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'strLotTracking',
                                value: '{itemNoFilter}',
                                condition: 'eq',
                                conjunction: 'and'
                            }
                        ]
                    }
                },

                colDescription: 'strItemDescription',

                colSubLocation: {
                    dataIndex: 'strSubLocation',
                    text: '{setSubLocationLabel}',
                    editor: {
                        store: '{fromSubLocation}',
                        origValueField: 'intSubLocationId',
                        origUpdateField: 'intSubLocationId',
                        defaultFilters: [
                            {
                                column: 'intItemId',
                                value: '{grdInventoryAdjustment.selection.intItemId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'intLocationId',
                                value: '{current.intLocationId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },

                colStorageLocation: {
                    dataIndex: 'strStorageLocation',
                    text: '{setStorageLocationLabel}',
                    editor: {
                        store: '{fromStorageLocation}',
                        origValueField: 'intStorageLocationId',
                        origUpdateField: 'intStorageLocationId',
                        defaultFilters: [
                            {
                                column: 'intItemId',
                                value: '{grdInventoryAdjustment.selection.intItemId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'intLocationId',
                                value: '{current.intLocationId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'intSubLocationId',
                                value: '{grdInventoryAdjustment.selection.intSubLocationId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },

                colOwnershipType: {
                    dataIndex: 'strOwnershipType',
                    editor: {
                        defaultFilters: [
                            {
                                column: 'intOwnershipType',
                                value: 4,
                                condition: 'noteq'
                            } 
                        ],
                        readOnly: '{disableOwnership}',
                        origValueField: 'intOwnershipType',
                        origUpdateField: 'intOwnershipType',
                        store: '{ownershipTypes}'
                    }
                },

                colLotNumber: {
                    dataIndex: 'strLotNumber',
                    text: '{setLotNumberLabel}',
                    editor: {
                        //store: '{lot}',
                        store: '{itemRunningQty}',
                        defaultFilters: '{runningQtyFilter}',
                        // defaultFilters: [
                        //     {
                        //         column: 'intItemId',
                        //         value: '{grdInventoryAdjustment.selection.intItemId}',
                        //         conjunction: 'and'
                        //     },
                        //     {
                        //         column: 'intLocationId',
                        //         value: '{current.intLocationId}',
                        //         conjunction: 'and'
                        //     },
                        //     {
                        //         column: 'intSubLocationId',
                        //         value: '{grdInventoryAdjustment.selection.intSubLocationId}',
                        //         conjunction: 'and',
                        //         condition: 'blk'
                        //     },
                        //     {
                        //         column: 'intStorageLocationId',
                        //         value: '{grdInventoryAdjustment.selection.intStorageLocationId}',
                        //         conjunction: 'and',
                        //         condition: 'blk'
                        //     }
                        // ],
                        readOnly: '{formulaShowLotNumberEditor}'
                    }
                },

                colNewLotNumber: {
                    dataIndex: 'strNewLotNumber',
                    hidden: '{formulaHideColumn_colNewLotNumber}',
                    text: '{setNewLotNumberLabel}'
                },

                colQuantity: {
                    dataIndex: 'dblQuantity',
                    hidden: '{formulaHideColumn_colQuantity}'
                },

                colNewQuantity: {
                    dataIndex: 'dblNewQuantity',
                    hidden: '{formulaHideColumn_colNewQuantity}',
                    text: '{setNewQuantityLabel}'
                },

                colAdjustByQuantity: {
                    dataIndex: 'dblAdjustByQuantity',
                    hidden: '{formulaHideColumn_colAdjustByQuantity}',
                    text: '{setAdjustByQuantityLabel}'
                },

                colNewSplitLotQuantity: {
                    dataIndex: 'dblNewSplitLotQuantity',
                    hidden: '{formulaHideColumn_colNewSplitLotQuantity}',
                    text: '{setNewSplitLotQuantityLabel}'
                },

                colUOM: {
                    dataIndex: 'strItemUOM',
                    hidden: '{formulaHideColumn_colUOM}',
                    editor: {
                        //store: '{itemUOM}',
                        store: '{itemRunningQty}',
                        defaultFilters: '{runningQtyFilter}',
                        origValueField: 'intItemUOMId',
                        readOnly: '{formulaShowItemUOMEditor}'
                        // defaultFilters: [

                        //     {
                        //         column: 'intLocationId',
                        //         value: '{current.intLocationId}',
                        //         conjunction: 'and'
                        //     },
                        //    /* {
                        //         column: 'intLocationId',
                        //         value: '',
                        //         conjunction: 'or',
                        //         condition: 'blk'
                        //     },*/
                        //     {
                        //         column: 'intItemId',
                        //         value: '{grdInventoryAdjustment.selection.intItemId}',
                        //         conjunction: 'and'
                        //     }//,
                        //     // {
                        //     //     column: 'dblOnHand',
                        //     //     value: '{getOnHandFilterValue}',
                        //     //     conjunction: 'and',
                        //     //     condition: 'gt'
                        //     // }
                        // ],
                    }
                },

                colNewUOM: {
                    dataIndex: 'strNewItemUOM',
                    hidden: '{formulaHideColumn_colNewUOM}',
                    text: '{setNewUOMLabel}',
                    editor: {
                        store: '{newItemUOM}',
                        defaultFilters: [
                            {
                                column: 'intItemId',
                                value: '{grdInventoryAdjustment.selection.intItemId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },

                colNetWeight: {
                    dataIndex: 'dblWeight',
                    hidden: '{formulaHideColumn_colNetWeight}'
                },

                colNewNetWeight: {
                    dataIndex: 'dblNewWeight',
                    hidden: '{formulaHideColumn_colNewNetWeight}'
                },

                colWeightUOM: {
                    dataIndex: 'strWeightUOM',
                    hidden: '{formulaHideColumn_colWeightUOM}',
                    editor: {
                        store: '{weightUOM}',
                        defaultFilters: [
                            {
                                column: 'intItemId',
                                value: '{grdInventoryAdjustment.selection.intItemId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },

                colNewWeightUOM: {
                    dataIndex: 'strNewWeightUOM',
                    hidden: '{formulaHideColumn_colNewWeightUOM}',
                    editor: {
                        store: '{newWeightUOM}',
                        defaultFilters: [
                            {
                                column: 'intItemId',
                                value: '{grdInventoryAdjustment.selection.intItemId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },

                colWeightPerQty: {
                    dataIndex: 'dblWeightPerQty',
                    hidden: '{formulaHideColumn_colWeightPerQty}'
                },

                colNewWeightPerQty: {
                    dataIndex: 'dblNewWeightPerQty',
                    hidden: '{formulaHideColumn_colNewWeightPerQty}'
                },

                colUnitCost: {
                    dataIndex: 'dblCost',
                    hidden: '{formulaHideColumn_colUnitCost}'
                },

                colNewUnitCost: {
                    dataIndex: 'dblNewCost',
                    hidden: '{formulaHideColumn_colNewUnitCost}',
                    editor: {
                        readOnly: '{formulaShowNewCostEditor}'
                    }
                },

                colNewItemNumber: {
                    dataIndex: 'strNewItemNo',
                    hidden: '{formulaHideColumn_colNewItemNumber}',
                    text: '{setNewItemNumberLabel}',
                    editor: {
                        store: '{newItem}',
                        defaultFilters: [
                            {
                                column: 'intLocationId',
                                value: '{current.intLocationId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },

                colNewItemDescription: {
                    dataIndex: 'strNewItemDescription',
                    hidden: '{formulaHideColumn_colNewItemDescription}'
                },

                colExpiryDate: {
                    dataIndex: 'dtmExpiryDate',
                    hidden: '{formulaHideColumn_colExpiryDate}'
                },

                colNewExpiryDate: {
                    dataIndex: 'dtmNewExpiryDate',
                    hidden: '{formulaHideColumn_colNewExpiryDate}',
                    text: '{setNewExpiryDateLabel}'
                },

                colLotStatus: {
                    dataIndex: 'strLotStatus',
                    hidden: '{formulaHideColumn_colLotStatus}'
                },

                colNewLotStatus: {
                    dataIndex: 'strNewLotStatus',
                    hidden: '{formulaHideColumn_colNewLotStatus}',
                    text: '{setNewLotStatusLabel}',
                    editor: {
                        store: '{newLotStatus}'
                    }
                },

                colLineTotal: {
                    dataIndex: 'dblLineTotal',
                    hidden: '{formulaHideColumn_colLineTotal}'
                },

                colNewLocation: {
                    dataIndex: 'strNewLocation',
                    hidden: '{formulaHideColumn_colNewLocation}',
                    text: '{setNewLocationLabel}',
                    editor: {
                        store: '{newLocation}',
                        defaultFilters: [
                            {
                                column: 'intCompanyLocationId',
                                value: '{current.intLocationId}',
                                conjunction: 'and',
                                condition: 'noteq'
                            }
                        ]
                    }
                },

                colNewSubLocation: {
                    dataIndex: 'strNewSubLocation',
                    hidden: '{formulaHideColumn_colNewSubLocation}',
                    text: '{setNewSubLocationLabel}',
                    editor: {
                        store: '{newSubLocation}',
                        defaultFilters: [
                            {
                                column: 'intCompanyLocationId',
                                value: '{grdInventoryAdjustment.selection.intNewLocationId}',
                                conjunction: 'and',
                                condition: 'eq'
                            },
                            {
                                column: 'strClassification',
                                value: 'Inventory',
                                conjunction: 'and'
                            }
                        ]
                    }
                },

                colNewStorageLocation: {
                    dataIndex: 'strNewStorageLocation',
                    hidden: '{formulaHideColumn_colNewStorageLocation}',
                    text: '{setNewStorageLocationLabel}',
                    editor: {
                        store: '{newStorageLocation}',
                        defaultFilters: [
                            {
                                column: 'intLocationId',
                                value: '{grdInventoryAdjustment.selection.intNewLocationId}',
                                conjunction: 'and',
                                condition: 'blk'
                            },
                            {
                                column: 'intSubLocationId',
                                value: '{grdInventoryAdjustment.selection.intNewSubLocationId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },

                colOwner: {
                    dataIndex: 'strOwnerName',
                    hidden: '{formulaHideColumn_colOwner}'
                },

                colNewOwner: {
                    dataIndex: 'strNewOwnerName',
                    hidden: '{formulaHideColumn_colNewOwner}',
                    text: '{setNewOwnerNameLabel}',
                    editor: {
                        store: '{newOwner}',
                        defaultFilters: [
                            {
                                column: 'intItemId',
                                value: '{grdInventoryAdjustment.selection.intItemId}',
                                conjunction: 'and'
                            }
                        ]                        
                    }
                }
            },
            btnViewItem: {
                hidden: true
            },
            pgePostPreview: {
                title: '{pgePreviewTitle}'
            } 
        }
    },

    setupContext: function (options) {
        "use strict";
        var me = this,
            win = me.getView(),
            store = Ext.create('Inventory.store.Adjustment', { pageSize: 1 }),
            grdInventoryAdjustment = win.down('#grdInventoryAdjustment');

        win.context = Ext.create('iRely.Engine', {
            window: win,
            store: store,
            enableActivity: true,
            createTransaction: Ext.bind(me.createTransaction, me),
            enableAudit: true,
            //include: 'vyuICGetInventoryAdjustment, tblICInventoryAdjustmentDetails.vyuICGetInventoryAdjustmentDetail',
            onSaveClick: me.saveAndPokeGrid(win, grdInventoryAdjustment),
            createRecord: me.createRecord,
            validateRecord: me.validateRecord,
            binding: me.config.binding,
            attachment: Ext.create('iRely.attachment.Manager', {
                type: 'Inventory.InventoryAdjustment',
                window: win
            }),
            details: [
                {
                    key: 'tblICInventoryAdjustmentDetails',
                    lazy: true,
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdInventoryAdjustment,
                        deleteButton: win.down('#btnRemoveItem')
                    })
                }
            ]
        });

        // var colItemNo = grdInventoryAdjustment.columns[0];
        // var colStorageLocation = grdInventoryAdjustment.columns[2];
        // var colStorageUnit = grdInventoryAdjustment.columns[3];

        // colItemNo.renderer = this.onRenderDrilldown;
        // colStorageLocation.renderer = this.onRenderDrilldown;
        // colStorageUnit.renderer = this.onRenderDrilldown;
        return win.context;
    },

    onLocationDrilldown: function(combo) {
        iRely.Functions.openScreen('i21.view.CompanyLocation', { 
            filters: [
                {
                    column: 'strLocationName',
                    value: combo.getRawValue()
                }
            ],
            viewConfig: { modal: true } 
        });
    },

    onItemHeaderClick: function (menu, column) {
        // var grid = column.initOwnerCt.grid; 
        var grid = column.$initParent.grid;
        if(grid && grid.selection) {
            if (grid.itemId === 'grdInventoryAdjustment') {
                i21.ModuleMgr.Inventory.showScreenFromHeaderDrilldown('Inventory.view.Item', grid, 'intItemId');
            }
        } else {
            iRely.Functions.showErrorDialog('Please make a selection.');
        }
    },

    onStorageLocationHeaderClick: function (menu, column) {
        // var grid = column.initOwnerCt.grid; 
        var grid = column.$initParent.grid;
        var win = grid.up('window');
        var combo = win.down('#cboLocation');

        if(grid && grid.selection) {
            if (grid.itemId === 'grdInventoryAdjustment') {
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
        } else {
            iRely.Functions.showErrorDialog('Please make a selection.');
        }
    },

    onStorageUnitHeaderClick: function (menu, column) {
        // var grid = column.initOwnerCt.grid; 
        var grid = column.$initParent.grid;
        if(grid && grid.selection) {
            if (grid.itemId === 'grdInventoryAdjustment') {
                i21.ModuleMgr.Inventory.showScreenFromHeaderDrilldown('Inventory.view.StorageUnit', grid, 'intStorageLocationId');
            }
        } else {
            iRely.Functions.showErrorDialog('Please make a selection.');
        }
    },

    onRenderDrilldown: function (value, column, record, rowIndex, dataIndex) {
        var id = null;

        if(dataIndex === 1) {
            id = record.get('intItemId');
        } else if (dataIndex === 3) {
            id = record.get('intSubLocationId');
        } else if (dataIndex === 4) {
            id = record.get('intStorageLocationId');
        }

        if(id !== null) {
            return "<a id=\"_drilldown-" + id.toString() + "\" style=\"color: #005FB2;text-decoration: none;\" onMouseOut=\"this.style.textDecoration='none'\" onMouseOver=\"this.style.textDecoration='underline'\" href=\"javascript:void(0);\">" + value + "</a>";
        }
        
        return value;
    },

    onCellClick: function (view, cell, cellIndex, record, row, rowIndex, e) {
        var linkClicked = (e.target.tagName == 'A');
        var clickedDataIndex =
            view.panel.headerCt.getHeaderAtIndex(cellIndex).dataIndex;

        if (linkClicked) {
            var win = view.up('window');
            var me = win.controller;
            var vm = win.getViewModel();

            if (!record) {
                //iRely.Functions.showErrorDialog('Please select a location to edit.');
                return;
            }

            var id = null, screen = null;

            if(clickedDataIndex === 'strItemNo') {
                id = record.get('intItemId');
                screen = 'Inventory.view.Item';
            } else if (clickedDataIndex === 'strSubLocation') {
                id = record.get('intSubLocationId');
                screen = 'i21.view.CompanyLocation';
            } else if (clickedDataIndex === 'strStorageLocation') {
                id = record.get('intStorageLocationId');
                screen = 'Inventory.view.StorageUnit';
            }

            if(id !== null) {
                if (vm.data.current.phantom === true) {
                    win.context.data.saveRecord({
                        successFn: function (batch, eOpts) {
                            iRely.Functions.openScreen(screen, id);
                            return;
                        }
                    });
                }
                else {
                    win.context.data.validator.validateRecord(win.context.data.configuration, function (valid) {
                        if (valid) {
                            iRely.Functions.openScreen(screen, id);
                            return;
                        }
                    });
                }
            }
        }
    },

    createTransaction: function(config, action) {
        var me = this,
            current = me.getViewModel().get('current');

        action({
            strTransactionNo: current.get('strAdjustmentNo'), //Unique field
            intEntityId: current.get('intEntityId'), //Entity Associated
            dtmDate: current.get('dtmDate') // Date
        })
    },


    show: function (config) {
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
                    config.filters = [
                        {
                            column: 'intInventoryAdjustmentId',
                            value: config.id
                        }
                    ];
                }
                context.data.load({
                    filters: config.filters
                });
            }
        }
    },

    createRecord: function (config, action) {
        
        var newRecord = Ext.create('Inventory.model.Adjustment', {
            intAdjustmentType: 1,
            intLocationId: iRely.Configuration.Security.CurrentDefaultLocation,
            strLocationName: iRely.Configuration.Security.CurrentDefaultLocationName
        });

        action(newRecord);
    },

    validateRecord: function (config, action) {
        var win = config.window;
        this.validateRecord(config, function (result) {
           if (result) {
                var controller = config.window.controller;
                var vm = config.window.viewModel;
                var current = vm.data.current;
                var win = config.window;
                var colNewUnitCost = win.down('#colNewUnitCost');

                if(current) {
                    var lineItems = current.tblICInventoryAdjustmentDetails().data.items,
                        countLineItems = lineItems.length,
                        currentLotId = null,
                        currentItemIndex = 0,
                        countLineNumber = 0,
                        duplicateLotDetected = 0;
                        hasNonZero = true,
                        eachLotId = [];
                    //Validate Lot Id
                    if(countLineItems > 1) {
                        Ext.Array.each(current.tblICInventoryAdjustmentDetails().data.items, function (item) {
                            if (!item.dummy) {
                                eachLotId[currentItemIndex] = item.get('intLotId');
                                if(item.get('dblAdjustByQuantity') && item.get('dblAdjustByQuantity') !== 0)
                                    hasNonZero = false;

                                currentItemIndex++;
                            }
                        });

                        for (var i=0; i < countLineItems-1; i++) {
                            currentLotId = eachLotId[i];

                            for (var j=0; j < countLineItems-1; j++) {
                                if(i !== j) {
                                    if(eachLotId[j] == currentLotId && currentLotId !== null) {
                                        duplicateLotDetected = 1;
                                        j = countLineItems;
                                        i = countLineItems;
                                    }
                                }
                            }
                        }

                        if(hasNonZero && current.get('intAdjustmentType') === 8) {
                            iRely.Functions.showErrorDialog("None of the items have specified a non-zero value for 'Adjustment Qty By' field.");
                            return;
                        }

                        if(duplicateLotDetected == 1) {
                            iRely.Functions.showErrorDialog("You cannot adjust the same lot multiple times.");
                            return;
                        }
                    }

                    
                   /* var lotIds = [];
                    _.each(lineItems.data.items, function (value, key, list) {
                        if(!value.dummy)
                            lotIds.push(value.data.intLotId);
                    });
                    if(_.size(lotIds) !== _.size(_.uniq(lotIds))) {
                        iRely.Functions.showErrorDialog("You cannot adjust the same lot multiple times.");
                        return;
                    }*/
                    var zeroCostLineItems = _.filter(lineItems, function(x) { 
                        return !x.dummy 
                            && (!iRely.Functions.isEmpty(x.get('dblNewCost')) || x.modified.dblNewCost !== null) 
                            && (x.get('dblNewCost') === 0 && x.get('intOwnershipType') === 1); 
                    });

                    var zeroCost = (zeroCostLineItems && zeroCostLineItems.length > 0);

                    if (zeroCost && colNewUnitCost.hidden == false) {
                        var msgAction = function (button) {
                            if (button === 'yes') {
                                action(true);
                            }
                            else {
                                win.down("#btnPost").enable();
                                action(false);
                            }
                        };
                        iRely.Functions.showCustomDialog('question', 'yesnocancel', 'One of your line items has a zero (0) New Unit Cost.<br>Are you sure you want to set your new unit cost to zero(0)?', msgAction);
                    }
                    else {
                        action(true);
                    }
                }
                else {
                     action(true);
                }
            }
        });
    },

    onAdjustmentDetailSelect: function (combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var record = records[0];

        var win = combo.up('window');
        var me = win.controller;
        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();

        if (combo.itemId === 'cboItemNo') {

            // Populate the default data.
            current.set('intItemId', record.get('intItemId'));
            current.set('strItemDescription', record.get('strDescription'));
            //current.set('dblCost', record.get('dblLastCost'));
            //current.set('dblNewCost', record.get('dblLastCost'));
            
            var strLotTracking = record.get('strLotTracking');
            current.set('strLotTracking', strLotTracking);

            // Check if selected item lot-tracking = NO.
            // Non Lot items will need to use stock UOM.

            // if (strLotTracking == 'No') {
            //     current.set('intItemUOMId', record.get('intStockUOMId'));
            //     current.set('strItemUOM', record.get('strStockUOM'));
            //     current.set('dblItemUOMUnitQty', record.get('dblStockUnitQty'));
            //     current.set('dblQuantity', record.get('dblStockUnitQty'));

            //     me.getStockQuantity(current, win);
            // }
            // else {
                current.set('intItemUOMId', null);
                current.set('strItemUOM', null);
                current.set('dblItemUOMUnitQty', null);
            //}

            // Clear the values for the following fields:
            current.set('strOwnershipType', 'Own');
            current.set('intOwnershipType', 1);
            current.set('strSubLocation', null);
            current.set('strStorageLocation', null);
            current.set('intLotId', null);
            current.set('strLotNumber', null);
            current.set('intNewLotId', null);
            current.set('strNewLotNumber', null);
            current.set('dblAdjustByQuantity', null);
            current.set('dblNewQuantity', null);
            current.set('intNewItemUOMId', null);
            current.set('dblNewItemUOMUnitQty', null);
            current.set('strNewItemUOM', null);
            current.set('dblWeight', null);
            current.set('dblNewWeight', null);
            current.set('intWeightUOMId', null);
            current.set('strWeightUOM', null);
            current.set('intNewWeightUOMId', null);
            current.set('strNewWeightUOM', null);
            current.set('dblWeightPerQty', null);
            current.set('dblNewWeightPerQty', null);
            current.set('dblLineTotal', 0.00);

            // Set the editor for Lot and UOM
            var cboLotNumber = win.down('#cboLotNumber');
            var cboUOM = win.down('#cboUOM');

            if (strLotTracking == 'No') {
                if (cboLotNumber) cboLotNumber.setReadOnly(true);
                if (cboUOM) cboUOM.setReadOnly(false);
            }
            else {
                if (cboLotNumber) cboLotNumber.setReadOnly(false);
                if (cboUOM) cboUOM.setReadOnly(true);
            }

        }
        else if (combo.itemId === 'cboSubLocation') {
            current.set('intSubLocationId', record.get('intCompanyLocationSubLocationId'));
            //me.getStockQuantity(current, win);
            current.set('dblItemUOMUnitQty', null);
            current.set('intLotId', null);
            current.set('strLotNumber', null);
            current.set('intNewLotId', null);
            current.set('strNewLotNumber', null);
            current.set('dblAdjustByQuantity', null);
            current.set('dblNewQuantity', null);
            current.set('dblNewCost', null);
            current.set('intNewItemUOMId', null);
            current.set('dblNewItemUOMUnitQty', null);
            current.set('strNewItemUOM', null);
            current.set('dblWeight', null);
            current.set('dblNewWeight', null);
            current.set('intWeightUOMId', null);
            current.set('strWeightUOM', null);
            current.set('intNewWeightUOMId', null);
            current.set('strNewWeightUOM', null);
            current.set('dblWeightPerQty', null);
            current.set('dblNewWeightPerQty', null);
            current.set('dblLineTotal', 0.00);

            current.set('strStorageLocation', null);
            current.set('intStorageLocationId', null);
            current.set('intSubLocationId', records[0].get('intSubLocationId'));
            current.set('dblQuantity', null);
            current.set('intItemUOMId', null);
            current.set('strItemUOM', null);
        }
        else if (combo.itemId === 'cboStorageLocation') {
            current.set('intStorageLocationId', record.get('intStorageLocationId'));
           // me.getStockQuantity(current, win);
            current.set('dblItemUOMUnitQty', null);
            current.set('intLotId', null);
            current.set('strLotNumber', null);
            current.set('intNewLotId', null);
            current.set('strNewLotNumber', null);
            current.set('dblAdjustByQuantity', null);
            current.set('dblNewQuantity', null);
            current.set('dblNewCost', null);
            current.set('intNewItemUOMId', null);
            current.set('dblNewItemUOMUnitQty', null);
            current.set('strNewItemUOM', null);
            current.set('dblWeight', null);
            current.set('dblNewWeight', null);
            current.set('intWeightUOMId', null);
            current.set('strWeightUOM', null);
            current.set('intNewWeightUOMId', null);
            current.set('strNewWeightUOM', null);
            current.set('dblWeightPerQty', null);
            current.set('dblNewWeightPerQty', null);
            current.set('dblLineTotal', 0.00);

            // current.set('strSubLocation', records[0].get('strSubLocationName'));
            // current.set('intSubLocationId', records[0].get('intSubLocationId'));
            current.set('intStorageLocationId', records[0].get('intStorageLocationId'));
            current.set('dblQuantity', null);
            current.set('intItemUOMId', null);
            current.set('strItemUOM', null);
        }

        else if (combo.itemId === 'cboNewItemNo') {
            current.set('intNewItemId', record.get('intItemId'));
            current.set('strNewItemDescription', record.get('strDescription'));
        }
        else if (combo.itemId === 'cboLotNumber') {
            var iowt = record.get('intOwnershipType');

            current.set('intLotId', record.get('intLotId'));
            current.set('dblQuantity', iowt == 1 ? record.get('dblRunningAvailableQty') : record.get('dblStorageAvailableQty'));
            current.set('dblWeight', record.get('dblWeight'));
            current.set('dblCost', record.get('dblCost') * record.get('dblUnitQty'));
            current.set('dblWeightPerQty', record.get('dblWeightPerQty'));
            current.set('intItemUOMId', record.get('intItemUOMId'));
            current.set('dblItemUOMUnitQty', record.get('dblItemUOMUnitQty'));
            current.set('strItemUOM', record.get('strItemUOM'));
            current.set('strWeightUOM', record.get('strWeightUOM'));
            current.set('intWeightUOMId', record.get('intWeightUOMId'));
            current.set('strLotStatus', record.get('strLotStatus'));
            current.set('intLotStatusId', record.get('intLotStatusId'));
            current.set('dtmExpiryDate', record.get('dtmExpiryDate'));
            current.set('intSubLocationId', record.get('intSubLocationId'));
            current.set('intStorageLocationId', record.get('intStorageLocationId'));
            current.set('strSubLocation', record.get('strSubLocationName'));
            current.set('strStorageLocation', record.get('strStorageLocationName'));
            current.set('strOwnerName', record.get('strOwnerName'));
            current.set('intItemOwnerId', record.get('intItemOwnerId'));
            current.set('dblLineTotal', 0.00);

            // Clear the values for the following fields:
            current.set('dblAdjustByQuantity', null);
            current.set('dblNewQuantity', null);
            current.set('dblNewWeight', null);
            current.set('dblNewCost', record.get('dblCost') * record.get('dblItemUOMUnitQty'));
            current.set('dblNewWeightPerQty', null);
            current.set('intNewItemUOMId', null);
            current.set('dblNewItemUOMUnitQty', null);
            current.set('strNewItemUOM', null);
            current.set('intNewWeightUOMId', null);
            current.set('strNewWeightUOM', null);
            current.set('intNewLotStatusId', null);
            current.set('strNewLotStatus', null);
            current.set('dtmNewExpiryDate', null);
            current.set('intNewLocationId', null);
            current.set('strNewLocation', null);
            current.set('intNewSubLocationId', null);
            current.set('strNewSubLocation', null);
            current.set('intNewStorageLocationId', null);
            current.set('strNewStorageLocation', null);

            current.set('intOwnershipType', iowt);
            current.set('strOwnershipType', iowt === 1 ? 'Own' : 'Storage');
            
        }
        else if (combo.itemId === 'cboNewUOM') {
            // Auto-calculate a new cost.
            var unitCost = current.get('dblCost')
                , newUnitCost = current.get('dblNewCost')
                , dblNewItemUOMUnitQty = record.get('dblUnitQty');

            if (Ext.isNumeric(newUnitCost) && Ext.isNumeric(unitCost) && Ext.isNumeric(dblNewItemUOMUnitQty)) {
                current.set('dblNewCost', unitCost * dblNewItemUOMUnitQty);
            }
            current.set('intNewItemUOMId', record.get('intItemUOMId'));
            current.set('dblNewItemUOMUnitQty', record.get('dblUnitQty'));
        }
        else if (combo.itemId === 'cboOwnershipType') {
            me.getStockQuantity(current, win);
        }
        else if (combo.itemId === 'cboUOM') {
            // Recalculate the unit cost
            var currentUnitCost = current.get('dblCost') ? current.get('dblCost') : record.get('dblCost')
                , currentItemUOMUnitQty = current.get('dblItemUOMUnitQty')
                //, selectedUnitCost = record.get('dblCost')
                , selectedItemUOMUnitQty = record.get('dblUnitQty')
                , selectedOnHandQty = record.get('dblRunningAvailableQty')
                , selectedOnStorageQty = record.get('dblStorageAvailableQty')
                , newUnitCost;

            if (Ext.isNumeric(currentUnitCost)
                && Ext.isNumeric(selectedItemUOMUnitQty)
                ) {
                if (Ext.isNumeric(currentItemUOMUnitQty) && currentItemUOMUnitQty != 0) {
                    newUnitCost = (currentUnitCost / currentItemUOMUnitQty) * selectedItemUOMUnitQty;
                }
                else {
                    newUnitCost = currentUnitCost * selectedItemUOMUnitQty;
                }
            }

            current.set('dblCost', newUnitCost);
            current.set('dblNewCost', newUnitCost);
//            current.set('dblQuantity', selectedOnHandQty);
            current.set('intItemUOMId', record.get('intItemUOMId'));
            current.set('dblItemUOMUnitQty', selectedItemUOMUnitQty);

            // Recalculate the new quantity
            var adjustByQuantity = current.get('dblAdjustByQuantity')
            newQty = null;

            var qty = selectedOnHandQty;
            if(current.get('intOwnershipType') === 2)
                qty = selectedOnStorageQty;
            if (Ext.isNumeric(qty) && Ext.isNumeric(adjustByQuantity)) {
                newQty = qty + adjustByQuantity;
            }

            current.set('dblNewQuantity', newQty);

            //Set Sub and Storage Locations
            //if(iRely.Functions.isEmpty(record.get('intItemStockUOMId'))) {
            current.set('intSubLocationId', record.get('intSubLocationId'));
            current.set('strSubLocation', record.get('strSubLocationName'));
            current.set('intStorageLocationId', record.get('intStorageLocationId'));
            current.set('strStorageLocation', record.get('strStorageLocationName'));
            //}

            //Set Available Quantity Per UOm
            current.set('dblQuantity', qty);
        }

        else if (combo.itemId === 'cboNewWeightUOM') {
            current.set('intNewWeightUOMId', record.get('intItemUOMId'));
        }
        else if (combo.itemId === 'cboNewLotStatus') {
            current.set('intNewLotStatusId', record.get('intLotStatusId'));
        }
        else if (combo.itemId === 'cboNewLocation') {
            current.set('intNewLocationId', record.get('intCompanyLocationId'));

            // Blank out the new sub location and storage location
            current.set('intNewSubLocationId', null);
            current.set('intNewStorageLocationId', null);
            current.set('strNewSubLocation', null);
            current.set('strNewStorageLocation', null);
        }
        else if (combo.itemId === 'cboNewSubLocation') {
            current.set('intNewSubLocationId', record.get('intCompanyLocationSubLocationId'));

            // Blank out the new sub storage location
            current.set('intNewStorageLocationId', null);
            current.set('strNewStorageLocation', null);

            // Specify the new location as well
            current.set('intNewLocationId', record.get('intCompanyLocationId'));
            current.set('strNewLocation', record.get('strLocationName'));
        }
        else if (combo.itemId === 'cboNewStorageLocation') {
            current.set('intNewStorageLocationId', record.get('intStorageLocationId'));

            // Specify the new location and sub location as well.
            current.set('intNewLocationId', record.get('intLocationId'));
            current.set('strNewLocation', record.get('strLocationName'));

            current.set('intNewSubLocationId', record.get('intSubLocationId'));
            current.set('strNewSubLocation', record.get('strSubLocationName'));
        }
        else if (combo.itemId === 'cboNewOwner') {
            current.set('intNewItemOwnerId', record.get('intItemOwnerId'));
        }        
    },

    getStockQuantity: function (record, win) {
        var vm = win.viewModel;
        var current = vm.data.current;
        var locationId = current.get('intLocationId'),
            itemId = record.get('intItemId'),
            subLocationId = record.get('intSubLocationId'),
            storageLocationId = record.get('intStorageLocationId'),
            asOfDate = Ext.Date.format(current.get('dtmAdjustmentDate'),'Y-m-d'),
            ysnLotTracked = record.get('strLotTracking') !== 'No' ? true : false;
        
        var qty = 0,
            cost = 0;

        var filters = [
            {
                column: 'intItemId',
                value: itemId,
                condition: 'eq',
                conjunction: 'and'
            },
            {
                column: 'dtmAsOfDate',
                value: asOfDate,
                condition: 'lte',
                conjunction: 'and'
            },{
                column: 'intLocationId',
                value: locationId,
                condition: 'eq',
                conjunction: 'and'
            }
        ];

        if(subLocationId && storageLocationId){
            filters.push({ column: 'intSubLocationId', value: subLocationId, condition: 'eq', conjunction: 'and' },
                { column: 'intStorageLocationId', value: storageLocationId, condition: 'eq', conjunction: 'and' });

            Inventory.Utils.ajax({
                timeout: 120000,   
                url: './inventory/api/item/getitemrunningstock',
                params: {
                    filter: iRely.Functions.encodeFilters(filters)
                } 
            })
            .map(function(x) { return Ext.decode(x.responseText); })
            .subscribe(
                function(data) {
                    if (data.success) {
                        if (data.data.length > 0) {
                            var stockRecord = data.data[0];
                            qty = record.get('intOwnershipType') === 1 ? stockRecord.dblRunningAvailableQty : stockRecord.dblStorageAvailableQty;
                            cost = stockRecord.dblCost;
                        }
                    }
                    else {
                        iRely.Functions.showErrorDialog(data.message.statusText);
                    }

                    record.set('dblQuantity', qty);
                    var adjustByQuantity = record.get('dblAdjustByQuantity')
                    var newQty = null;

                    if (Ext.isNumeric(qty) && Ext.isNumeric(adjustByQuantity)) {
                        newQty = qty + adjustByQuantity;
                    }
                    record.set('dblNewQuantity', newQty); 

                    if(ysnLotTracked) {
                        record.set('intLotId', stockRecord.intLotId);
                        record.set('strLotNumber', stockRecord.strLotNumber);
                        record.set('intSubLocationId', stockRecord.intSubLocationId);
                        record.set('strSubLocation', stockRecord.strSubLocationName);
                        record.set('intStorageLocationId', stockRecord.intStorageLocationId);
                        record.set('strStorageLocation', stockRecord.strStorageLocationName);
                    }
                },
                function(error) {
                    var json = Ext.decode(error.responseText);
                    iRely.Functions.showErrorDialog(json.ExceptionMessage);
                }
            );
        }
    },

    /**
     * A helper function. It will return the column object from the grid
     * using the data index.
     *
     * Using the column index is not reliable since it can be changed during runtime.
     * The use of data index is more reliable.
     *
     * @param grid
     * @param dataIndex
     * @returns {*}
     */
    getGridColumnByDataIndex: function (grid, dataIndex) {
        gridColumns = grid.headerCt.getGridColumns();
        for (var i = 0; i < gridColumns.length; i++) {
            if (gridColumns[i].dataIndex == dataIndex) {
                return gridColumns[i];
            }
        }
    },

    /**
     * This function is going to disable the other options.
     * Allowed adjustment type for now is: Quantity Change
     * Remove this function if we can now support the other
     * adjustment types.
     *
     * @param combo
     * @param record
     * @returns {boolean}
     */
    onAdjustmentTypeBeforeSelect: function (combo, record) {
        var QuantityChange = 1;
        var UOMChange = 2;
        var ItemChange = 3;
        var LotStatusChange = 4;
        var SplitLot = 5;
        var ExpiryDateChange = 6;
        var LotMerge = 7;
        var LotMove = 8;
        var LotOwnerChange = 9;

        var data = record.getData();
        var adjustmentTypeId;
        if (data && (adjustmentTypeId = data.intAdjustmentTypeId)) {

            switch (adjustmentTypeId) {
                case QuantityChange:
                case LotStatusChange:
                case ExpiryDateChange:
                case SplitLot:
                case LotMerge:
                case LotMove:
                case ItemChange:
                case LotOwnerChange: 
                    break;
                default:
                    var msgBox = iRely.Functions;
                    msgBox.showCustomDialog(
                        msgBox.dialogType.ERROR,
                        msgBox.dialogButtonType.OK,
                            data.strDescription + ' is not yet supported.'
                    );
                    return false;
            }

        }
        return true;
    },

    calculateLineTotal: function (newQuantity, newCost, record) {
        var lineTotal = 0.00
            , originalQuantity = 0.00
            , originalCost = 0.00
            , cost;


        if (record) {
            // Get the new quantity.
            newQuantity = Ext.isNumeric(newQuantity) ? newQuantity : record.get('dblNewQuantity');
            newQuantity = Ext.isNumeric(newQuantity) ? newQuantity : 0.00;

            // Get the original qty.
            originalQuantity = record.get('dblQuantity');
            originalQuantity = Ext.isNumeric(originalQuantity) ? originalQuantity : 0.00;

            // Get the new cost.
            newCost = Ext.isNumeric(newCost) ? newCost : record.get('dblNewCost');
            newCost = Ext.isNumeric(newCost) ? newCost : 0.00;

            // Get original cost.
            originalCost = record.get('dblCost');
            originalCost = Ext.isNumeric(originalCost) ? originalCost : 0.00;

            // Determine the cost to use:
            cost = newCost != 0 ? newCost : originalCost;

            // Calculate the line total
            lineTotal = (newQuantity - originalQuantity) * cost;
            record.set('dblLineTotal', lineTotal);
        }
    },

    calculateNewNetWeight: function (quantity, weight, record) {
        var newWeightPerQty = null;
        var newQty
            , newWeight;

        // Calculate a new Wgt per Qty if there is a valid new wgt.
        if (record) {

            // Get the new values
            newQty = Ext.isNumeric(quantity) ? quantity : record.get('dblNewQuantity');
            newWeight = Ext.isNumeric(weight) ? weight : record.get('dblNewWeight');

            // If new qty is intentionally set to null, use the original qty
            if (quantity === false) {
                quantity = record.get('dblQuantity');
                newQty = null;
            }

            // If new weight is intentionally set to null, use the original weight
            if (weight === false) {
                weight = record.get('dblWeight');
                newWeight = null;
            }

            // If new values are both null, set the weight per qty back to null
            if (newQty === null && newWeight === null) {
                newWeightPerQty = null;
            }
            else {
                // get the new Qty.
                quantity = Ext.isNumeric(quantity) ? quantity : record.get('dblNewQuantity');

                // If new Qty is invalid, use the original Qty
                quantity = Ext.isNumeric(quantity) ? quantity : record.get('dblQuantity');

                // If original qty is invalid, use zero
                quantity = Ext.isNumeric(quantity) ? quantity : 0.00;

                // get the new weight
                weight = Ext.isNumeric(weight) ? weight : record.get('dblNewWeight');

                // if new weight is invalid, use the original weight
                weight = Ext.isNumeric(weight) ? weight : record.get('dblWeight');

                if (Ext.isNumeric(weight) && quantity != 0) {
                    newWeightPerQty = weight / quantity;
                }
            }

            record.set('dblNewWeightPerQty', newWeightPerQty);
        }
    },

    onNumNewQuantityChange: function (control, newQuantity, oldValue, eOpts) {
        var me = this;
        var grid = control.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        if (current) {
            me.calculateLineTotal(newQuantity, null, current);
            me.calculateNewNetWeight((newQuantity === null ? false : newQuantity), null, current);

            var qty = current.get('dblQuantity'),
                weightPerQty = current.get('dblWeightPerQty'),
                newWeight = null,
                adjustByQty = null;

            if (Ext.isNumeric(qty) && Ext.isNumeric(newQuantity)) {
                adjustByQty = newQuantity - qty;
                newWeight = Ext.isNumeric(weightPerQty) ? weightPerQty * Math.abs(newQuantity) : null;
            }
            current.set('dblAdjustByQuantity', adjustByQty);
            current.set('dblWeight', newWeight);
        }
    },

    onNumAdjustByQuantityChange: function (control, newAdjustByQty, oldValue, eOpts) {
        var grid = control.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        if (current) {
            var qty = current.get('dblQuantity'),
                weightPerQty = current.get('dblWeightPerQty'),
                newWeight = null,
                newQty = null;

            if (Ext.isNumeric(qty) && Ext.isNumeric(newAdjustByQty)) {
                newQty = qty + newAdjustByQty;
                newWeight = Ext.isNumeric(weightPerQty) ? weightPerQty * Math.abs(newQty) : null;
            }

            current.set('dblNewQuantity', newQty);
            current.set('dblWeight', newWeight);
        }
    },

    onNumNewUnitCostChange: function (control, newCost, oldValue, eOpts) {
        var me = this;
        var grid = control.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        if (current) {
            me.calculateLineTotal(null, newCost, current);
        }
    },

    onNumNewNetWeightChange: function (control, newNetWeight, oldValue, eOpts) {
        var me = this;
        var grid = control.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        if (current) {
            me.calculateNewNetWeight(null, (newNetWeight === null ? false : newNetWeight), current);
        }
    },

    onPostClick: function(button, e, eOpts) {
        if (button){
            button.disable();
        }
        var me = this;
        var win = button.up('window');
        var current = win.viewModel.data.current;

        if (!current){
            button.enable();
            return;
        }        

        var context = win.context;
        var tabInventoryAdjustment = win.down('#tabInventoryAdjustment');
        var activeTab = tabInventoryAdjustment.getActiveTab();       

        var doPost = function (){
            Inventory.Utils.ajax({
                url: './inventory/api/inventoryadjustment/posttransaction',
                params:{
                    strTransactionId: current.get('strAdjustmentNo'),
                    isPost: current.get('ysnPosted') ? false : true,
                    isRecap: false
                },
                method: 'post'
            })
            .subscribe(
                function(successResponse) {
                    win.context.data.load();
                    // Check what is the active tab. If it is the Post Preview tab, load the recap data. 
                    if (activeTab.itemId == 'pgePostPreview'){
                        var cfg = {
                            isAfterPostCall: true,
                            ysnPosted: current.get('ysnPosted') ? true : false
                        };
                        me.doPostPreview(win, cfg);
                    }                    
                    button.enable();
                    iRely.Functions.refreshFloatingSearch('Inventory.view.InventoryAdjustment');
                }
                ,function(failureResponse) {
                    var responseText = Ext.decode(failureResponse.responseText);
                    var message = responseText ? responseText.message : {}; 
                    var statusText = message ? message.statusText : 'Oh no! Something went wrong while posting the inventory adjustment.';

                    iRely.Functions.showCustomDialog(iRely.Functions.dialogType.ERROR, iRely.Functions.dialogButtonType.OK, statusText);
                    button.enable();
                }
            )
        };
        
        // Save data changes first before doing the post.
        if (context.data.hasChanges()) {
            context.data.validator.validateRecord(context.data.configuration, function(valid) {
                // If records are valid, continue with the save. 
                if (valid){
                    context.data.saveRecord({
                        successFn: function () {
                            doPost();             
                        }
                    });
                }
                // If records are invalid, re-enable the post button. 
                else {
                    button.enable();
                }
            });            
        }        
        // Otherwise, simply post the transaction. 
        else {
            doPost();
        }                
    },

    doPostPreview: function(win, cfg){
        var me = this;

        if (!win) {return;}
        cfg = cfg ? cfg : {};

        var isAfterPostCall = cfg.isAfterPostCall;
        var ysnPosted = cfg.ysnPosted;

        var context = win.context;
        var current = win.viewModel.data.current;        
        var grdInventoryAdjustment = win.down('#grdInventoryAdjustment');        

        //Deselect all rows in Item Grid
        if (grdInventoryAdjustment) {grdInventoryAdjustment.getSelectionModel().deselectAll();       }

        var doRecap = function (){
            Inventory.Utils.ajax({
                url: './inventory/api/inventoryadjustment/posttransaction',
                params:{
                    strTransactionId: current.get('strAdjustmentNo'),
                    isPost: isAfterPostCall ? ysnPosted : current.get('ysnPosted') ? false : true,
                    isRecap: true
                },
                method: 'post'
            })
            .subscribe(
                function(successResponse) {
                    var postResult = Ext.decode(successResponse.responseText);
                    var batchId = postResult.data.strBatchId;
                    if (batchId) {
                        me.bindRecapGrid(batchId);
                    }                    
                }
                ,function(failureResponse) {
                    // Show Post Preview failed.
                    var jsonData = Ext.decode(failureResponse.responseText);
                    iRely.Functions.showErrorDialog(jsonData.message.statusText);                    
                }
            )
        };    

        // Save any unsaved data first before doing the post. 
        if (context.data.hasChanges()) {
            context.data.validator.validateRecord(context.data.configuration, function(valid) {
                // If records are valid, continue with the save. 
                if (valid){
                    context.data.saveRecord({
                        successFn: function () {
                            doRecap();             
                        }
                    });
                }
            });            
        }
        else {
            doRecap();
        }   
    },    

    onNewUOMChange: function (control, newUOM, oldValue, eOpts) {
        var me = this;
        var grid = control.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        if (current && (newUOM === null || newUOM === '')) {
            current.set('intNewItemUOMId', null);
        }
    },

    onUOMChange: function (control, newUOM, oldValue, eOpts) {
        var me = this;
        var grid = control.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        if (current && (newUOM === null || newUOM === '')) {
            current.set('intItemUOMId', null);
        }
    },


    onNewWeightUOMChange: function (control, newWeightUOM, oldValue, eOpts) {
        var me = this;
        var grid = control.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        if (current && (newWeightUOM === null || newWeightUOM === '')) {
            current.set('intNewWeightUOMId', null);
        }
    },

    onNewLotStatusChange: function (control, newLotStatus, oldValue, eOpts) {
        var me = this;
        var grid = control.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        if (current && (newLotStatus === null || newLotStatus === '')) {
            current.set('intNewLotStatusId', null);
        }
    },

    onInventoryClick: function (button, e, eOpts) {
        var win = button.up('window');
        var grd = win.down('#grdInventoryAdjustment');

        var selected = grd.getSelectionModel().getSelection();

        if (selected) {
            if (selected.length > 0) {
                var current = selected[0];
                if (!current.dummy)
                    iRely.Functions.openScreen('Inventory.view.Item', current.get('intItemId'));
            }
            else {
                iRely.Functions.showErrorDialog('Please select an Item to view.');
            }
        }
        else {
            iRely.Functions.showErrorDialog('Please select an Item to view.');
        }
    },

    onStorageLocationChange: function (obj, newValue, oldValue, eOpts) {
        var me = this;
        var grid = obj.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        var win = obj.up('window');
        var strLotTracking = current.get('strLotTracking');

        if (current && (newValue === null || newValue === '')) {
            current.set('intStorageLocationId', null);
            current.set('intItemUOMId', null);
            current.set('strItemUOM', '');
            current.set('dblQuantity', 0);
        } else if(current && newValue && strLotTracking == 'No'){
            me.getStockQuantity(current, win);
        }

    },

    // onItemNoBeforeQuery: function (obj) {
    //     if (obj.combo) {
    //         var win = obj.combo.up('window'),
    //             cboAdjustmentType = win.down('#cboAdjustmentType'),
    //             cboLocation = win.down('#cboLocation'),
    //             store = obj.combo.store;

    //         if (store) {
    //             store.remoteFilter = true;
    //             store.remoteSort = true;
    //         }

	// 	    //Show only lot tracked items for Adjustments Types: Lot Status Change, Split Lot, Lot Merge, Lot Move
    //         if(cboAdjustmentType.getValue() == 4 || cboAdjustmentType.getValue() == 5 || cboAdjustmentType.getValue() == 7 || cboAdjustmentType.getValue() == 8) {
    //             obj.combo.defaultFilters = [
    //                 {
    //                     column: 'intLocationId',
    //                     value: cboLocation.getValue(),
    //                     conjunction: 'and'
    //                 },
    //                 {
    //                     column: 'strLotTracking',
    //                     value: 'No',
    //                     condition: 'noteq',
    //                     conjunction: 'and'
    //                 }
    //             ];
    //         }
    //         else {
    //             obj.combo.defaultFilters = [
    //                 {
    //                     column: 'intLocationId',
    //                     value: cboLocation.getValue(),
    //                     conjunction: 'and'
    //                 }
    //             ];
    //         }
    //     }
    // },

    onSubLocationChange: function (control, newValue, oldValue, eOpts) {
        var me = this;
        var grid = control.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        if (current && (newValue === null || newValue === '')) {
            current.set('dblQuantity', 0);
            current.set('intSubLocationId', null);
            current.set('intStorageLocationId', null);
            current.set('strSubLocation', '');
            current.set('strStorageLocation', '');
            current.set('intItemUOMId', null);
            current.set('strItemUOM', '');
        }
    },

    onAdjustmentTabChange: function (tabPanel, newCard, oldCard, eOpts) {
        var me = this;
        var win = tabPanel.up('window');
        var context = win.context;
        var current = win.viewModel.data.current;

        switch (newCard.itemId) {
            case 'pgePostPreview':
                me.doPostPreview(win);
        }
    },

    init: function (application) {
        this.control({
            "#cboItemNo": {
                select: this.onAdjustmentDetailSelect
            },
            "#cboNewItemNo": {
                select: this.onAdjustmentDetailSelect
            },
            "#cboStorageLocation": {
                select: this.onAdjustmentDetailSelect,
                change: this.onStorageLocationChange
            },
            "#cboLotNumber": {
                select: this.onAdjustmentDetailSelect
            },
            "#cboSubLocation": {
                select: this.onAdjustmentDetailSelect,
                change: this.onSubLocationChange
            },
            "#cboOwnershipType": {
                select: this.onAdjustmentDetailSelect
            },
            "#cboUOM": {
                select: this.onAdjustmentDetailSelect,
                change: this.onUOMChange
            },
            "#cboNewUOM": {
                select: this.onAdjustmentDetailSelect,
                change: this.onNewUOMChange
            },
            "#cboNewWeightUOM": {
                select: this.onAdjustmentDetailSelect,
                change: this.onNewWeightUOMChange
            },
            "#cboNewLotStatus": {
                select: this.onAdjustmentDetailSelect,
                change: this.onNewLotStatusChange
            },
            "#cboAdjustmentType": {
                beforeselect: this.onAdjustmentTypeBeforeSelect
            },
            "#numNewQuantity": {
                change: this.onNumNewQuantityChange
            },
            "#numAdjustByQuantity": {
                change: this.onNumAdjustByQuantityChange
            },
            "#numNewUnitCost": {
                change: this.onNumNewUnitCostChange
            },
            "#numNewNetWeight": {
                change: this.onNumNewNetWeightChange
            },
            "#btnPost": {
                click: this.onPostClick
            },
            "#btnUnpost": {
                click: this.onPostClick
            },
            "#cboNewLocation": {
                select: this.onAdjustmentDetailSelect
            },
            "#cboNewSubLocation": {
                select: this.onAdjustmentDetailSelect
            },
            "#cboNewStorageLocation": {
                select: this.onAdjustmentDetailSelect
            },
            "#btnViewItem": {
                click: this.onInventoryClick
            },
            "#cboNewOwner": {
                select: this.onAdjustmentDetailSelect
            },
            "#grdInventoryAdjustment": {
                cellclick: this.onCellClick
            },
            "#cboLocation": {
                drilldown: this.onLocationDrilldown
            },
            "#tabInventoryAdjustment": {
                tabChange: this.onAdjustmentTabChange
            }             
        });
    }
});