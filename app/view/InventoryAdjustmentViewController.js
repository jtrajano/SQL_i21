Ext.define('Inventory.view.InventoryAdjustmentViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icinventoryadjustment',

    config: {
        searchConfig: {
            title: 'Search Inventory Adjustment',
            type: 'Inventory.InventoryAdjustment',
            api: {
                read: '../Inventory/api/Adjustment/SearchAdjustments'
            },
            columns: [
                {dataIndex: 'intInventoryAdjustmentId', text: "Inventory Adjustment Id", flex: 1, defaultSort: true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strAdjustmentNo', text: 'Adjustment No', flex: 1, dataType: 'string'},
                {dataIndex: 'strLocationName', text: 'Location Id', flex: 1, dataType: 'string'},
                {dataIndex: 'strDescription', text: 'Description', flex: 1, dataType: 'string'},
                //{dataIndex: 'strAdjustmentType', text: 'Adjustment Type', flex: 1, dataType: 'string'},
                {dataIndex: 'dtmAdjustmentDate', text: 'Date', flex: 1, dataType: 'date', xtype: 'datecolumn'}
            ]
        },
        binding: {
            bind: {
                title: 'Inventory Adjustment - {current.strAdjustmentNo}'
            },
            cboLocation: {
                value: '{current.intLocationId}',
                store: '{location}'
            },
            dtmDate: '{current.dtmAdjustmentDate}',
            cboAdjustmentType: {
                value: '{current.intAdjustmentType}',
                store: '{adjustmentTypes}'
            },
            txtAdjustmentNumber: '{current.strAdjustmentNo}',
            txtDescription: '{current.strDescription}',

            grdInventoryAdjustment: {
                colItemNumber: {
                    dataIndex: 'strItemNo',
                    editor: {
                        store: '{item}',
                        defaultFilters: [{
                            column: 'intLocationId',
                            value: '{current.intLocationId}',
                            conjunction: 'and'
                        }]
                    }
                },

                colDescription: 'strItemDescription',

                colSubLocation: {
                    dataIndex: 'strSubLocation',
                    editor: {
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
                    }
                },

                colStorageLocation: {
                    dataIndex: 'strStorageLocation',
                    editor: {
                        store: '{storageLocation}',
                        defaultFilters: [{
                            column: 'intLocationId',
                            value: '{current.intLocationId}',
                            conjunction: 'and'
                        }]
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
                                conjunction: 'and'
                            },
                            {
                                column: 'intStorageLocationId',
                                value: '{grdInventoryAdjustment.selection.intStorageLocationId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },

                colNewLotNumber: {
                    dataIndex: 'strNewLotNumber',
                    editor: {
                        store: '{newLot}'
                    }
                },

                colQuantity: 'dblQuantity',

                colNewQuantity: 'dblNewQuantity',

                colUOM: 'strItemUOM',

                colNewUOM: {
                    dataIndex: 'strNewItemUOM',
                    editor: {
                        store: '{newItemUOM}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryAdjustment.selection.intItemId}',
                            conjunction: 'and'
                        }]
                    }
                },

                colNetWeight: 'dblWeight',

                colNewNetWeight: 'dblNewWeight',

                colWeightUOM: {
                    dataIndex: 'strWeightUOM',
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
                    editor: {
                        store: '{weightUOM}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryAdjustment.selection.intItemId}',
                            conjunction: 'and'
                        }]
                    }
                },

                colWeightPerQty: 'dblWeightPerQty',

                colNewWeightPerQty: 'dblNewWeightPerQty',

                colUnitCost: 'dblCost',

                colNewUnitCost: 'dblNewCost',

                colNewItemNumber: {
                    dataIndex: 'strNewItemNo',
                    editor: {
                        store: '{newItem}',
                        defaultFilters: [{
                            column: 'intLocationId',
                            value: '{current.intLocationId}',
                            conjunction: 'and'
                        }]
                    }
                },

                colNewItemDescription: 'strNewItemDescription',

                colExpiryDate: 'dtmExpiryDate',

                colNewExpiryDate: 'dtmNewExpiryDate',

                colLotStatus: 'strLotStatus',

                colNewLotStatus: {
                    dataIndex: 'strNewLotStatus',
                    editor: {
                        store: '{newLotStatus}'
                    }
                }
            },

            grdNotes: {
                colNoteDescription: 'strDescription',
                colNotes: 'strNotes'
            }
        }
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Adjustment', { pageSize: 1 });

        win.context = Ext.create('iRely.Engine', {
            window : win,
            store  : store,
            createRecord : me.createRecord,
            binding: me.config.binding,
            attachment: Ext.create('iRely.attachment.Manager', {
                type: 'Inventory.InventoryAdjustment',
                window: win
            }),
            details: [
                {
                    key: 'tblICInventoryAdjustmentDetails',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdInventoryAdjustment'),
                        deleteButton : win.down('#btnRemoveItem')
                    })
                },
                {
                    key: 'tblICInventoryAdjustmentNotes',
                    component: Ext.create('iRely.grid.Manager', {
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

            // Clear the values for the following fields:
            current.set('strSubLocation', null);
            current.set('strStorageLocation', null);
            current.set('intLotId', null);
            current.set('strLotNumber', null);
            current.set('intNewLotId', null);
            current.set('strNewLotNumber', null);
            current.set('dblQuantity', null);
            current.set('dblNewQuantity', null);
            current.set('dblCost', null);
            current.set('dblNewCost', null);
            current.set('intItemUOMId', null);
            current.set('strItemUOM', null);
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
        else if (combo.itemId === 'cboSubLocation')
        {
            current.set('intSubLocationId', record.get('intCompanyLocationSubLocationId'));
        }
        else if (combo.itemId === 'cboStorageLocation')
        {
            current.set('intStorageLocationId', record.get('intStorageLocationId'));
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
        }
        else if (combo.itemId === 'cboNewUOM')
        {
            current.set('intNewItemUOMId', record.get('intItemUOMId'));
        }
        else if (combo.itemId === 'cboNewWeightUOM')
        {
            current.set('intNewWeightUOMId', record.get('intItemUOMId'));
        }
        else if (combo.itemId === 'cboNewStatus')
        {
            current.set('intNewLotStatusId', record.get('intLotStatusId'));
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

    onAdjustmentTypeChange: function(obj, newValue, oldValue, eOpts) {
        var win = obj.up('window');
        var grid = win.down('#grdInventoryAdjustment');

        var colNewLot = this.getGridColumnByDataIndex(grid, 'strNewLotNumber');

        var colQuantity = this.getGridColumnByDataIndex(grid, 'dblQuantity');
        var colNewQuantity = this.getGridColumnByDataIndex(grid, 'dblNewQuantity');

        var colUOM = this.getGridColumnByDataIndex(grid, 'strItemUOM');
        var colNewUOM = this.getGridColumnByDataIndex(grid, 'strNewItemUOM');

        var colNetWeight = this.getGridColumnByDataIndex(grid, 'dblWeight');
        var colNewNetWeight = this.getGridColumnByDataIndex(grid, 'dblNewWeight');

        var colWeightUOM = this.getGridColumnByDataIndex(grid, 'strWeightUOM');
        var colNewWeightUOM = this.getGridColumnByDataIndex(grid, 'strNewWeightUOM');

        var colWeightPerQty = this.getGridColumnByDataIndex(grid, 'dblWeightPerQty');
        var colNewWeightPerQty = this.getGridColumnByDataIndex(grid, 'dblNewWeightPerQty');

        var colUnitCost = this.getGridColumnByDataIndex(grid, 'dblCost');
        var colNewUnitCost = this.getGridColumnByDataIndex(grid, 'dblNewCost');

        var colNewItemNumber = this.getGridColumnByDataIndex(grid, 'strNewItemNo');
        var colNewItemDescription = this.getGridColumnByDataIndex(grid, 'strNewItemDescription');

        var colExpiryDate = this.getGridColumnByDataIndex(grid, 'dtmExpiryDate');
        var colNewExpiryDate = this.getGridColumnByDataIndex(grid, 'dtmNewExpiryDate');

        var colLotStatus = this.getGridColumnByDataIndex(grid, 'strLotStatus');
        var colNewLotStatus = this.getGridColumnByDataIndex(grid, 'strNewLotStatus');

        var QuantityChange = 1;
        var UOMChange = 2;
        var ItemChange = 3;
        var LotStatusChange = 4;
        var LotIdChange = 5;
        var ExpiryDateChange = 6;

        var hide = true;
        var show = false;

        switch (newValue) {
            case QuantityChange:
                // Hide columns:
                colNewLot.setHidden(hide);
                colNewItemNumber.setHidden(hide);
                colNewItemDescription.setHidden(hide);
                colExpiryDate.setHidden(hide);
                colNewExpiryDate.setHidden(hide);
                colLotStatus.setHidden(hide);
                colNewLotStatus.setHidden(hide);

                // Show columns:
                colQuantity.setHidden(show);
                colNewQuantity.setHidden(show);

                colUOM.setHidden(show);
                colNewUOM.setHidden(show);

                colNetWeight.setHidden(show);
                colNewNetWeight.setHidden(show);

                colWeightUOM.setHidden(show);
                colNewWeightUOM.setHidden(show);

                colWeightPerQty.setHidden(show);
                colNewWeightPerQty.setHidden(show);

                colUnitCost.setHidden(show);
                colNewUnitCost.setHidden(show);
                break;
            case UOMChange:
                // todo
                break;
            case ItemChange:
                // todo
                break;
            case LotStatusChange:
                // todo
                break;
            case LotIdChange:
                // todo
                break;
            case ExpiryDateChange:
                // todo
                break;
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

        var data = record.getData();
        var adjustmentTypeId;
        if (data && (adjustmentTypeId = data.intAdjustmentTypeId)){
            if (adjustmentTypeId !== QuantityChange){
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

    onNumNewQuantityChange: function(control, newQuantity, oldValue, eOpts ){
        var grid = control.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        var lineTotal = 0.00;

        if (current){
            newQuantity = Ext.isNumeric(newQuantity) ? newQuantity : 0.00;

            var cost = current.get('dblNewCost');
            cost = Ext.isNumeric(cost) ? cost : current.get('dblCost');
            if (Ext.isNumeric(cost)){
                lineTotal = newQuantity * cost;
            }
        }

        current.set('dblLineTotal', lineTotal);
    },

    onNumNewUnitCostChange: function(control, newCost, oldValue, eOpts ){
        var grid = control.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        var lineTotal = 0.00;

        if (current){
            newCost = (newCost && newCost != 0) ? newCost : current.get('dblCost');

            var quantity = current.get('dblNewQuantity');
            if (Ext.isNumeric(quantity)){
                lineTotal = quantity * newCost;
            }
        }

        current.set('dblLineTotal', lineTotal);
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
            "#cboNewUOM": {
                select: this.onAdjustmentDetailSelect
            },
            "#cboWeightUOM": {
                select: this.onAdjustmentDetailSelect
            },
            "#cboNewStatus": {
                select: this.onAdjustmentDetailSelect
            },
            "#cboAccountCategory": {
                select: this.onAdjustmentDetailSelect
            },
            "#cboCreditAccount": {
                select: this.onAdjustmentDetailSelect
            },
            "#cboDebitAccount": {
                select: this.onAdjustmentDetailSelect
            },
            "#cboAdjustmentType": {
                change: this.onAdjustmentTypeChange,
                beforeselect: this.onAdjustmentTypeBeforeSelect
            },
            "#numNewQuantity": {
                change: this.onNumNewQuantityChange
            },
            "#numNewUnitCost": {
                change: this.onNumNewUnitCostChange
            }

        });
    }
});

