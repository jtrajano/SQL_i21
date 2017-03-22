Ext.define('Inventory.view.InventoryTransferViewController', {
    extend: 'Inventory.view.InventoryBaseViewController',
    alias: 'controller.icinventorytransfer',
    requires: [
        'CashManagement.common.Text',
        'CashManagement.common.BusinessRules'
    ],

    config: {
        binding: {
            bind: {
                title: 'Inventory Transfer - {current.strTransferNo}'
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
            btnPost: {
                hidden: '{hidePostButton}'
            },
            btnUnpost: {
                hidden: '{hideUnpostButton}'
            },
            btnPostPreview: {
                hidden: '{hidePostButton}'
            },
            btnUnpostPreview: {
                hidden: '{hideUnpostButton}'  
            },
            btnAddItem: {
                hidden: '{current.ysnPosted}'
            },
            btnRemoveItem: {
                hidden: '{current.ysnPosted}'
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
            cboSourceType: {
                value: '{current.intSourceType}',
                store: '{sourceTypes}',
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

//            cboShipVia: {
//                value: '{current.intShipViaId}',
//                store: '{shipVia}',
//                readOnly: '{current.ysnPosted}'
//            },
//            cboFreightUOM: {
//                value: '{current.intFreightUOMId}',
//                store: '{uom}',
//                readOnly: '{current.ysnPosted}'
//            },
//            txtTaxAmount: '{current.dblTaxAmount}',
//
//            pnlFreight: {
//                hidden: '{hideOnStorageToStorage}'
//            },

            grdInventoryTransfer: {
                readOnly: '{current.ysnPosted}',
                colSourceNumber: {
                    dataIndex: 'strSourceNumber',
                    hidden: '{checkHideSourceNo}'
                },
                colItemNumber: {
                    dataIndex: 'strItemNo',
                    editor: {
                        store: '{item}',
                        defaultFilters: [
                            {
                                column: 'intLocationId',
                                value: '{current.intFromLocationId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colDescription: 'strItemDescription',
                colFromSubLocation: {
                    dataIndex: 'strFromSubLocationName',    
                    editor: {
                        store: '{fromSubLocation}',
                        readOnly: '{readOnlyInventoryTransferField}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryTransfer.selection.intItemId}',
                            conjunction: 'and'
                        },{
                            column: 'intLocationId',
                            value: '{current.intFromLocationId}',
                            conjunction: 'and'
                        },{
                            column: 'dblOnHand',
                            value: '0',
                            conjunction: 'and',
                            condition: 'gt'
                        },{
                            column: 'ysnStockUnit',
                            value: true,
                            conjunction: 'and',
                            condition: 'eq'
                        }
                        ]
                    }
                },
                colFromStorage: {
                    dataIndex: 'strFromStorageLocationName',
                    editor: {
                        store: '{fromStorageLocation}',
                        readOnly: '{readOnlyInventoryTransferField}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryTransfer.selection.intItemId}',
                            conjunction: 'and'
                        },{
                            column: 'intLocationId',
                            value: '{current.intFromLocationId}',
                            conjunction: 'and'
                        },{
                            column: 'intSubLocationId',
                            value: '{grdInventoryTransfer.selection.intFromSubLocationId}',
                            conjunction: 'and'
                        },{
                            column: 'dblOnHand',
                            value: '0',
                            conjunction: 'and',
                            condition: 'gt'
                        }]
                    }
                },
                colLotID: {
                    dataIndex: 'strLotNumber',
                    editor: {
                        store: '{lot}',
                        readOnly: '{readOnlyInventoryTransferField}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryTransfer.selection.intItemId}',
                            conjunction: 'and'
                        },{
                            column: 'intLocationId',
                            value: '{current.intFromLocationId}',
                            conjunction: 'and'
                        },{
                            column: 'intSubLocationId',
                            value: '{grdInventoryTransfer.selection.intFromSubLocationId}',
                            conjunction: 'and'
                        },{
                            column: 'intStorageLocationId',
                            value: '{grdInventoryTransfer.selection.intFromStorageLocationId}',
                            conjunction: 'and'
                        },{
                            column: 'intOwnershipType',
                            value: '{grdInventoryTransfer.selection.intOwnershipType}',
                            conjunction: 'and'
                        }]
                    }
                },
                colAvailableQty: 'dblAvailableQty',
                colAvailableUOM: 'strAvailableUOM',
                colToSubLocation: {
                    dataIndex: 'strToSubLocationName',
                    editor: {
                        store: '{toSubLocation}',
                        readOnly: '{readOnlyInventoryTransferField}',
                        defaultFilters: [
                            {
                                column: 'intCompanyLocationId',
                                value: '{current.intToLocationId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colToStorage: {
                    dataIndex: 'strToStorageLocationName',
                    editor: {
                        store: '{toStorageLocation}',
                        readOnly: '{readOnlyInventoryTransferField}',
                        defaultFilters: [
                            {
                                column: 'intLocationId',
                                value: '{current.intToLocationId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'intSubLocationId',
                                value: '{grdInventoryTransfer.selection.intToSubLocationId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colOwnershipType: {
                    dataIndex: 'strOwnershipType',
                    editor: {
                        readOnly: '{readOnlyInventoryTransferField}',
                        origValueField: 'intOwnershipType',
                        origUpdateField: 'intOwnershipType',
                        store: '{ownershipTypes}'
                    }
                },
                colTransferQty: 'dblQuantity',
                //colTransferUOM: {
                //    dataIndex: 'strUnitMeasure',
                //    editor: {
                //        readOnly: '{checkLotExists}',
                //        store: '{itemUOM}',
                //        defaultFilters: [{
                //            column: 'intItemId',
                //            value: '{grdInventoryTransfer.selection.intItemId}',
                //            conjunction: 'and'
                //        }]
                //    }
                //},
                colNewLotID: {
                    dataIndex: 'strNewLotId'
                },
                colCost: 'dblCost',
                chkDestinationWeights: {
                    dataIndex: 'ysnWeights',
                    disabled: '{destinationWeightsDisabled}'
                }
//                colTaxCode: {
//                    dataIndex: 'strTaxCode',
//                    editor: {
//                        store: '{taxCode}'
//                    }
//                },
//                colTaxAmount: 'dblTaxAmount',
//                colFreightRate: {
//                    dataIndex: 'dblFreightRate',
//                    hidden: '{hideOnStorageToStorage}'
//                },
//                colFreightAmount: {
//                    dataIndex: 'dblFreightAmount',
//                    hidden: '{hideOnStorageToStorage}'
//                }
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
            enableActivity: true,
            createTransaction: Ext.bind(me.createTransaction, me),
            enableAudit: true,
            include: 'tblICInventoryTransferDetails.vyuICGetInventoryTransferDetail',
            onSaveClick: me.saveAndPokeGrid(win, grdInventoryTransfer),
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
                        deleteButton : grdInventoryTransfer.down('#btnRemoveItem'),
                        createRecord : me.createDetailRecord
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
            strTransactionNo: current.get('strTransferNo'), //Unique field
            intEntityId: current.get('intEntityId'), //Entity Associated
            dtmDate: current.get('dtmDate') // Date
        })
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
        record.set('intSourceType', 0);
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

    createDetailRecord: function(config, action) {
        var today = new Date();
        var record = Ext.create('Inventory.model.TransferDetail');
        record.set('intOwnershipType', 1);
        record.set('strOwnershipType', 'Own');
        action(record);
    },

    AvailableQtyRenderer: function (value, metadata, record) {
        if (!metadata) return value;
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

        return value;
    },

    AvailableUOMRenderer: function (value, metadata, record) {
        if (!metadata) return value;
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
        return value;
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
            current.set('strItemDescription', records[0].get('strDescription'));
            current.set('intItemUOMId', records[0].get('intStockUOMId'));
            current.set('dblAvailableQty', records[0].get('dblAvailable'));
            current.set('strAvailableUOM', records[0].get('strStockUOM'));
            current.set('dblOriginalAvailableQty', records[0].get('dblAvailable'));
            current.set('dblOriginalStorageQty', records[0].get('dblStorageQty'));

        }
        else if (combo.itemId === 'cboLot') {
            current.set('intLotId', records[0].get('intLotId'));
            current.set('dblAvailableQty', records[0].get('dblQty'));
            current.set('strAvailableUOM', records[0].get('strItemUOM'));
            current.set('intItemUOMId', records[0].get('intItemUOMId'));

            current.set('dblOriginalAvailableQty', records[0].get('dblQty'));
            current.set('dblOriginalStorageQty', records[0].get('dblQty'));

        }
        else if (combo.itemId === 'cboFromSubLocation') {
            current.set('intFromSubLocationId', records[0].get('intSubLocationId'));
            current.set('intFromStorageLocationId', records[0].get('intStorageLocationId'));

            current.set('strFromStorageLocationName', records[0].get('strStorageLocationName'));

            current.set('strAvailableUOM', records[0].get('strUnitMeasure'));

            current.set('dblOriginalAvailableQty', records[0].get('dblAvailableQty'));
            current.set('dblOriginalStorageQty', records[0].get('dblStorageQty'));
            current.set('intItemUOMId', records[0].get('intItemUOMId'));

            switch (current.get('intOwnershipType')) {
                case 1:
                    current.set('dblAvailableQty', current.get('dblOriginalAvailableQty'));
                    break;
                case 2:
                    current.set('dblAvailableQty', current.get('dblOriginalStorageQty'));
                    break;
                default:
                    current.set('dblAvailableQty', current.get('dblOriginalAvailableQty'));
            }
        }
        else if (combo.itemId === 'cboFromStorage') {
            current.set('intFromSubLocationId', records[0].get('intSubLocationId'));
            current.set('intFromStorageLocationId', records[0].get('intStorageLocationId'));

            current.set('strFromSubLocationName', records[0].get('strSubLocationName'));

            current.set('strAvailableUOM', records[0].get('strUnitMeasure'));

            current.set('dblOriginalAvailableQty', records[0].get('dblAvailableQty'));
            current.set('dblOriginalStorageQty', records[0].get('dblStorageQty'));
            current.set('intItemUOMId', records[0].get('intItemUOMId'));

            switch (current.get('intOwnershipType')) {
                case 1:
                    current.set('dblAvailableQty', current.get('dblOriginalAvailableQty'));
                    break;
                case 2:
                    current.set('dblAvailableQty', current.get('dblOriginalStorageQty'));
                    break;
                default:
                    current.set('dblAvailableQty', current.get('dblOriginalAvailableQty'));
            }
        }
        else if (combo.itemId === 'cboOwnershipType'){
            switch (records[0].get('intOwnershipType')) {
                case 1:
                    current.set('dblAvailableQty', current.get('dblOriginalAvailableQty'));
                    break;
                case 2:
                    current.set('dblAvailableQty', current.get('dblOriginalStorageQty'));
                    break;
                default:
                    current.set('dblAvailableQty', current.get('dblOriginalAvailableQty'));
            }
        }
        else if (combo.itemId === 'cboToSubLocation') {
            current.set('intToSubLocationId', records[0].get('intCompanyLocationSubLocationId'));
            current.set('intToStorageLocationId', null);
            current.set('strToStorageLocationName', null);
        }
        else if (combo.itemId === 'cboToStorage') {
            current.set('intToStorageLocationId', records[0].get('intStorageLocationId'));
            current.set('intToSubLocationId', records[0].get('intSubLocationId'));
            current.set('strToSubLocationName', records[0].get('strSubLocationName'));
        }
        //else if (combo.itemId === 'cboUOM') {
        //    current.set('intItemUOMId', records[0].get('intItemUOMId'));
        //}
        else if (combo.itemId === 'cboWeightUOM') {
            current.set('intItemWeightUOMId', records[0].get('intItemUOMId'));
        }
        else if (combo.itemId === 'cboNewLotID') {
            current.set('intNewLotId', records[0].get('intLotId'));
        }
        else if (combo.itemId === 'cboTaxCode') {
            current.set('intTaxCodeId', records[0].get('intTaxCodeId'));
        }

        win.viewModel.data.currentDetailItem = current;
    },

    onDetailSelectionChange: function(selModel, selected, eOpts) {
        if (selModel) {
            var view = selModel.view;
            if (view == null) return;
            
            var win = view.grid.up('window');
            var vm = win.viewModel;

            if (selected.length > 0) {
                var current = selected[0];
                if (current.dummy) {
                    vm.data.currentDetailItem = null;
                }
                else {
                    vm.data.currentDetailItem = current
                }
            }
            else {
                vm.data.currentDetailItem = null;
            }
        }
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
                postURL             : '../Inventory/api/InventoryTransfer/PostTransaction',
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
                postURL: '../Inventory/api/InventoryTransfer/PostTransaction',
                strTransactionId: currentRecord.get('strTransferNo'),
                ysnPosted: currentRecord.get('ysnPosted'),
                scope: me,
                success: function(){
                    // If data is generated, show the recap screen.
                    var showPostButton = true;
                    if (currentRecord.get('intSourceType') === 3){
                        showPostButton = false;
                    }

                    CashManagement.common.BusinessRules.showRecap({
                        strTransactionId: currentRecord.get('strTransferNo'),
                        ysnPosted: currentRecord.get('ysnPosted'),
                        dtmDate: currentRecord.get('dtmTransferDate'),
                        strCurrencyId: null,
                        dblExchangeRate: 1,
                        scope: me,
                        showPostButton: showPostButton,
                        showUnpostButton: showPostButton,
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

    

    onItemHeaderClick: function(menu, column) {
        //var grid = column.initOwnerCt.grid;
        var grid = column.$initParent.grid;

        i21.ModuleMgr.Inventory.showScreenFromHeaderDrilldown('Inventory.view.Item', grid, 'intItemId');
    },

    onStorageHeaderClick: function(menu, column) {
        //var grid = column.initOwnerCt.grid;
        var grid = column.$initParent.grid;

        i21.ModuleMgr.Inventory.showScreenFromHeaderDrilldown('Inventory.view.StorageUnit', grid, 'intFromStorageLocationId');
    },

    onFromLocationDrilldown: function(combo) {
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

    onToLocationDrilldown: function(combo) {
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

    onViewTransaction: function (value, record) {
        var intSourceType = record.get('intSourceType');
        switch (intSourceType) {
            case 1:
                i21.ModuleMgr.Inventory.showScreen(value, 'Scale');
                break;
            case 2:
                i21.ModuleMgr.Inventory.showScreen(value, 'Inbound Shipment');
                break;
            case 3:
                i21.ModuleMgr.Inventory.showScreen(value, 'Transport');
                break;
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
            "#cboFromLocation": {
                drilldown: this.onFromLocationDrilldown
            },
            "#cboToLocation": {
                drilldown: this.onToLocationDrilldown
            },
            //"#cboUOM": {
            //    select: this.onTransferDetailSelect
            //},
            "#cboWeightUOM": {
                select: this.onTransferDetailSelect
            },
            "#cboNewLotID": {
                select: this.onTransferDetailSelect
            },
            "#cboTaxCode": {
                select: this.onTransferDetailSelect
            },
            "#cboOwnershipType": {
                select: this.onTransferDetailSelect
            },
            "#btnPost": {
                click: this.onPostClick
            },
            "#btnUnpost": {
                click: this.onPostClick
            },
            "#btnPostPreview": {
                click: this.onRecapClick
            },
            "#btnUnpostPreview": {
                click: this.onRecapClick
            },
            "#btnViewItem": {
                click: this.onViewItemClick
            },
            "#grdInventoryTransfer": {
                selectionchange: this.onDetailSelectionChange
            }
        });
    }
});
