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
                value: '{current.strFromLocation}',
                origValueField: 'intCompanyLocationId',
                origUpdateField: 'intFromLocationId',
                store: '{fromLocation}',
                readOnly: '{current.ysnPosted}'
            },
            cboToLocation: {
                value: '{current.strToLocation}',
                origValueField: 'intCompanyLocationId',
                origUpdateField: 'intToLocationId',
                store: '{toLocation}',
                readOnly: '{current.ysnPosted}'
            },
            chkShipmentRequired: {
                value: '{current.ysnShipmentRequired}',
                readOnly: '{current.ysnPosted}'
            },
            cboStatus: {
                value: '{current.strStatus}',
                origValueField: 'intStatusId',
                store: '{status}',
                readOnly: '{current.ysnPosted}'
            },
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
                            },
                            {
                                column: 'strType',
                                value: 'Comment',
                                conjunction: 'Or',
                                condition: 'eq'
                            }
                        ]
                    }
                },
                colDescription: 'strDescription',
                colFromSubLocation: {
                    dataIndex: 'strFromSubLocationName',    
                    editor: {
                        store: '{fromSubLocation}',
                        readOnly: '{readOnlyInventoryTransferField}',
                        defaultFilters: 
                        [
                            {
                                column: 'intItemId',
                                value: '{grdInventoryTransfer.selection.intItemId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'intLocationId',
                                value: '{current.intFromLocationId}',
                                conjunction: 'and'
                            },
                            // {
                            //     inner: [
                            //         {
                            //             column: 'dblOnHand',
                            //             value: '0',
                            //             conjunction: 'and',
                            //             condition: 'gt'
                            //         },
                            //         {
                            //             column: 'ysnStockUnit',
                            //             value: true,
                            //             conjunction: 'and',
                            //             condition: 'eq'
                            //         }
                            //     ],
                            //     conjunction: 'or'
                            // }
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
                colAvailableQty: {
                    dataIndex: 'dblAvailableQty'
                },
                colAvailableUOM: {
                    dataIndex: 'strAvailableUOM'
                },
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
                colTransferQty: {
                    editor: {
                        readOnly: '{readOnlyInventoryTransferField}'
                    },
                    dataIndex: 'dblQuantity'
                },
                colNewLotID: {
                    editor: {
                        readOnly: '{readOnlyInventoryTransferField}'
                    },
                    dataIndex: 'strNewLotId'
                },
                colNetUOM: {
                    dataIndex: 'strGrossNetUOM',
                    editor: {
                        store: '{weightUOM}',
                        readOnly: '{readOnlyInventoryTransferField}',                        
                        origUpdateField: 'intGrossNetUOMId',
                        origValueField: 'intItemUOMId',
                        defaultFilters: [
                            {
                                column: 'intItemId',
                                value: '{grdInventoryTransfer.selection.intItemId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'ysnAllowPurchase',
                                value: true,
                                conjunction: 'and'
                            }
                        ]
                    },
                },
                colCost: {
                    dataIndex: 'dblCost',
                    hidden: true,
                    editor: {
                        readOnly: true 
                    }                   
                },
                colGross: {
                    editor: {
                        readOnly: '{readOnlyInventoryTransferField}'
                    },
                    dataIndex: 'dblGross'
                },
                colNet: {
                    dataIndex: 'dblNet'
                },
                colTare: {
                    editor: {
                        readOnly: '{readOnlyInventoryTransferField}'
                    },
                    dataIndex: 'dblTare'
                },
                colWeightUOMId: {
                    editor: {
                        readOnly: '{readOnlyInventoryTransferField}'
                    },
                    dataIndex: 'intWeightUOMId'
                },
                colNewLotStatus: {
                    editor: {
                        readOnly: '{readOnlyInventoryTransferField}',
                        origUpdateField: 'intNewLotStatusId',
                        origValueField: 'intLotStatusId',
                        store: '{lotStatuses}',
 
                    },
                    dataIndex: 'strNewLotStatus'
                },
                colLotCondition: {
                    dataIndex: 'strLotCondition',
                    editor: {
                        store: '{condition}'
                    }
                },
                // chkDestinationWeights: {
                //     dataIndex: 'ysnWeights',
                //     disabled: '{destinationWeightsDisabled}'
                // }
            },
            pgePostPreview: {
                title: '{pgePreviewTitle}'
            }    
        }
    },

    mapGrossNet: function (current) {
        var gn = this.calculateGrossNet(current.get('dblQuantity'), current.get('dblItemUnitQty'), current.get('dblGrossNetUnitQty'), 0.00);
        current.set('dblGross', gn.gross);
    },

    calculateGrossNet: function (lotQty, itemUOMConversionFactor, weightUOMConversionFactor, tareWeight) {
        var grossQty = 0.00;
        var me = this;
        if (itemUOMConversionFactor === weightUOMConversionFactor) {
            grossQty = lotQty;
        }
        else if (weightUOMConversionFactor !== 0) {
            grossQty = me.convertQtyBetweenUOM(itemUOMConversionFactor, weightUOMConversionFactor, lotQty);
        }

        return {
            gross: grossQty,
            tare: tareWeight,
            net: grossQty - tareWeight
        };
    },

    convertQtyBetweenUOM: function (sourceUOMConversionFactor, targetUOMConversionFactor, qty) {
        var result = 0;

        if (sourceUOMConversionFactor === targetUOMConversionFactor) {
            result = qty;
        }
        else if (targetUOMConversionFactor !== 0) {
            result = (sourceUOMConversionFactor * qty) / targetUOMConversionFactor;
        }

        //return Math.round(result, 12);
        return ic.utils.Math.round(result, 12);
    },

    onTransferQtyChange: function (config, column) {
        var me = this;
        var current = column.record;
        if (column.field === 'dblQuantity') {
            me.mapGrossNet(current);
        }
    },

    setupContext : function(options){
        var me = this,
            win = me.getView(),
            store = Ext.create('Inventory.store.Transfer', { pageSize: 1 });

        var grdInventoryTransfer = win.down('#grdInventoryTransfer');

        win.context = Ext.create('iRely.Engine', {
            window : win,
            store  : store,
            enableActivity: true,
            createTransaction: Ext.bind(me.createTransaction, me),
            enableAudit: true,
            include: 'vyuICGetInventoryTransfer, tblICInventoryTransferDetails.vyuICGetInventoryTransferDetail, tblICInventoryTransferDetails.tblICItem, tblICInventoryTransferDetails.tblICLotStatus',
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

        var cepItem = grdInventoryTransfer.getPlugin('cepItem');
        if (cepItem) {
            cepItem.on({
                edit: me.onTransferQtyChange,
                scope: me
            });
        }

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

            var context = win.context ? win.context.initialize() : me.setupContext();

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
            record.set('strFromLocation', app.DefaultLocationName);
            record.set('intToLocationId', app.DefaultLocation);
            record.set('strToLocation', app.DefaultLocationName);
        }
        if (app.EntityId > 0)
            record.set('intTransferredById', app.EntityId);
        record.set('dtmTransferDate', today);
        record.set('intStatusId', 1);
        record.set('strStatus', 'Open');
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
        var me = this;
        
        if (combo.itemId === 'cboItem') {
            current.set('intItemId', records[0].get('intItemId'));
            current.set('strDescription', records[0].get('strDescription'));
            current.set('intItemUOMId', records[0].get('intStockUOMId'));
            current.set('dblAvailableQty', records[0].get('dblAvailable'));
            current.set('strAvailableUOM', records[0].get('strStockUOM'));
            current.set('dblOriginalAvailableQty', records[0].get('dblAvailable'));
            current.set('dblOriginalStorageQty', records[0].get('dblStorageQty'));
            current.set('strItemType', records[0].get('strType'));

        }
        else if (combo.itemId === 'cboLot') {
            current.set('intLotId', records[0].get('intLotId'));
            current.set('dblAvailableQty', records[0].get('dblQty'));
            current.set('strAvailableUOM', records[0].get('strItemUOM'));
            current.set('intItemUOMId', records[0].get('intItemUOMId'));

            current.set('dblOriginalAvailableQty', records[0].get('dblQty'));
            current.set('dblOriginalStorageQty', records[0].get('dblQty'));
            current.set('intNewLotStatusId', records[0].get('intLotStatusId'));
            current.set('dblItemUnitQty', records[0].get('dblItemUnitQty'));

            current.set('intFromSubLocationId', records[0].get('intSubLocationId'));
            current.set('intFromStorageLocationId', records[0].get('intStorageLocationId'));
            current.set('strFromSubLocationName', records[0].get('strSubLocationName'));
            current.set('strFromStorageLocationName', records[0].get('strStorageLocation'));

            var strNewLotStatus = 'Active';
            switch(records[0].get('intLotStatusId')) {
                case 1:
                    strNewLotStatus = 'Active';
                    break;
                case 2:
                    strNewLotStatus = 'On Hold';
                    break;
                case 3:
                    strNewLotStatus = 'Quarantine';
                    break;
                case 4:
                    strNewLotStatus = 'Pre-Sanitized';
                    break;
            }
            current.set('strNewLotStatus', strNewLotStatus);
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
        } else if (combo.itemId === 'cboNetUOM') {
            current.set('dblGrossNetUnitQty', records[0].get('dblUnitQty'));
            me.mapGrossNet(current);
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

    onPostClick: function(btnPost, e, eOpts) {
        if (btnPost){
            btnPost.disable();
        }
        else {
            return;
        }

        var me = this;
        var win = btnPost.up('window');
        var context = win ? win.context : null;
        var current = context ? win.viewModel.data.current : null;

        if (!current){
            btnPost.enable();
            return;
        }        

        var tabInventoryTransfer = win.down('#tabInventoryTransfer');
        var activeTab = tabInventoryTransfer ? tabInventoryTransfer.getActiveTab() : null;        

        var doPost = function (){
            ic.utils.ajax({
                url: './Inventory/api/InventoryTransfer/PostTransaction',
                params:{
                    strTransactionId: current.get('strTransferNo'),
                    isPost: current.get('ysnPosted') ? false : true,
                    isRecap: false
                },
                method: 'post'
            })
            .subscribe(
                function(successResponse) {
                    win.context.data.load();
                    // Check what is the active tab. If it is the Post Preview tab, load the recap data. 
                    if (activeTab && activeTab.itemId == 'pgePostPreview') {
                        var cfg = {
                            isAfterPostCall: true,
                            ysnPosted: current.get('ysnPosted') ? true : false
                        };
                        me.doPostPreview(win, cfg);
                    }
                    btnPost.enable();
                    iRely.Functions.refreshFloatingSearch('Inventory.view.InventoryTransfer');
                }
                ,function(failureResponse) {
                    var responseText = Ext.decode(failureResponse.responseText);
                    var message = responseText ? responseText.message : {}; 
                    var statusText = message ? message.statusText : 'Oh no! Something went wrong while posting the transfer.';

                    iRely.Functions.showCustomDialog(iRely.Functions.dialogType.ERROR, iRely.Functions.dialogButtonType.OK, statusText);
                    btnPost.enable();
                }
            )
        };  

        // me.validateTransfer(win, current, function() {
        //     // Save any unsaved data first before doing the post. 
        //     if (context.data.hasChanges()) {
        //         context.data.validator.validateRecord({ window: win }, function(valid) {
        //             // If records are valid, continue with the save. 
        //             if (valid){
        //                 context.data.saveRecord({
        //                     successFn: function () {
        //                         doPost();             
        //                     }
        //                 });
        //             }
        //             // If records are invalid, re-enable the post button. 
        //             else {
        //                 btnPost.enable();
        //             }
        //         });            
        //     }
        //     else {
        //         doPost();
        //     }    
        // });       


        // Save any unsaved data first before doing the post. 
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
                    btnPost.enable();
                }
            });            
        }
        else {
            doPost();
        }    
    },

    // validateTransfer: function(win, current, action) {
    //     if(current) {
    //         var hasWarnings = false;

    //         var rx = Rx.Observable.from(current.tblICInventoryTransferDetails().data.items)
    //             .filter(function(x) { return !x.dummy && (x.get('intLotId') !== null || x.get('intLotId') !== 0) && x.get('intToStorageLocationId') === null})
    //             .subscribe(function(x) {
    //                 hasWarnings = true;
    //             });
            
    //         if(hasWarnings) {
    //             iRely.Functions.showCustomDialog('Warning', 'ok', "Warning: There are lotted items that don't have 'To Storage Location' specified. It might cause an issue during production consumption period.", function(button) {
    //                 action();
    //             });
    //         }
    //     }
    // },

    doPostPreview: function (win, cfg) {
        var me = this;

        if (!win) { return; }
        cfg = cfg ? cfg : {};

        var isAfterPostCall = cfg.isAfterPostCall;
        var ysnPosted = cfg.ysnPosted;

        var context = win.context;
        var current = win.viewModel.data.current;
        var grdInventoryTransfer = win.down('#grdInventoryTransfer');

        //Deselect all rows in Item Grid
        if (grdInventoryTransfer) { grdInventoryTransfer.getSelectionModel().deselectAll(); }

        var doRecap = function () {
            ic.utils.ajax({
                url: './Inventory/api/InventoryTransfer/PostTransaction',
                params: {
                    strTransactionId: current.get('strTransferNo'),
                    isPost: isAfterPostCall ? ysnPosted : current.get('ysnPosted') ? false : true,
                    isRecap: true
                },
                method: 'post'
            })
            .subscribe(
                function (successResponse) {
                    var postResult = Ext.decode(successResponse.responseText);
                    var batchId = postResult.data.strBatchId;
                    if (batchId) {
                        me.bindRecapGrid(batchId);
                    }
                }
                , function (failureResponse) {
                    // Show Post Preview failed.
                    var jsonData = Ext.decode(failureResponse.responseText);
                    iRely.Functions.showErrorDialog(jsonData.message.statusText);
                }
            )
        };

        // me.validateTransfer(win, current, function() {
        //     // Save any unsaved data first before doing the post. 
        //     if (context.data.hasChanges()) {
        //         context.data.validator.validateRecord({ window: win }, function(valid) {
        //             // If records are valid, continue with the save. 
        //             if (valid){
        //                 context.data.saveRecord({
        //                     successFn: function () {
        //                         doRecap();             
        //                     }
        //                 });
        //             }
        //         });            
        //     }
        //     else {
        //         doRecap();
        //     } 
        // });   
        
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

    onTransferTabChange: function (tabPanel, newCard, oldCard, eOpts) {
        var me = this;
        var win = tabPanel.up('window');
        var context = win.context;
        var current = win.viewModel.data.current;

        switch (newCard.itemId) {
            case 'pgePostPreview':
                me.doPostPreview(win);
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

    onPrintClick: function(btnPrint, e, eOpts) {
        var win = btnPrint.up('window');
        
        // Save has data changes first before doing the post.
        win.context.data.saveRecord({
            callbackFn: function() {
                var vm = win.viewModel;
                var current = vm.data.current;

                var filters = [{
                    Name: 'strTransferNo',
                    Type: 'string',
                    Condition: 'EQUAL TO',
                    From: current.get('strTransferNo'),
                    Operator: 'AND'
                }];

                iRely.Functions.openScreen('Reporting.view.ReportViewer', {
                    selectedReport: 'TransferOrderReport',
                    selectedGroup: 'Inventory',
                    selectedParameters: filters,
                    viewConfig: { maximized: true }
                });
            }
        });
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
            "#cboNetUOM": {
                select: this.onTransferDetailSelect
            },
            "#btnPost": {
                click: this.onPostClick
            },
            "#btnUnpost": {
                click: this.onPostClick
            },
            "#btnPrint": {
                click: this.onPrintClick
            },
            "#btnViewItem": {
                click: this.onViewItemClick
            },
            "#grdInventoryTransfer": {
                selectionchange: this.onDetailSelectionChange
            },
            "#tabInventoryTransfer": {
                tabChange: this.onTransferTabChange
            }             
        });
    }
});
