Ext.define('Inventory.view.InventoryTransferViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icinventorytransfer',

    config: {
        searchConfig: {
            title: 'Search Inventory Transfer',
            type: 'Inventory.InventoryTransfer',
            api: {
                read: '../Inventory/api/Transfer/SearchTransfers'
            },
            columns: [
                {dataIndex: 'intInventoryTransferId', text: "Inventory Transfer Id", flex: 1, defaultSort: true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strTransferNo', text: 'Transfer No', flex: 1, dataType: 'string'},
                {dataIndex: 'dtmTransferDate', text: 'Date', flex: 1, dataType: 'date', xtype: 'datecolumn'},
                {dataIndex: 'strTransferType', text: 'Transfer Type', flex: 1, dataType: 'string'},
                {dataIndex: 'strDescription', text: 'Description', flex: 1, dataType: 'string'},
                {dataIndex: 'strFromLocation', text: 'From Location', flex: 1, dataType: 'string'},
                {dataIndex: 'strToLocation', text: 'To Location', flex: 1, dataType: 'string'},
                {dataIndex: 'strStatus', text: 'Status', flex: 1, dataType: 'string'},
                {dataIndex: 'ysnPosted', text: 'Posted', flex: 1, dataType: 'boolean', xtype: 'checkcolumn'}
            ]
        },
        binding: {
            bind: {
                title: 'Inventory Transfer - {current.strTransferNo}'
            },
            txtTransferNumber: '{current.strTransferNo}',
            dtmTransferDate: {
                value: '{current.dtmTransferDate}',
                readOnly: '{current.ysnPosted}'
            },
            cboTransferType: {
                value: '{current.strTransferType}',
                store: '{transferTypes}',
                readOnly: '{current.ysnPosted}'
            },
            cboTransferredBy: {
                value: '{current.intTransferredById}',
                store: '{userList}'
            },
            txtDescription: {
                value: '{current.strDescription}',
                readOnly: '{current.ysnPosted}'
            },
            cboFromLocation: {
                value: '{current.intFromLocationId}',
                store: '{fromLocation}',
                readOnly: '{current.ysnPosted}'
            },
            cboToLocation: {
                value: '{current.intToLocationId}',
                store: '{toLocation}',
                readOnly: '{current.ysnPosted}'
            },
            chkShipmentRequired: {
                value: '{current.ysnShipmentRequired}',
                readOnly: '{current.ysnPosted}'
            },
            cboStatus: {
                value: '{current.intStatusId}',
                store: '{status}',
                readOnly: '{current.ysnPosted}'
            },

            cboShipVia: {
                value: '{current.intShipViaId}',
                store: '{shipVia}',
                readOnly: '{current.ysnPosted}'
            },
            cboFreightUOM: {
                value: '{current.intFreightUOMId}',
                store: '{uom}',
                readOnly: '{current.ysnPosted}'
            },
            txtTaxAmount: '{current.dblTaxAmount}',

            pnlFreight: {
                hidden: '{hideOnStorageToStorage}'
            },

            grdInventoryTransfer: {
                readOnly: '{current.ysnPosted}',
                colItemNumber: {
                    dataIndex: 'strItemNo',
                    editor: {
                        store: '{item}',
                        defaultFilters: [{
                            column: 'intLocationId',
                            value: '{current.intFromLocationId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colDescription: 'strItemDescription',
                colLotID: {
                    dataIndex: 'strLotNumber',
                    editor: {
                        store: '{lot}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryTransfer.selection.intItemId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colFromSubLocation: {
                    dataIndex: 'strFromSubLocationName',
                    editor: {
                        store: '{fromSubLocation}',
                        defaultFilters: [{
                            column: 'intCompanyLocationId',
                            value: '{current.intFromLocationId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colFromStorage: {
                    dataIndex: 'strFromStorageLocationName',
                    editor: {
                        store: '{fromStorageLocation}',
                        defaultFilters: [{
                            column: 'intLocationId',
                            value: '{current.intFromLocationId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colToSubLocation: {
                    dataIndex: 'strToSubLocationName',
                    editor: {
                        store: '{toSubLocation}',
                        defaultFilters: [{
                            column: 'intCompanyLocationId',
                            value: '{current.intToLocationId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colToStorage: {
                    dataIndex: 'strToStorageLocationName',
                    editor: {
                        store: '{fromStorageLocation}',
                        defaultFilters: [{
                            column: 'intLocationId',
                            value: '{current.intToLocationId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colAvailableQty: 'dblAvailableQty',
                colAvailableUOM: 'strAvailableUOM',

                colTransferQty: 'dblQuantity',
                colTransferUOM: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{itemUOM}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryTransfer.selection.intItemId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colWeightUOM: {
                    dataIndex: 'strWeightUOM',
                    editor: {
                        store: '{weightUOM}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryTransfer.selection.intItemId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colGross: 'dblGrossWeight',
                colTare: 'dblTareWeight',
                colNet: 'dblNetWeight',
                colNewLotID: {
                    dataIndex: 'strNewLotNumber',
                    editor: {
                        store: '{newLot}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryTransfer.selection.intItemId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colCost: 'dblCost',
                colTaxCode: {
                    dataIndex: 'strTaxCode',
                    editor: {
                        store: '{taxCode}'
                    }
                },
                colTaxAmount: 'dblTaxAmount',
                colFreightRate: {
                    dataIndex: 'dblFreightRate',
                    hidden: '{hideOnStorageToStorage}'
                },
                colFreightAmount: {
                    dataIndex: 'dblFreightAmount',
                    hidden: '{hideOnStorageToStorage}'
                }
            },

            grdNotes: {
                readOnly: '{current.ysnPosted}',
                colNoteType: 'strNoteType',
                colNote: 'strNotes'
            }
        }
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Transfer', { pageSize: 1 });

        var grdInventoryTransfer = win.down('#grdInventoryTransfer');

        win.context = Ext.create('iRely.Engine', {
            window : win,
            store  : store,
            createRecord : me.createRecord,
            binding: me.config.binding,
            attachment: Ext.create('iRely.attachment.Manager', {
                type: 'Inventory.InventoryTransfer',
                window: win
            }),
            details: [
                {
                    key: 'tblICInventoryTransferDetails',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdInventoryTransfer,
                        deleteButton : grdInventoryTransfer.down('#btnRemoveItem')
                    })
                },
                {
                    key: 'tblICInventoryTransferNotes',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdNotes'),
                        deleteButton : win.down('#btnRemoveNotes')
                    })
                }
            ]
        });

//        var cepItem = grdInventoryTransfer.getPlugin('cepItem');
//        if (cepItem){
//            cepItem.on({
//                validateedit: me.onEditDetails,
//                scope: me
//            });
//        }

        var colAvailableQty = grdInventoryTransfer.columns[7];
        var colAvailableUOM = grdInventoryTransfer.columns[8];
        colAvailableQty.renderer = this.AvailableQtyRenderer;
        colAvailableUOM.renderer = this.AvailableUOMRenderer;
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
                        column: 'intInventoryTransferId',
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
        var record = Ext.create('Inventory.model.Transfer');
        record.set('strTransferType', 'Location to Location');
        if (app.DefaultLocation > 0){
            record.set('intFromLocationId', app.DefaultLocation);
            record.set('intToLocationId', app.DefaultLocation);
        }
        if (app.EntityId > 0)
            record.set('intTransferredById', app.EntityId);
        record.set('dtmTransferDate', today);
        record.set('intStatusId', 1);
        action(record);
    },

    AvailableQtyRenderer: function (value, metadata, record) {
        if (!metadata) return;
        var grid = metadata.column.up('grid');
        var win = grid.up('window');
        var items = win.viewModel.storeInfo.itemStock;
        var currentMaster = win.viewModel.data.current;

        if (currentMaster) {
            if (record) {
                if (items) {
                    var index = items.data.findIndexBy(function (row) {
                        if (row.get('intItemId') === record.get('intItemId') &&
                            row.get('intLocationId') === currentMaster.get('intFromLocationId') &&
                            row.get('intItemUOMId') === record.get('intItemUOMId') &&
                            row.get('intSubLocationId') === record.get('intFromSubLocationId') &&
                            row.get('intStorageLocationId') === record.get('intFromStorageLocationId')) {
                            return true;
                        }
                    });
                    if (index >= 0) {
                        var stockUOM = items.getAt(index);
                        return stockUOM.get('dblOnHand');
                    }
                }
            }
        }
    },

    AvailableUOMRenderer: function (value, metadata, record) {
        if (!metadata) return;
        var grid = metadata.column.up('grid');
        var win = grid.up('window');
        var items = win.viewModel.storeInfo.itemStock;
        var currentMaster = win.viewModel.data.current;

        if (currentMaster) {
            if (record) {
                if (items) {
                    var index = items.data.findIndexBy(function (row) {
                        if (row.get('intItemId') === record.get('intItemId') &&
                            row.get('intLocationId') === currentMaster.get('intFromLocationId') &&
                            row.get('intItemUOMId') === record.get('intItemUOMId') &&
                            row.get('intSubLocationId') === record.get('intFromSubLocationId') &&
                            row.get('intStorageLocationId') === record.get('intFromStorageLocationId')) {
                            return true;
                        }
                    });
                    if (index >= 0) {
                        var stockUOM = items.getAt(index);
                        return stockUOM.get('strUnitMeasure');
                    }
                }
            }
        }
    },

    onTransferDetailSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();

        if (combo.itemId === 'cboItem') {
            current.set('intItemId', records[0].get('intItemId'));
            current.set('strItemDescription', records[0].get('strItemDescription'));
            current.set('strFromSubLocationName', records[0].get('strSubLocationName'));
            current.set('intFromSubLocationId', records[0].get('intSubLocationId'));
            current.set('strFromStorageLocationName', records[0].get('strStorageLocationName'));
            current.set('intFromStorageLocationId', records[0].get('intStorageLocationId'));
            current.set('dblAvailableQty', records[0].get('dblOnHand'));
            current.set('strAvailableUOM', records[0].get('strUnitMeasure'));
        }
        else if (combo.itemId === 'cboLot') {
            current.set('intLotId', records[0].get('intLotId'));
        }
        else if (combo.itemId === 'cboFromSubLocation') {
            current.set('intFromSubLocationId', records[0].get('intCompanyLocationSubLocationId'));
        }
        else if (combo.itemId === 'cboFromStorage') {
            current.set('intFromStorageLocationId', records[0].get('intStorageLocationId'));
        }
        else if (combo.itemId === 'cboToSubLocation') {
            current.set('intToSubLocationId', records[0].get('intCompanyLocationSubLocationId'));
        }
        else if (combo.itemId === 'cboToStorage') {
            current.set('intToStorageLocationId', records[0].get('intStorageLocationId'));
        }
        else if (combo.itemId === 'cboUOM') {
            current.set('intItemUOMId', records[0].get('intItemUOMId'));
        }
        else if (combo.itemId === 'cboWeightUOM') {
            current.set('intItemWeightUOMId', records[0].get('intItemUOMId'));
        }
        else if (combo.itemId === 'cboNewLotID') {
            current.set('intNewLotId', records[0].get('intLotId'));
        }
        else if (combo.itemId === 'cboTaxCode') {
            current.set('intTaxCodeId', records[0].get('intTaxCodeId'));
        }
    },

    onEditDetails: function(editor, context, eOpts) {

    },

    onDetailGridColumnBeforeRender: function(column) {
        var me = this,
            win = column.up('window'),
            grid = column.up('grid'),
            plugin = grid.getPlugin('cepItem'),
            current = plugin.getActiveRecord();

        if (!column) return false;

        column.getRenderer = function(record) {
            if (!record) return false;
            if (!current) return false;

            var columnId = column.itemId;

            switch (columnId) {
                case 'colAvailableQty':

                    break;
                case 'colAvailableUOM':

                    break;
            }
        };
    },

    onViewItemClick: function(button, e, eOpts) {
        var win = button.up('window');
        var grd = win.down('#grdInventoryTransfer');

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

    onPostClick: function(button, e, eOpts) {
        var me = this;
        var win = button.up('window');
        var context = win.context;

        var doPost = function() {
            var strTransferNo = win.viewModel.data.current.get('strTransferNo');
            var posted = win.viewModel.data.current.get('ysnPosted');

            var options = {
                postURL             : '../Inventory/api/Transfer/Post',
                strTransactionId    : strTransferNo,
                isPost              : !posted,
                isRecap             : false,
                callback            : me.onAfterReceive,
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
        var context = win.context;

        var doRecap = function(recapButton, currentRecord){

            // Call the buildRecapData to generate the recap data
            CashManagement.common.BusinessRules.buildRecapData({
                postURL: '../Inventory/api/Transfer/Post',
                strTransactionId: currentRecord.get('strTransferNo'),
                ysnPosted: currentRecord.get('ysnPosted'),
                scope: me,
                success: function(){
                    // If data is generated, show the recap screen.
                    CashManagement.common.BusinessRules.showRecap({
                        strTransactionId: currentRecord.get('strTransferNo'),
                        ysnPosted: currentRecord.get('ysnPosted'),
                        dtmDate: currentRecord.get('dtmTransferDate'),
                        strCurrencyId: null,
                        dblExchangeRate: 1,
                        scope: me,
                        postCallback: function(){
                            me.onPostClick(recapButton);
                        },
                        unpostCallback: function(){
                            me.onPostClick(recapButton);
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
            doRecap(button, win.viewModel.data.current);
            return;
        }

        // Save has data changes first before doing the post.
        context.data.saveRecord({
            successFn: function() {
                doRecap(button, win.viewModel.data.current);
            }
        });
    },

    onAfterReceive: function(success, message) {
        if (success === true) {
            var me = this;
            var win = me.view;
            win.context.data.load();
        }
        else {
            iRely.Functions.showCustomDialog(iRely.Functions.dialogType.ERROR, iRely.Functions.dialogButtonType.OK, message);
        }
    },

    init: function(application) {
        this.control({
            "#cboItem": {
                select: this.onTransferDetailSelect
            },
            "#cboLot": {
                select: this.onTransferDetailSelect
            },
            "#cboFromSubLocation": {
                select: this.onTransferDetailSelect
            },
            "#cboFromStorage": {
                select: this.onTransferDetailSelect
            },
            "#cboToSubLocation": {
                select: this.onTransferDetailSelect
            },
            "#cboToStorage": {
                select: this.onTransferDetailSelect
            },
            "#cboUOM": {
                select: this.onTransferDetailSelect
            },
            "#cboWeightUOM": {
                select: this.onTransferDetailSelect
            },
            "#cboNewLotID": {
                select: this.onTransferDetailSelect
            },
            "#cboTaxCode": {
                select: this.onTransferDetailSelect
            },
            "#colAvailableQty": {
                beforerender: this.onDetailGridColumnBeforeRender
            },
            "#colAvailableUOM": {
                beforerender: this.onDetailGridColumnBeforeRender
            },
            "#btnPost": {
                click: this.onPostClick
            },
            "#btnRecap": {
                click: this.onRecapClick
            },
            "#btnViewItem": {
                click: this.onViewItemClick
            }
        });
    }
});
