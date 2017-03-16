Ext.define('Inventory.view.InventoryAdjustmentViewController', {
    extend: 'Inventory.view.InventoryBaseViewController',
    alias: 'controller.icinventoryadjustment',
    requires: [
        'CashManagement.common.Text',
        'CashManagement.common.BusinessRules'
    ],

    config: {
        searchConfig: {
            title: 'Search Inventory Adjustment',
            type: 'Inventory.InventoryAdjustment',
            api: {
                read: '../Inventory/api/InventoryAdjustment/Search'
            },
            columns: [
                {dataIndex: 'intInventoryAdjustmentId', text: 'Inventory Adjustment Id', flex: 1, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', key: true, hidden: true },
                {dataIndex: 'intLocationId', text: 'Location Id', flex: 1, dataType: 'numeric', hidden: true },
                {dataIndex: 'strLocationName', text: 'Location Name', flex: 1, dataType: 'string', drillDownText: 'View Location', drillDownClick: 'onViewLocation' },
                {dataIndex: 'dtmAdjustmentDate', text: 'Adjustment Date', flex: 1, dataType: 'date', xtype: 'datecolumn' },
                {dataIndex: 'intAdjustmentType', text: 'Adjustment Type', flex: 1, dataType: 'numeric', hidden: true },
                {dataIndex: 'strAdjustmentType', text: 'Adjustment Type', flex: 1, dataType: 'string' },
                {dataIndex: 'strAdjustmentNo', text: 'Adjustment No', flex: 1, dataType: 'string', drillDownText: 'View Adjustment', drillDownClick: 'onViewAdjustment' },
                {dataIndex: 'strDescription', text: 'Description', flex: 1, dataType: 'string' },
                {dataIndex: 'ysnPosted', text: 'Posted', flex: 1, dataType: 'boolean', xtype: 'checkcolumn' },
                {dataIndex: 'intEntityId', text: 'Entity Id', flex: 1, dataType: 'numeric', hidden: true },
                {dataIndex: 'strUser', text: 'User', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'dtmPostedDate', text: 'Posted Date', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                {dataIndex: 'dtmUnpostedDate', text: 'Unposted Date', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                {dataIndex: 'intSourceId', text: 'Source Id', flex: 1, dataType: 'numeric', hidden: true },
                {dataIndex: 'intSourceTransactionTypeId', text: 'Source Transaction Type Id', flex: 1, dataType: 'numeric', hidden: true }
            ],
            buttons: [
                {
                    text: 'Items',
                    itemId: 'btnItem',
                    clickHandler: 'onItemClick',
                    width: 80
                },
                {
                    text: 'Categories',
                    itemId: 'btnCategory',
                    clickHandler: 'onCategoryClick',
                    width: 100
                },
                {
                    text: 'Commodities',
                    itemId: 'btnCommodity',
                    clickHandler: 'onCommodityClick',
                    width: 100
                },
                {
                    text: 'Locations',
                    itemId: 'btnLocation',
                    clickHandler: 'onLocationClick',
                    width: 100
                },
                {
                    text: 'Storage Locations',
                    itemId: 'btnStorageLocation',
                    clickHandler: 'onStorageLocationClick',
                    width: 110
                }
            ],
            searchConfig: [
                {
                    title: 'Details',
                    api: {
                        read: '../Inventory/api/InventoryAdjustment/SearchAdjustmentDetails'
                    },
                    columns: [
                        {dataIndex: 'intInventoryAdjustmentDetailId', text: 'Inventory Adjustment Detail Id', width: 100, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', hidden: true },
                        {dataIndex: 'intInventoryAdjustmentId', text: 'Inventory Adjustment Id', width: 100, key: true, dataType: 'numeric', hidden: true },
                        {dataIndex: 'intLocationId', text: 'Location Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strLocationName', text: 'Location Name', width: 100, dataType: 'string', hidden: true },
                        {dataIndex: 'dtmAdjustmentDate', text: 'Adjustment Date', width: 100, dataType: 'date', xtype: 'datecolumn', hidden: true },
                        {dataIndex: 'intAdjustmentType', text: 'Adjustment Type', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strAdjustmentType', text: 'Adjustment Type', width: 100, dataType: 'string', hidden: true },
                        {dataIndex: 'strAdjustmentNo', text: 'Adjustment No', width: 100, dataType: 'string', drillDownText: 'View Adjustment', drillDownClick: 'onViewAdjustment' },
                        {dataIndex: 'strDescription', text: 'Description', width: 100, dataType: 'string', hidden: true },
                        {dataIndex: 'ysnPosted', text: 'Posted', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                        {dataIndex: 'intEntityId', text: 'Entity Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strUser', text: 'User', width: 100, dataType: 'string', hidden: true },
                        {dataIndex: 'dtmPostedDate', text: 'Posted Date', width: 100, dataType: 'date', xtype: 'datecolumn', hidden: true },
                        {dataIndex: 'dtmUnpostedDate', text: 'Unposted Date', width: 100, dataType: 'date', xtype: 'datecolumn', hidden: true },
                        {dataIndex: 'intSubLocationId', text: 'SubLocation Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strSubLocationName', text: 'SubLocation Name', width: 100, dataType: 'string' },
                        {dataIndex: 'intStorageLocationId', text: 'Storage Location Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strStorageLocationName', text: 'Storage Location Name', width: 100, dataType: 'string', drillDownText: 'View Storage Location', drillDownClick: 'onViewStorageLocation' },
                        {dataIndex: 'intItemId', text: 'Item Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strItemNo', text: 'Item No', width: 100, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                        {dataIndex: 'strItemDescription', text: 'Item Description', width: 100, dataType: 'string' },
                        {dataIndex: 'strLotTracking', text: 'Lot Tracking', width: 100, dataType: 'string', hidden: true },
                        {dataIndex: 'intNewItemId', text: 'New Item Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strNewItemNo', text: 'New Item No', width: 100, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                        {dataIndex: 'strNewItemDescription', text: 'New Item Description', width: 100, dataType: 'string' },
                        {dataIndex: 'strNewLotTracking', text: 'New Lot Tracking', width: 100, dataType: 'string', hidden: true },
                        {dataIndex: 'intLotId', text: 'Lot Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strLotNumber', text: 'Lot Number', width: 100, dataType: 'string' },
                        {dataIndex: 'dblLotQty', text: 'Lot Qty', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'dblLotUnitCost', text: 'Lot Unit Cost', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'dblLotWeightPerQty', text: 'Lot Weight Per Qty', width: 100, dataType: 'float', xtype: 'numbercolumn', hidden: true },
                        {dataIndex: 'intNewLotId', text: 'New Lot Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strNewLotNumber', text: 'New Lot Number', width: 100, dataType: 'string' },
                        {dataIndex: 'dblQuantity', text: 'Available Qty', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'dblNewQuantity', text: 'New Quantity', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'dblNewSplitLotQuantity', text: 'New Split Lot Quantity', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'dblAdjustByQuantity', text: 'Adjust By Quantity', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'intItemUOMId', text: 'Item UOM Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strItemUOM', text: 'Item UOM', width: 100, dataType: 'string', drillDownText: 'View Inventory UOM', drillDownClick: 'onViewUOM' },
                        {dataIndex: 'dblItemUOMUnitQty', text: 'Item UOM Unit Qty', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'intNewItemUOMId', text: 'New Item UOM Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strNewItemUOM', text: 'New Item UOM', width: 100, dataType: 'string', drillDownText: 'View Inventory UOM', drillDownClick: 'onViewUOM' },
                        {dataIndex: 'dblNewItemUOMUnitQty', text: 'New Item UOM Unit Qty', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'intWeightUOMId', text: 'Weight UOM Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strWeightUOM', text: 'Weight UOM', width: 100, dataType: 'string', drillDownText: 'View Inventory UOM', drillDownClick: 'onViewUOM' },
                        {dataIndex: 'intNewWeightUOMId', text: 'New Weight UOM Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strNewWeightUOM', text: 'New Weight UOM', width: 100, dataType: 'string', drillDownText: 'View Inventory UOM', drillDownClick: 'onViewUOM' },
                        {dataIndex: 'dblWeight', text: 'Weight', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'dblNewWeight', text: 'New Weight', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'dblWeightPerQty', text: 'Weight Per Qty', width: 100, dataType: 'float', xtype: 'numbercolumn', hidden: true },
                        {dataIndex: 'dblNewWeightPerQty', text: 'New Weight Per Qty', width: 100, dataType: 'float', xtype: 'numbercolumn', hidden: true },
                        {dataIndex: 'dtmExpiryDate', text: 'Expiry Date', width: 100, dataType: 'date', xtype: 'datecolumn' },
                        {dataIndex: 'dtmNewExpiryDate', text: 'New Expiry Date', width: 100, dataType: 'date', xtype: 'datecolumn' },
                        {dataIndex: 'intLotStatusId', text: 'Lot Status Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strLotStatus', text: 'Lot Status', width: 100, dataType: 'string', drillDownText: 'View Lot Status', drillDownClick: 'onViewLotStatus' },
                        {dataIndex: 'intNewLotStatusId', text: 'New Lot Status Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strNewLotStatus', text: 'New Lot Status', width: 100, dataType: 'string', drillDownText: 'View Lot Status', drillDownClick: 'onViewLotStatus' },
                        {dataIndex: 'dblCost', text: 'Cost', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'dblNewCost', text: 'New Cost', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'intNewLocationId', text: 'New Location Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strNewLocationName', text: 'New Location Name', width: 100, dataType: 'string', drillDownText: 'View Location', drillDownClick: 'onViewLocation' },
                        {dataIndex: 'intNewSubLocationId', text: 'New SubLocation Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strNewSubLocationName', text: 'New SubLocation Name', width: 100, dataType: 'string' },
                        {dataIndex: 'intNewStorageLocationId', text: 'New Storage Location Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strNewStorageLocationName', text: 'New Storage Location Name', width: 100, dataType: 'string', drillDownText: 'View Storage Location', drillDownClick: 'onViewStorageLocation' },
                        {dataIndex: 'dblLineTotal', text: 'LineTotal', width: 100, dataType: 'float', xtype: 'numbercolumn' }
                    ]
                }
            ]
        },
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
            btnPostPreview: {
                hidden: '{current.ysnPosted}'
            },
            btnUnpostPreview: {
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
                value: '{current.intLocationId}',
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
                            },
                            {
                                column: 'dblOnHand',
                                value: '{getOnHandFilterValue}',
                                conjunction: 'and',
                                condition: 'gt'
                            },
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
                            },
                            {
                                column: 'dblOnHand',
                                value: '{getOnHandFilterValue}',
                                conjunction: 'and',
                                condition: 'gt'
                            }
                        ]
                    }
                },

                colLotNumber: {
                    dataIndex: 'strLotNumber',
                    text: '{setLotNumberLabel}',
                    editor: {
                        store: '{lot}',
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
                                conjunction: 'and',
                                condition: 'blk'
                            },
                            {
                                column: 'intStorageLocationId',
                                value: '{grdInventoryAdjustment.selection.intStorageLocationId}',
                                conjunction: 'and',
                                condition: 'blk'
                            }
                        ],
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
                        store: '{itemUOM}',
                        defaultFilters: [

                            {
                                column: 'intLocationId',
                                value: '{current.intLocationId}',
                                conjunction: 'and'
                            },
                           /* {
                                column: 'intLocationId',
                                value: '',
                                conjunction: 'or',
                                condition: 'blk'
                            },*/
                            {
                                column: 'intItemId',
                                value: '{grdInventoryAdjustment.selection.intItemId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'dblOnHand',
                                value: '{getOnHandFilterValue}',
                                conjunction: 'and',
                                condition: 'gt'
                            }
                        ],
                        readOnly: '{formulaShowItemUOMEditor}'
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
                    hidden: '{formulaHideColumn_colNewExpiryDate}'
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
                                condition: 'blk'
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
            }
        }
    },

    setupContext: function (options) {
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Adjustment', { pageSize: 1 }),
            grdInventoryAdjustment = win.down('#grdInventoryAdjustment');

        win.context = Ext.create('iRely.mvvm.Engine', {
            window: win,
            store: store,
            enableActivity: true,
            createTransaction: Ext.bind(me.createTransaction, me),
            enableAudit: true,
            include: 'tblICInventoryAdjustmentDetails.vyuICGetInventoryAdjustmentDetail',
            onSaveClick: me.saveAndPokeGrid(win, grdInventoryAdjustment),
            createRecord: me.createRecord,
            validateRecord: me.validateRecord,
            binding: me.config.binding,
            attachment: Ext.create('iRely.mvvm.attachment.Manager', {
                type: 'Inventory.InventoryAdjustment',
                window: win
            }),
            details: [
                {
                    key: 'tblICInventoryAdjustmentDetails',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdInventoryAdjustment,
                        deleteButton: win.down('#btnRemoveItem')
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

            var context = me.setupContext({window: win});

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
        var today = new Date();
        var record = Ext.create('Inventory.model.Adjustment');
        record.set('intAdjustmentType', '1');
        if (app.DefaultLocation > 0)
            record.set('intLocationId', app.DefaultLocation);
        record.set('dtmAdjustmentDate', today);
        record.set('ysnPosted', false);
        action(record);
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
                        eachLotId = [];
                    //Validate Lot Id
                    if(countLineItems > 1) {
                        Ext.Array.each(current.tblICInventoryAdjustmentDetails().data.items, function (item) {
                            if (!item.dummy) {
                                eachLotId[currentItemIndex] = item.get('intLotId');
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



                    var zeroCost = false;
                        zeroCost = Ext.Array.each(lineItems, function (detail) {
                            if (!detail.dummy) {
                                if(!iRely.Functions.isEmpty(detail.get('dblNewCost')) || detail.modified.dblNewCost !== null) {
                                   /* var hasModification = !_.isUndefined(detail.modified);
                                    var defined =  hasModification && !_.isUndefined(detail.modified.dblNewCost);
                                    var notNull = hasModification && !_.isNull(detail.modified.dblNewCost);
                                    var checkCost = defined && notNull;

                                    if (detail.get('dblNewCost') <= 0 && (checkCost &&  (detail.modified.dblNewCost !== detail.get('dblNewCost')))) {
                                        return true;
                                    }*/

                                    if(detail.get('dblNewCost') == 0) {
                                        return true;
                                    }
                                }
                            }
                            return false;
                        });

                        if (zeroCost && colNewUnitCost.hidden == false) {
                            var msgAction = function (button) {
                                if (button === 'yes') {
                                    action(true);
                                }
                                else action(false);
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
            current.set('dblCost', record.get('dblLastCost'));
            current.set('dblNewCost', record.get('dblLastCost'));
            me.getStockQuantity(current, win);

            // Check if selected item lot-tracking = NO.
            // Non Lot items will need to use stock UOM.
            var strLotTracking = record.get('strLotTracking');

            if (strLotTracking == 'No') {
                current.set('intItemUOMId', record.get('intStockUOMId'));
                current.set('strItemUOM', record.get('strStockUOM'));
                current.set('dblItemUOMUnitQty', record.get('dblStockUnitQty'));
            }
            else {
                current.set('intItemUOMId', null);
                current.set('strItemUOM', null);
                current.set('dblItemUOMUnitQty', null);
            }

            // Clear the values for the following fields:
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
            current.set('strLotTracking', strLotTracking);

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

            current.set('strStorageLocation', records[0].get('strStorageLocationName'));
            current.set('intStorageLocationId', records[0].get('intStorageLocationId'));
            current.set('intSubLocationId', records[0].get('intSubLocationId'));
            current.set('dblQuantity', records[0].get('dblOnHand'));
            current.set('intItemUOMId', records[0].get('intItemUOMId'));
            current.set('strItemUOM', records[0].get('strUnitMeasure'));
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

            current.set('strSubLocation', records[0].get('strSubLocationName'));
            current.set('intSubLocationId', records[0].get('intSubLocationId'));
            current.set('intStorageLocationId', records[0].get('intStorageLocationId'));
            current.set('dblQuantity', records[0].get('dblOnHand'));
            current.set('intItemUOMId', records[0].get('intItemUOMId'));
            current.set('strItemUOM', records[0].get('strUnitMeasure'));
        }

        else if (combo.itemId === 'cboNewItemNo') {
            current.set('intNewItemId', record.get('intItemId'));
            current.set('strNewItemDescription', record.get('strDescription'));
        }
        else if (combo.itemId === 'cboLotNumber') {
            current.set('intLotId', record.get('intLotId'));
            current.set('dblQuantity', record.get('dblQty'));
            current.set('dblWeight', record.get('dblWeight'));
            current.set('dblCost', record.get('dblCost') * record.get('dblItemUOMUnitQty'));
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
        else if (combo.itemId === 'cboUOM') {
            // Recalculate the unit cost
            var currentUnitCost = current.get('dblCost')
                , currentItemUOMUnitQty = current.get('dblItemUOMUnitQty')
                , selectedItemUOMUnitQty = record.get('dblUnitQty')
                , selectedOnHandQty = record.get('dblOnHand')
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

            if (Ext.isNumeric(selectedOnHandQty) && Ext.isNumeric(adjustByQuantity)) {
                newQty = selectedOnHandQty + adjustByQuantity;
            }

            current.set('dblNewQuantity', newQty);

            //Set Sub and Storage Locations
            if(iRely.Functions.isEmpty(record.get('intItemStockUOMId'))) {
                current.set('intStorageLocationId', record.get('intStorageLocationId'));
                current.set('strStorageLocation', record.get('strStorageLocationName'));
                current.set('intSubLocationId', record.get('intStorageLocationId'));
                current.set('strSubLocation', record.get('strSubLocationName'));
            }

            //Set Available Quantity Per UOm
            current.set('dblQuantity', record.get('dblOnHand'));
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
            storageLocationId = record.get('intStorageLocationId');
        var qty = 0;

        ic.utils.ajax({
            timeout: 120000,   
            url: '../Inventory/api/Item/GetItemStockUOMSummary',
            params: {
                ItemId: itemId,
                LocationId: locationId,
                SubLocationId: subLocationId,
                StorageLocationId: storageLocationId
            } 
        })
        .map(function(x) { return Ext.decode(x.responseText); })
        .subscribe(
            function(data) {
                if (data.success) {
                    if (data.data.length > 0) {
                        var stockRecord = data.data[0];
                        qty = stockRecord.dblOnHand;
                    }
                }
                else {
                    iRely.Functions.showErrorDialog(data.message.statusText);
                }
                record.set('dblQuantity', qty);
            },
            function(error) {
                var json = Ext.decode(error.responseText);
                iRely.Functions.showErrorDialog(json.ExceptionMessage);
            }
        );
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

    onAfterPost: function (success, message) {
        var me = this;
        var win = me.view;

        if (success === true) {
            win.context.data.load();
        }
        else {
            iRely.Functions.showCustomDialog(
                iRely.Functions.dialogType.ERROR,
                iRely.Functions.dialogButtonType.OK,
                message,
                function () {
                    message = message ? message : '';

                    var outdatedStock;

                    outdatedStock = message.indexOf('The stock on hand is outdated for');
                    if (outdatedStock == -1) {
                        outdatedStock = message.indexOf('The lot expiry dates are outdated for');
                    }

                    if (outdatedStock !== -1) {
                        win.context.data.load();
                    }
                }
            );
        }
    },

    onPostOrUnPostClick: function (button, e, eOpts) {
        var me = this;
        var win = button.up('window');
        var context = win.context;

        var doPost = function () {
            var strAdjustmentNo = win.viewModel.data.current.get('strAdjustmentNo');
            var posted = win.viewModel.data.current.get('ysnPosted');

            var options = {
                postURL: '../Inventory/api/InventoryAdjustment/PostTransaction',
                strTransactionId: strAdjustmentNo,
                isPost: !posted,
                isRecap: false,
                callback: me.onAfterPost,
                scope: me
            };

            CashManagement.common.BusinessRules.callPostRequest(options);
        };

        // If there is no data change, do the post.
        if (!context.data.hasChanges()) {
            doPost();
            return;
        }

        // Save has data changes first before doing the post.
        context.data.saveRecord({
            successFn: function () {
                doPost();
            }
        });
    },

    onRecapClick: function (button, e, eOpts) {
        var me = this;
        var win = button.up('window');
        var cboCurrency = null;
        var context = win.context;

        var doRecap = function (recapButton, currentRecord, currency) {

            // Call the buildRecapData to generate the recap data
            CashManagement.common.BusinessRules.buildRecapData({
                postURL: '../Inventory/api/InventoryAdjustment/PostTransaction',
                strTransactionId: currentRecord.get('strAdjustmentNo'),
                ysnPosted: currentRecord.get('ysnPosted'),
                scope: me,
                success: function () {
                    // If data is generated, show the recap screen.
                    CashManagement.common.BusinessRules.showRecap({
                        strTransactionId: currentRecord.get('strAdjustmentNo'),
                        ysnPosted: currentRecord.get('ysnPosted'),
                        dtmDate: currentRecord.get('dtmAdjustmentDate'),
                        strCurrencyId: currency,
                        dblExchangeRate: 1,
                        scope: me,
                        postCallback: function () {
                            me.onPostOrUnPostClick(recapButton);
                        },
                        unpostCallback: function () {
                            me.onPostOrUnPostClick(recapButton);
                        }
                    });
                },
                failure: function (message) {
                    // Show why recap failed.
                    var msgBox = iRely.Functions;
                    msgBox.showCustomDialog(
                        msgBox.dialogType.ERROR,
                        msgBox.dialogButtonType.OK,
                        message
                    );
                }
            });
        };

        // If there is no data change, do the post.
        if (!context.data.hasChanges()) {
            doRecap(button, win.viewModel.data.current, cboCurrency);
            return;
        }

        // Save has data changes first before doing the post.
        context.data.saveRecord({
            successFn: function () {
                doRecap(button, win.viewModel.data.current, cboCurrency);
            }
        });
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

    onItemClick: function () {
        iRely.Functions.openScreen('Inventory.view.Item', { action: 'new', viewConfig: { modal: true }});
    },

    onCategoryClick: function () {
        iRely.Functions.openScreen('Inventory.view.Category', { action: 'new', viewConfig: { modal: true }});
    },

    onCommodityClick: function () {
        iRely.Functions.openScreen('Inventory.view.Commodity', { action: 'new', viewConfig: { modal: true }});
    },

    onLocationClick: function () {
        iRely.Functions.openScreen('i21.view.CompanyLocation', { action: 'new', viewConfig: { modal: true }});
    },

    onStorageLocationClick: function () {
        iRely.Functions.openScreen('Inventory.view.StorageUnit', { action: 'new', viewConfig: { modal: true }});
    },

    onViewLocation: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'LocationName');
    },

    onViewAdjustment: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'AdjustmentNo');
    },

    onViewStorageLocation: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'StorageLocation');
    },

    onViewItem: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'ItemNo');
    },

    onViewUOM: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'UOM');
    },

    onViewLotStatus: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'LotStatus');
    },

    onStorageLocationChange: function (obj, newValue, oldValue, eOpts) {
        var me = this;
        var grid = obj.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        var win = obj.up('window');

         if (current && (newValue === null || newValue === '')) {
            current.set('intStorageLocationId', null);
            me.getStockQuantity(current, win);
        }
    },

    onItemNoBeforeQuery: function (obj) {
        if (obj.combo) {
            var win = obj.combo.up('window'),
                cboAdjustmentType = win.down('#cboAdjustmentType'),
                cboLocation = win.down('#cboLocation'),
                store = obj.combo.store;

            if (store) {
                store.remoteFilter = true;
                store.remoteSort = true;
            }

		    //Show only lot tracked items for Adjustments Types: Lot Status Change, Split Lot, Lot Merge, Lot Move
            if(cboAdjustmentType.getValue() == 4 || cboAdjustmentType.getValue() == 5 || cboAdjustmentType.getValue() == 7 || cboAdjustmentType.getValue() == 8) {
                obj.combo.defaultFilters = [
                    {
                        column: 'intLocationId',
                        value: cboLocation.getValue(),
                        conjunction: 'and'
                    },
                    {
                        column: 'strLotTracking',
                        value: 'No',
                        condition: 'noteq',
                        conjunction: 'and'
                    }
                ];
            }
            else {
                obj.combo.defaultFilters = [
                    {
                        column: 'intLocationId',
                        value: cboLocation.getValue(),
                        conjunction: 'and'
                    }
                ];
            }
        }
    },

    onSubLocationChange: function (control, newValue, oldValue, eOpts) {
        var me = this;
        var grid = control.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        if (current && (newValue === null || newValue === '')) {
            current.set('dblQuantity', 0);
            current.set('intSubLocationId', null);
        }
    },

    init: function (application) {
        this.control({
            "#cboItemNo": {
                beforequery: this.onItemNoBeforeQuery,
                select: this.onAdjustmentDetailSelect,
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
                click: this.onPostOrUnPostClick
            },
            "#btnUnpost": {
                click: this.onPostOrUnPostClick
            },
            "#btnPostPreview": {
                click: this.onRecapClick
            },
            "#btnUnpostPreview": {
                click: this.onRecapClick
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
            }
        });
    }
});