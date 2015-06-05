Ext.define('Inventory.view.InventoryAdjustmentViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icinventoryadjustment',

    config: {
        searchConfig: {
            title: 'Search Inventory Adjustment',
            type: 'Inventory.InventoryAdjustment',
            api: {
                read: '../Inventory/api/InventoryAdjustment/Search'
            },
            columns: [
                {dataIndex: 'intInventoryAdjustmentId', text: "Inventory Adjustment Id", flex: 1, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strAdjustmentNo', text: 'Adjustment No', flex: 1, dataType: 'string'},
                {dataIndex: 'strLocationName', text: 'Location Id', flex: 1, dataType: 'string'},
                {dataIndex: 'strDescription', text: 'Description', flex: 1, dataType: 'string'},
                //{dataIndex: 'strAdjustmentType', text: 'Adjustment Type', flex: 1, dataType: 'string'},
                {dataIndex: 'dtmAdjustmentDate', text: 'Date', flex: 1, dataType: 'date', xtype: 'datecolumn'},
                {dataIndex: 'ysnPosted',text: 'Posted', flex: 1,  dataType: 'boolean', xtype: 'checkcolumn'}
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
                    editor: {
                        store: '{subLocation}',
                        defaultFilters: [
                            {
                                column: 'intCompanyLocationId',
                                value: '{current.intLocationId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'strClassification',
                                value: 'Inventory',
                                conjunction: 'and'
                            }
                        ]
                    }
                },

                colStorageLocation: {
                    dataIndex: 'strStorageLocation',
                    editor: {
                        store: '{storageLocation}',
                        defaultFilters: [
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

                colLotNumber: {
                    dataIndex: 'strLotNumber',
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
                    hidden: '{formulaHideColumn_colNewLotNumber}'
                },

                colQuantity: {
                    dataIndex: 'dblQuantity',
                    hidden: '{formulaHideColumn_colQuantity}'
                },

                colNewQuantity: {
                    dataIndex: 'dblNewQuantity',
                    hidden: '{formulaHideColumn_colNewQuantity}'
                },

                colAdjustByQuantity: {
                    dataIndex: 'dblAdjustByQuantity',
                    hidden: '{formulaHideColumn_colAdjustByQuantity}'
                },

                colNewSplitLotQuantity: {
                    dataIndex: 'dblNewSplitLotQuantity',
                    hidden: '{formulaHideColumn_colNewSplitLotQuantity}'
                },

                colUOM: {
                    dataIndex: 'strItemUOM',
                    hidden: '{formulaHideColumn_colUOM}',
                    editor: {
                        store: '{itemUOM}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryAdjustment.selection.intItemId}',
                            conjunction: 'and'
                        }],
                        readOnly: '{formulaShowItemUOMEditor}'
                    }
                },

                colNewUOM: {
                    dataIndex: 'strNewItemUOM',
                    hidden: '{formulaHideColumn_colNewUOM}',
                    editor: {
                        store: '{newItemUOM}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryAdjustment.selection.intItemId}',
                            conjunction: 'and'
                        }]
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
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryAdjustment.selection.intItemId}',
                            conjunction: 'and'
                        }]
                    }
                },

                colNewWeightUOM: {
                    dataIndex: 'strNewWeightUOM',
                    hidden: '{formulaHideColumn_colNewWeightUOM}',
                    editor: {
                        store: '{newWeightUOM}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryAdjustment.selection.intItemId}',
                            conjunction: 'and'
                        }]
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
                    hidden: '{formulaHideColumn_colNewUnitCost}'
                },

                colNewItemNumber: {
                    dataIndex: 'strNewItemNo',
                    hidden: '{formulaHideColumn_colNewItemNumber}',
                    editor: {
                        store: '{newItem}',
                        defaultFilters: [{
                            column: 'intLocationId',
                            value: '{current.intLocationId}',
                            conjunction: 'and'
                        }]
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
                }
            },

            grdNotes: {
                readOnly: '{current.ysnPosted}',
                colNoteDescription: 'strDescription',
                colNotes: 'strNotes'
            }
        }
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Adjustment', { pageSize: 1 });

        win.context = Ext.create('iRely.mvvm.Engine', {
            window : win,
            store  : store,
            include: 'tblICInventoryAdjustmentDetails.tblSMCompanyLocationSubLocation, ' +
                'tblICInventoryAdjustmentDetails.tblICStorageLocation, ' +
                'tblICInventoryAdjustmentDetails.Item, ' +
                'tblICInventoryAdjustmentDetails.NewItem, ' +
                'tblICInventoryAdjustmentDetails.Lot, ' +
                'tblICInventoryAdjustmentDetails.NewLot, ' +
                'tblICInventoryAdjustmentDetails.ItemUOM.tblICUnitMeasure, ' +
                'tblICInventoryAdjustmentDetails.NewItemUOM.tblICUnitMeasure, ' +
                'tblICInventoryAdjustmentDetails.WeightUOM.tblICUnitMeasure, ' +
                'tblICInventoryAdjustmentDetails.NewWeightUOM.tblICUnitMeasure, ' +
                'tblICInventoryAdjustmentDetails.OldLotStatus, ' +
                'tblICInventoryAdjustmentDetails.NewLotStatus, ' +
                'tblICInventoryAdjustmentDetails.NewLocation, ' +
                'tblICInventoryAdjustmentDetails.NewSubLocation, ' +
                'tblICInventoryAdjustmentDetails.NewStorageLocation, ' +
                'tblICInventoryAdjustmentNotes',
            createRecord : me.createRecord,
            binding: me.config.binding,
            attachment: Ext.create('iRely.mvvm.attachment.Manager', {
                type: 'Inventory.InventoryAdjustment',
                window: win
            }),
            details: [
                {
                    key: 'tblICInventoryAdjustmentDetails',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: win.down('#grdInventoryAdjustment'),
                        deleteButton : win.down('#btnRemoveItem')
                    })
                },
                {
                    key: 'tblICInventoryAdjustmentNotes',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: win.down('#grdNotes'),
                        deleteButton : win.down('#btnRemoveNotes')
                    })
                }
            ]
        });

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
                        column: 'intInventoryAdjustmentId',
                        value: config.id
                    }];
                }
                context.data.load({
                    filters: config.filters
                });
            }
        }
    },

    createRecord: function(config, action) {
        var today = new Date();
        var record = Ext.create('Inventory.model.Adjustment');
        record.set('intAdjustmentType', '1');
        if (app.DefaultLocation > 0)
            record.set('intLocationId', app.DefaultLocation);
        record.set('dtmAdjustmentDate', today);
        record.set('ysnPosted', false);
        action(record);
    },

    onAdjustmentDetailSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var record = records[0];

        var win = combo.up('window');
        var me = win.controller;
        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();

        if (combo.itemId === 'cboItemNo')
        {

            // Populate the default data.
            current.set('intItemId', record.get('intItemId'));
            current.set('strItemDescription', record.get('strDescription'));

            // Check if selected item lot-tracking = NO.
            // Non Lot items will need to use stock UOM.
            var strLotTracking = record.get('strLotTracking');

            if (strLotTracking == 'No'){
                current.set('dblQuantity', record.get('dblUnitOnHand'));
                current.set('dblCost', record.get('dblLastCost'));
                current.set('intItemUOMId', record.get('intStockUOMId'));
                current.set('strItemUOM', record.get('strStockUOM'));
            }
            else {
                current.set('dblQuantity', null);
                current.set('dblCost', null);
                current.set('intItemUOMId', null);
                current.set('strItemUOM', null);
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
            current.set('dblNewCost', null);
            current.set('intNewItemUOMId', null);
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

            if (strLotTracking == 'No'){
                if (cboLotNumber) cboLotNumber.setReadOnly(true);
                if (cboUOM) cboUOM.setReadOnly(false);
            }
            else {
                if (cboLotNumber) cboLotNumber.setReadOnly(false);
                if (cboUOM) cboUOM.setReadOnly(true);
            }

        }
        else if (combo.itemId === 'cboSubLocation')
        {
            current.set('intSubLocationId', record.get('intCompanyLocationSubLocationId'));
            current.set('dblQuantity', null);
            current.set('dblCost', null);
            current.set('intItemUOMId', null);
            current.set('strItemUOM', null);
            current.set('strStorageLocation', null);
            current.set('intStorageLocationId', null);
            current.set('intLotId', null);
            current.set('strLotNumber', null);
            current.set('intNewLotId', null);
            current.set('strNewLotNumber', null);
            current.set('dblAdjustByQuantity', null);
            current.set('dblNewQuantity', null);
            current.set('dblNewCost', null);
            current.set('intNewItemUOMId', null);
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
        }
        else if (combo.itemId === 'cboStorageLocation')
        {
            current.set('intStorageLocationId', record.get('intStorageLocationId'));
            current.set('dblQuantity', null);
            current.set('dblCost', null);
            current.set('intItemUOMId', null);
            current.set('strItemUOM', null);
            current.set('intLotId', null);
            current.set('strLotNumber', null);
            current.set('intNewLotId', null);
            current.set('strNewLotNumber', null);
            current.set('dblAdjustByQuantity', null);
            current.set('dblNewQuantity', null);
            current.set('dblNewCost', null);
            current.set('intNewItemUOMId', null);
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
        }

        else if (combo.itemId === 'cboNewItemNo')
        {
            current.set('intNewItemId', record.get('intItemId'));
            current.set('strNewItemDescription', record.get('strDescription'));
        }
        else if (combo.itemId === 'cboLotNumber')
        {
            current.set('intLotId', record.get('intLotId'));
            current.set('dblQuantity', record.get('dblQty'));
            current.set('dblWeight', record.get('dblWeight'));
            current.set('dblCost', record.get('dblCost'));
            current.set('dblWeightPerQty', record.get('dblWeightPerQty'));
            current.set('intItemUOMId', record.get('intItemUOMId'));
            current.set('strItemUOM', record.get('strItemUOM'));
            current.set('strWeightUOM', record.get('strWeightUOM'));
            current.set('intWeightUOMId', record.get('intWeightUOMId'));
            current.set('strLotStatus', record.get('strLotStatus'));
            current.set('intLotStatusId', record.get('intLotStatusId'));
            current.set('dtmExpiryDate', record.get('dtmExpiryDate'));
            current.set('dblLineTotal', 0.00);

            // Clear the values for the following fields:
            current.set('dblAdjustByQuantity', null);
            current.set('dblNewQuantity', null);
            current.set('dblNewWeight', null);
            current.set('dblNewCost', null);
            current.set('dblNewWeightPerQty', null);
            current.set('intNewItemUOMId', null);
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
        else if (combo.itemId === 'cboNewUOM')
        {
            current.set('intNewItemUOMId', record.get('intItemUOMId'));
        }
        else if (combo.itemId === 'cboUOM')
        {
            current.set('intItemUOMId', record.get('intItemUOMId'));
        }

        else if (combo.itemId === 'cboNewWeightUOM')
        {
            current.set('intNewWeightUOMId', record.get('intItemUOMId'));
        }
        else if (combo.itemId === 'cboNewLotStatus')
        {
            current.set('intNewLotStatusId', record.get('intLotStatusId'));
        }
        else if (combo.itemId === 'cboNewLocation')
        {
            current.set('intNewLocationId', record.get('intCompanyLocationId'));
        }
        else if (combo.itemId === 'cboNewSubLocation')
        {
            current.set('intNewSubLocationId', record.get('intCompanyLocationSubLocationId'));
        }
        else if (combo.itemId === 'cboNewStorageLocation')
        {
            current.set('intNewStorageLocationId', record.get('intStorageLocationId'));
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
    getGridColumnByDataIndex: function(grid, dataIndex) {
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
    onAdjustmentTypeBeforeSelect: function(combo, record){
        var QuantityChange = 1;
        var UOMChange = 2;
        var ItemChange = 3;
        var LotStatusChange = 4;
        var SplitLot = 5;
        var ExpiryDateChange = 6;

        var data = record.getData();
        var adjustmentTypeId;
        if (data && (adjustmentTypeId = data.intAdjustmentTypeId)){

            switch (adjustmentTypeId)
            {
                case QuantityChange:
                case LotStatusChange:
                case ExpiryDateChange:
                case SplitLot:
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

    calculateLineTotal: function(newQuantity, newCost, record){
        var lineTotal = 0.00
            ,originalQuantity = 0.00
            ,originalCost = 0.00
            ,cost;


        if (record){
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

    calculateNewNetWeight: function(quantity, weight, record){
        var newWeightPerQty = null;
        var newQty
            ,newWeight;

        // Calculate a new Wgt per Qty if there is a valid new wgt.
        if (record){

            // Get the new values
            newQty = Ext.isNumeric(quantity) ? quantity : record.get('dblNewQuantity');
            newWeight = Ext.isNumeric(weight) ? weight : record.get('dblNewWeight');

            // If new qty is intentionally set to null, use the original qty
            if (quantity === false){
                quantity = record.get('dblQuantity');
                newQty = null;
            }

            // If new weight is intentionally set to null, use the original weight
            if (weight === false){
                weight = record.get('dblWeight');
                newWeight = null;
            }

            // If new values are both null, set the weight per qty back to null
            if (newQty === null && newWeight === null){
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

                if (Ext.isNumeric(weight) && quantity != 0){
                    newWeightPerQty = weight / quantity;
                }
            }

            record.set('dblNewWeightPerQty', newWeightPerQty);
        }
    },

    onNumNewQuantityChange: function(control, newQuantity, oldValue, eOpts ){
        var me = this;
        var grid = control.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        if (current){
            me.calculateLineTotal(newQuantity, null, current);
            me.calculateNewNetWeight((newQuantity === null ? false : newQuantity), null, current);

            var qty = current.get('dblQuantity'),
                adjustByQty  = null;

            if (Ext.isNumeric(qty) && Ext.isNumeric(newQuantity))
            {
                adjustByQty = newQuantity - qty;
            }
            current.set('dblAdjustByQuantity', adjustByQty);
        }
    },

    onNumAdjustByQuantityChange: function(control, newAdjustByQty, oldValue, eOpts ){
        var grid = control.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        if (current){
            var qty = current.get('dblQuantity'),
                newQty = null;

            if (Ext.isNumeric(qty) && Ext.isNumeric(newAdjustByQty))
            {
                newQty = qty + newAdjustByQty;
            }

            current.set('dblNewQuantity', newQty);
        }
    },

    onNumNewUnitCostChange: function(control, newCost, oldValue, eOpts ){
        var me = this;
        var grid = control.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        if (current){
            me.calculateLineTotal(null, newCost, current);
        }
    },

    onNumNewNetWeightChange: function(control, newNetWeight, oldValue, eOpts ){
        var me = this;
        var grid = control.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        if (current) {
            me.calculateNewNetWeight(null, (newNetWeight === null ? false : newNetWeight), current);
        }
    },

    onAfterPost: function(success, message) {
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
                function(){
                    message = message ? message : '';

                    var outdatedStock;

                    outdatedStock = message.indexOf('The stock on hand is outdated for');
                    if (outdatedStock == -1){
                        outdatedStock = message.indexOf('The lot expiry dates are outdated for');
                    }

                    if (outdatedStock !== -1) {
                        win.context.data.load();
                    }
                }
            );
        }
    },

    onPostOrUnPostClick: function(button, e, eOpts) {
        var me = this;
        var win = button.up('window');
        var context = win.context;

        var doPost = function() {
            var strAdjustmentNo = win.viewModel.data.current.get('strAdjustmentNo');
            var posted = win.viewModel.data.current.get('ysnPosted');

            var options = {
                postURL             : '../Inventory/api/InventoryAdjustment/PostTransaction',
                strTransactionId    : strAdjustmentNo,
                isPost              : !posted,
                isRecap             : false,
                callback            : me.onAfterPost,
                scope               : me
            };

            CashManagement.common.BusinessRules.callPostRequest(options);
        };

        // If there is no data change, do the post.
        if (!context.data.hasChanges()){
            doPost();
            return;
        }

        // Save has data changes first before doing the post.
        context.data.saveRecord({
            successFn: function() {
                doPost();
            }
        });
    },

    onRecapClick: function(button, e, eOpts) {
        var me = this;
        var win = button.up('window');
        var cboCurrency = null;
        var context = win.context;

        var doRecap = function(recapButton, currentRecord, currency){

            // Call the buildRecapData to generate the recap data
            CashManagement.common.BusinessRules.buildRecapData({
                postURL: '../Inventory/api/InventoryAdjustment/PostTransaction',
                strTransactionId: currentRecord.get('strAdjustmentNo'),
                ysnPosted: currentRecord.get('ysnPosted'),
                scope: me,
                success: function(){
                    // If data is generated, show the recap screen.
                    CashManagement.common.BusinessRules.showRecap({
                        strTransactionId: currentRecord.get('strAdjustmentNo'),
                        ysnPosted: currentRecord.get('ysnPosted'),
                        dtmDate: currentRecord.get('dtmAdjustmentDate'),
                        strCurrencyId: currency,
                        dblExchangeRate: 1,
                        scope: me,
                        postCallback: function(){
                            me.onPostOrUnPostClick(recapButton);
                        },
                        unpostCallback: function(){
                            me.onPostOrUnPostClick(recapButton);
                        }
                    });
                },
                failure: function(message){
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
        if (!context.data.hasChanges()){
            doRecap(button, win.viewModel.data.current, cboCurrency);
            return;
        }

        // Save has data changes first before doing the post.
        context.data.saveRecord({
            successFn: function() {
                doRecap(button, win.viewModel.data.current, cboCurrency);
            }
        });
    },

    onNewUOMChange: function(control, newUOM, oldValue, eOpts ){
        var me = this;
        var grid = control.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        if (current && (newUOM === null || newUOM === '')){
            current.set('intNewItemUOMId', null);
        }
    },

    onUOMChange: function(control, newUOM, oldValue, eOpts ){
        var me = this;
        var grid = control.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        if (current && (newUOM === null || newUOM === '')){
            current.set('intItemUOMId', null);
        }
    },


    onNewWeightUOMChange: function(control, newWeightUOM, oldValue, eOpts ){
        var me = this;
        var grid = control.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        if (current && (newWeightUOM === null || newWeightUOM === '')){
            current.set('intNewWeightUOMId', null);
        }
    },

    onNewLotStatusChange: function(control, newLotStatus, oldValue, eOpts ){
        var me = this;
        var grid = control.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        if (current && (newLotStatus === null || newLotStatus === '')){
            current.set('intNewLotStatusId', null);
        }
    },

    onInventoryClick: function(button, e, eOpts) {
        var win = button.up('window');
        var grd = win.down('#grdInventoryAdjustment');

        var selected = grd.getSelectionModel().getSelection();

        if (selected) {
            if (selected.length > 0){
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

    init: function(application) {
        this.control({
            "#cboItemNo": {
                select: this.onAdjustmentDetailSelect
            },
            "#cboNewItemNo": {
                select: this.onAdjustmentDetailSelect
            },
            "#cboStorageLocation": {
                select: this.onAdjustmentDetailSelect
            },
            "#cboLotNumber": {
                select: this.onAdjustmentDetailSelect
            },
            "#cboSubLocation": {
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
                click: this.onPostOrUnPostClick
            },
            "#btnUnpost": {
                click: this.onPostOrUnPostClick
            },
            "#btnRecap": {
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
            }
        });
    }
});