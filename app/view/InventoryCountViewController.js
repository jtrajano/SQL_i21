Ext.define('Inventory.view.InventoryCountViewController', {
    extend: 'Inventory.view.InventoryBaseViewController',
    alias: 'controller.icinventorycount',
    alternateClassName: 'ic.count',
    requires: [
        'CashManagement.common.Text',
        'CashManagement.common.BusinessRules'
    ],

    config: {
        binding: {
            bind: {
                title: 'Inventory Count - {current.strCountNo}'
            },
            cboPageSize: {
                hidden: true,
                value: '{pageSize}',
                store: '{pageSize}'
            },
            btnShowRow: {
                hidden: '{hasSelection}',
                hidden: true
            },
            btnDelete: {
                disabled: '{disableBtnDelete}'
            },
            btnSave: {
                disabled: '{current.ysnPosted}'
            },
            btnAttachNewRow: {
                hidden: '{hidePostButton}'
            },
            btnDetachSelectedRows: {
                hidden: '{hidePostButton}'
            },
            btnDetachAll: {
                hidden: '{hidePostButton}'
            },
            btnUndo: {
                disabled: '{current.ysnPosted}'
            },
            btnPrintCountSheets: {
                hidden: '{checkPrintCountSheet}'
            },
            btnPrintVariance: {
                hidden: '{checkPrintVariance}'
            },
            btnLockInventory: {
                hidden: '{checkLockInventory}',
                text: '{getLockInventoryText}'
            },
            btnPost: {
                hidden: '{hidePostButton}'
            },
            btnUnpost: {
                hidden: '{hideUnpostButton}'
            },
            btnPostPreview: {
                hidden: true
            },
            btnUnpostPreview: {
                hidden: true
            },
            btnRecount: {
                hidden: '{checkRecount}',
                hidden: '{hasCountGroup}',
            },
            cboLocation: {
                value: '{current.strLocation}',
                origValueField: 'intCompanyLocationId',
                origUpdateField: 'intLocationId',
                store: '{location}'
            },
            cboCategory: {
                value: '{current.strCategory}',
                origValueField: 'intCategoryId',
                store: '{category}',
                hidden: '{hasCountGroup}'
            },
            cboCommodity: {
                value: '{current.strCommodity}',
                origValueField: 'intCommodityId',
                store: '{commodity}',
                hidden: '{hasCountGroup}'
            },
            cboCountGroup: {
                value: '{current.strCountGroup}',
                origValueField: 'intCountGroupId',
                store: '{countGroup}',
                hidden: '{hasCountGroup}'
            },
            dtpCountDate: '{current.dtmCountDate}',
            txtCountNumber: '{current.strCountNo}',
            txtShiftCountNo: {
                value: '{current.strShiftNo}',
                hidden: '{!hasCountGroup}'
            },
            cboSubLocation: {
                value: '{current.strSubLocation}',
                origValueField: 'intCompanyLocationSubLocationId',
                origUpdateField: 'intSubLocationId',
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
                ],
                hidden: '{hasCountGroup}'
            },
            cboStorageLocation: {
                value: '{current.strStorageLocation}',
                origValueField: 'intStorageLocationId',
                store: '{storageLocation}',
                hidden: '{hasCountGroup}',
                defaultFilters: [
                    {
                        column: 'intLocationId',
                        value: '{current.intLocationId}',
                        conjunction: 'and'
                    },
                    {
                        column: 'intSubLocationId',
                        value: '{current.intSubLocationId}',
                        conjunction: 'and'
                    }
                ]
            },
            txtDescription: '{current.strDescription}',

            chkIncludeZeroOnHand: {
                value: '{current.ysnIncludeZeroOnHand}',
                hidden: '{hasCountGroup}'
            },
            chkIncludeOnHand: {
                value: '{current.ysnIncludeOnHand}',
                hidden: '{hasCountGroup}'
            },
            chkScannedCountEntry: {
                value: '{current.ysnScannedCountEntry}',
                hidden: '{hasCountGroup}'
            },
            cboCountBy: {
                store: '{countBy}',
                value: '{countByGroup}',
                disabled: '{current.ysnPosted}'
            },

            chkCountByLots: {
                value: '{current.ysnCountByLots}',
                hidden: '{hasCountGroup}',
                disabled: '{current.ysnPosted}'
            },
            chkCountByPallets: {
                value: '{current.ysnCountByPallets}',
                hidden: '{hasCountGroup}'
            },
            chkRecountMismatch: {
                value: '{current.ysnRecountMismatch}',
                hidden: '{hasCountGroup}'
            },
            chkExternal: {
                value: '{current.ysnExternal}',
                hidden: '{hasCountGroup}'
            },
            chkRecount: {
                value: '{current.ysnRecount}',
                hidden: '{hasCountGroup}'
            },
            cnt4: {
                hidden: '{hasCountGroup}'
            },
            cnt3: {
                hidden: '{hasCountGroup}'
            },
            txtReferenceCountNo: '{current.intRecountReferenceId}',
            cboStatus: {
                value: '{current.intStatus}',
                store: '{status}'
            },
            btnRemove: {
                hidden: '{current.ysnPosted}'
            },
            btnInsert:  {
                hidden: '{current.ysnPosted}'
            },
            btnFetchDetails: {
                text: '{getFetchText}',
                iconCls: '{getFetchIconCls}',
                disabled: '{checkPrintCountSheet}',
                hidden: '{current.ysnPosted}'      
            },
            grdPhysicalCount: {
                readOnly: '{current.ysnPosted}',
                colItem: {
                    dataIndex: 'strItemNo',
                    editor: {
                        store: '{itemStock}',
                        readOnly: true,
                        origValueField: 'intItemId',
                        origUpdateField: 'intItemId',
                        defaultFilters: [
                            {
                                column: 'intLocationId',
                                value: '{current.intLocationId}',
                                conjunction: 'and'
                            }
                        ]
                    },
                    hidden: true
                },
                colStockUOM: 'strUnitMeasure',
                colDescription: {
                    dataIndex: 'strItemDescription',
                    drillDownText: 'View Item',
                    drillDownClick: 'onViewItemDescription',
                    hidden: '{hasCountGroup}'
                },
                colCountGroup: {
                    dataIndex: 'strCountGroup',
                    editor: {
                        store: '{countGroup}',
                        origValueField: 'intCountGroupId',
                        origUpdateField: 'intCountGroupId'
                    },
                    hidden: '{!hasCountGroup}'
                },
                colCategory: {
                    hidden: '{hasCountGroup}',
                    dataIndex: 'strCategory',
                    drillDownText: 'View Category',
                    drillDownClick: 'onViewCategory'
                },
                colTextItemNo: 'strItemNo',
                colTextSubLocation: {
                    dataIndex: 'strSubLocationName',
                    hidden: '{isCountByGroupOrNotLotted}'
                },
                colTextStorageLocation: {
                    dataIndex: 'strStorageLocationName',
                    hidden: '{isCountByGroupOrNotLotted}'
                },
                colTextLotId: {
                    dataIndex: 'strLotNo',
                    hidden: '{isCountByGroupOrNotLotted}'
                },
                colParentLotId: {
                    dataIndex: 'strParentLotNo',
                    hidden: '{isCountByGroupOrNotLotted}'
                },
                colSubLocation: {
                    hidden: true,
                    dataIndex: 'strSubLocationName',
                    editor: {
                        // readOnly: '{disableCountGridFields}',
                        readOnly: true,
                        store: '{fromSubLocation}',
                        origValueField: 'intSubLocationId',
                        origUpdateField: 'intSubLocationId',
                        defaultFilters: [
                            {
                                column: 'intItemId',
                                value: '{grdPhysicalCount.selection.intItemId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'intLocationId',
                                value: '{current.intLocationId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'strClassification',
                                value: 'Inventory',
                                conjunction: 'and'
                            },
                           /* {
                                column: 'ysnStockUnit',
                                value: true,
                                conjunction: 'and',
                                condition: 'eq'
                            }*/
                        ]
                    }
                },
                colStorageLocation: {
                    hidden: true,
                    dataIndex: 'strStorageLocationName',
                    editor: {
                        // readOnly: '{disableCountGridFields}',
                        readOnly: true,
                        store: '{fromStorageLocation}',
                        origValueField: 'intStorageLocationId',
                        origUpdateField: 'intStorageLocationId',
                        defaultFilters: [
                            {
                                column: 'intItemId',
                                value: '{grdPhysicalCount.selection.intItemId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'intLocationId',
                                value: '{current.intFromLocationId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'intSubLocationId',
                                value: '{grdPhysicalCount.selection.intSubLocationId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'dblOnHand',
                                value: '0',
                                conjunction: 'and',
                                condition: 'gt'
                            }
                        ]
                    }
                },
                colLotNo: {
                    hidden: true,
                    dataIndex: 'strLotNo',
                    // hidden: '{!current.ysnCountByLots}',
                    hidden: true,
                    editor: {
                        // readOnly: '{disableCountGridFields}',
                        readOnly: true,
                        store: '{lot}',
                        forceSelection: '{forceSelection}',
                        origValueField: 'intLotId',
                        origUpdateField: 'intLotId',
                        defaultFilters: [
                            {
                                column: 'intItemId',
                                value: '{grdPhysicalCount.selection.intItemId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'intLocationId',
                                value: '{current.intLocationId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'intSubLocationId',
                                value: '{grdPhysicalCount.selection.intSubLocationId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'intStorageLocationId',
                                value: '{grdPhysicalCount.selection.intStorageLocationId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colLotAlias: {
                    dataIndex: 'strLotAlias',
                    hidden: '{isCountByGroupOrNotLotted}'
                },
                colSystemCount: 'dblSystemCount',
                colQtyReceived: {
                    dataIndex: 'dblQtyReceived',
                    hidden: '{!hasCountGroup}'
                },
                colQtySold: {
                    dataIndex: 'dblQtySold',
                    hidden: '{!hasCountGroup}'
                },
                colLastCost: {
                    dataIndex: 'dblLastCost',
                    hidden: '{hasCountGroup}'
                },
                colCountLineNo: {
                    dataIndex: 'strCountLine',
                },
                colNoPallets: {
                    dataIndex: 'dblPallets',
                    hidden: '{hidePalletFields}',
                    editor: {
                        readOnly: '{disableCountGridFields}',
                    }
                },
                colQtyPerPallet: {
                    dataIndex: 'dblQtyPerPallet',
                    hidden: '{hidePalletFields}',
                    editor: {
                        readOnly: '{disableCountGridFields}',
                    }
                },
                colPhysicalCount: {
                    dataIndex: 'dblPhysicalCount',
                    editor: {
                        readOnly: '{disableCountGridFields}',
                        readOnly: '{disablePhysicalCount}'
                    }
                },
                colUOM: {
                    dataIndex: 'strUnitMeasure',
                    hidden: '{hasCountGroup}',
                    editor: {
                        readOnly: '{disableCountUOM}',
                        origValueField: 'intItemUOMId',
                        origUpdateField: 'intItemUOMId',
                        store: '{itemUOM}',
                        defaultFilters: [
                            {
                                column: 'intItemId',
                                value: '{grdPhysicalCount.selection.intItemId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'intLocationId',
                                value: '{current.intLocationId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'dblOnHand',
                                value: 0,
                                conjunction: 'and',
                                condition: 'noteq'
                            }
                        ]
                    }
                },
                colWeightQty: {
                    dataIndex: 'dblWeightQty',
                    hidden: '{!current.ysnCountByLots}',
                    editor: {
                        readOnly: '{disableCountGridFields}'
                    }
                },
                colNetWeightQty: {
                    dataIndex: 'dblNetQty',
                    hidden: '{!current.ysnCountByLots}'
                },
                colWeightUOM: {
                    dataIndex: 'strWeightUOM',
                    hidden: '{!current.ysnCountByLots}',
                    editor: {
                        readOnly: '{disableCountGridFields}',
                        origValueField: 'intItemUOMId',
                        origUpdateField: 'intWeightUOMId',
                        store: '{itemUOM}',
                        defaultFilters: [
                            {
                                column: 'intItemId',
                                value: '{grdPhysicalCount.selection.intItemId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'intLocationId',
                                value: '{current.intLocationId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'strUnitType',
                                value: 'Weight',
                                conjunction: 'and'
                            }
                        ]
                    }    
                },
                colPhysicalCountStockUnit: {
                    dataIndex: 'dblPhysicalCountStockUnit',
                    hidden: '{hasCountGroup}'
                },
                colVariance: 'dblVariance',
                colRecount: {
                    dataIndex: 'ysnRecount',
                    disabled: '{disableCountGridFields}',
                    hidden: '{hasCountGroup}'
                },
                colEnteredBy: 'strUserName'
            },
            pgePostPreview: {
                title: '{pgePreviewTitle}'
            }
        }
    },

    setupContext: function (options) {
        var me = this,
            win = me.getView(),
            store = Ext.create('Inventory.store.InventoryCount', { pageSize: 1 }),
            grdPhysicalCount = win.down('#grdPhysicalCount');

        win.context = Ext.create('iRely.Engine', {
            window: win,
            store: store,
            enableActivity: true,
            enableScreenOptimization: false,
            onPageChange: me.onPageChange,
            enableAttachment: true,
            attachment: Ext.create('iRely.attachment.Manager', {
                type: 'Inventory.InventoryCount',
                window: win
            }),
            createTransaction: Ext.bind(me.createTransaction, me),
            include: 'vyuICGetInventoryCount,tblICInventoryCountDetails',
            onSaveClick: me.saveAndPokeGrid(win, grdPhysicalCount),
            createRecord: me.createRecord,
            binding: me.config.binding,
            // details: [
            //     {
            //         key: 'tblICInventoryCountDetails',
            //         component: Ext.create('iRely.grid.Manager', {
            //             grid: grdPhysicalCount,
            //             deleteButton: win.down('#btnRemove'),
            //             createRecord: me.createLineItemRecord
            //         })
            //     }
            // ]
        });


        // var gmgr = Ext.create('iRely.grid.Manager', {
        //     grid: grdPhysicalCount,
        //     deleteButton: win.down('#btnRemoveDetail'),

        // });

        var btnExportGridData = win.down("#btnExportGridData");
        if(btnExportGridData)
            btnExportGridData.setText("Export");

        me.attachOnEditListener(win, grdPhysicalCount);

        var cepCount = grdPhysicalCount.getPlugin('cepPhysicalCount');
        if (cepCount) {
            cepCount.on({
                edit: me.onPhysicalCountChange,
                scope: me
            });
        }

        return win.context;
    },

    createTransaction: function(config, action) {
        var me = this,
            current = me.getViewModel().get('current');

        action({
            strTransactionNo: current.get('strCountNo'), //Unique field
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
                            column: 'intInventoryCountId',
                            value: config.id
                        }
                    ];
                }
                context.data.load({
                    filters: config.filters,
                    callback: function(records, opts, success) {
                        //ic.count.loadDetails(me, win, context, false);
                    }
                });
            }
        }
    },

    createRecord: function (config, action) {
        var today = new Date();
        var newRecord = Ext.create('Inventory.model.InventoryCount');
        var defaultLocation = iRely.config.Security.CurrentDefaultLocation; 

        newRecord.set('dtmCountDate', today);
        newRecord.set('intStatus', 1);

        if (defaultLocation){
            newRecord.set('intLocationId', defaultLocation);
            Ext.create('i21.store.CompanyLocationBuffered', {
                storeId: 'icReceiptCompanyLocation',
                autoLoad: {
                    filters: [
                        {
                            dataIndex: 'intCompanyLocationId',
                            value: defaultLocation,
                            condition: 'eq'
                        }
                    ],
                    params: {
                        columns: 'strLocationName:intCompanyLocationId:'
                    },
                    callback: function(records, operation, success){
                        var record; 
                        if (records && records.length > 0) {
                            record = records[0];
                        }

                        if(success && record){
                            newRecord.set('strLocation', record.get('strLocationName'));
                            newRecord.set('intLocationId', record.get('intCompanyLocationId'));
                        }
                    }
                }
            });            
        }         

        action(newRecord);
    },

    getTotalLocationStockOnHand: function (intLocationId, intItemId, intSubLocationId, intStorageLocationId, intLotId, intItemUOMId, callback) {
        Inventory.Utils.ajax({
            timeout: 120000,
            url: './inventory/api/itemstock/getlocationstockonhand',
            params: {
                intLocationId: intLocationId,
                intItemId: intItemId,
                intSubLocationId: intSubLocationId,
                intStorageLocationId: intStorageLocationId,
                intLotId: intLotId,
                intItemUOMId: intItemUOMId
            }
        })
            .subscribe(
            function (response) {
                var jsonData = Ext.decode(response.responseText);
                if (jsonData.success) {
                    if (jsonData.data.length > 0)
                        callback(jsonData.data[0].dblOnHand);
                    else
                        callback(0);
                } else
                    callback(0);
            },
            function (error) {
                var jsonData = Ext.decode(error.responseText);
                callback(jsonData.ExceptionMessage, true);
            }
            );
    },

    createLineItemRecord: function (config, action) {
        var record = Ext.create('Inventory.model.InventoryCountDetail');
        var strCountLine = '';

        record.set('strCountLine', strCountLine);
        record.set('intEntityUserSecurityId', iRely.config.Security.EntityId);
        record.set('strUserName', iRely.config.Security.UserName);
        if(!iRely.Functions.isEmpty(record.get('strItemNo'))) {
            config.createRecord.$owner.prototype.getTotalLocationStockOnHand(
                config.dummy.intInventoryCount.data.intLocationId,
                config.dummy.data.intItemId,
                config.dummy.data.intSubLocationId,
                config.dummy.data.intStorageLocationId,
                config.dummy.data.intLotId,
                config.dummy.data.intItemUOMId,
                function (val, err) {
                    if (err) {
                        iRely.Functions.showErrorDialog(val);
                    } else {
                        record.set('dblSystemCount', val);
                    }
                });
        }
        action(record);
    },

    onCountGroupSelect: function (combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) {
            current.set('ysnIncludeOnHand', records[0].get('ysnIncludeOnHand'));
            current.set('ysnScannedCountEntry', records[0].get('ysnScannedCountEntry'));
            current.set('ysnCountByLots', records[0].get('ysnCountByLots'));
            current.set('ysnCountByPallets', records[0].get('ysnCountByPallets'));
            current.set('ysnRecountMismatch', records[0].get('ysnRecountMismatch'));
            current.set('ysnExternal', records[0].get('ysnExternal'));
        }
    },
    statics: {
        getFilter: function(current, filterKey) {
            var filter = [];
            if(!current) 
                return filter;
            
            if(filterKey) {
                filter.push({
                    column: 'intInventoryCountId',
                    value: current.get('intInventoryCountId'),
                    conjunction: 'and'
                });
            }
            
            if (!iRely.Functions.isEmpty(current.get('intLocationId'))) {
                filter.push({
                    column: 'intLocationId',
                    value: current.get('intLocationId'),
                    conjunction: 'and'
                });
            }
            
            if (!iRely.Functions.isEmpty(current.get('intCategoryId'))) {
                filter.push({
                    column: 'intCategoryId',
                    value: current.get('intCategoryId'),
                    conjunction: 'and'
                });
            }
            
            if (!iRely.Functions.isEmpty(current.get('intCommodityId'))) {
                filter.push({
                    column: 'intCommodityId',
                    value: current.get('intCommodityId'),
                    conjunction: 'and'
                });
            }
            
            if (!iRely.Functions.isEmpty(current.get('intCountGroupId'))) {
                filter.push({
                    column: 'intCountGroupId',
                    value: current.get('intCountGroupId'),
                    conjunction: 'and'
                });
            }
            
            if (!iRely.Functions.isEmpty(current.get('intSubLocationId'))) {
                filter.push({
                    column: 'intSubLocationId',
                    value: current.get('intSubLocationId'),
                    conjunction: 'and'
                });
            }
            
            if (!iRely.Functions.isEmpty(current.get('intStorageLocationId'))) {
                filter.push({
                    column: 'intStorageLocationId',
                    value: current.get('intStorageLocationId'),
                    conjunction: 'and'
                });
            }
            
            if(current.get('ysnIncludeZeroOnHand') === false){
                    filter.push({
                    column: 'dblOnHand',
                    value: 0,
                    condition: 'gt',
                    conjunction: 'and'
                });
            }

            return filter;
        },

        loadDetails: function(me, win, context, showProgress, filters) {
            if(showProgress)
                win.setLoading('Loading Items...');
            var current = win.viewModel.data.current;
            var store = Ext.create('Inventory.store.BufferedInventoryCountDetail');
            var grdPhysicalCount = win.down("#grdPhysicalCount");

            var pagingtoolbar = win.down("#pgtCount");
            var defaultFilter = ic.count.getFilter(current, true);
            var filter = []; //defaultFilter;
            if(filters)
                filter = filters;

            store.proxy.extraParams = { filter: iRely.Functions.encodeFilters(filter) };
            grdPhysicalCount.setStore(store);
            grdPhysicalCount.down("#tlbGridOptions").hide();
            win.down("#gridfilter").hide();
            var defaultFilterText = win.down("#txtFilterGrid");
            if(defaultFilterText)
                defaultFilterText.hide();
            
            var tlbSearchFilter = win.down("#tlbSearchFilter");
            var btnSearchFilter = tlbSearchFilter.down("#btnSearchFilter");
            var mnuSearchFilter = btnSearchFilter.down("#mnuSearchFilter");
            if(mnuSearchFilter.items.length === 0) {
                Ext.each(grdPhysicalCount.columns, function(column){
                    mnuSearchFilter.add({
                        xtype: 'menucheckitem',
                        text: column.text,
                        itemId: column.name,
                        dataIndex: column.dataIndex,
                        checked: true
                    });
                });
            }
            pagingtoolbar.setStore(store);
            
            store.load({
                filters: filter,
                params: {
                    start: 0,
                    limit: win.viewModel.data.pageSize
                },
                callback: function(records, opts, success) {
                    win.setLoading(false);
                }
            });

            
        }
    },

    onSearchFilter: function(f, e) {
        if(e.getKey() == e.ENTER){
            var me = this;
            var win = f.up('window');
            var grdPhysicalCount = win.down("#grdPhysicalCount");
            var tlbSearchFilter = win.down("#tlbSearchFilter");
            var btnSearchFilter = tlbSearchFilter.down("#btnSearchFilter");
            var mnuSearchFilter = btnSearchFilter.down("#mnuSearchFilter");

            var filters = [];
            var cols = _.filter(mnuSearchFilter.items.items, function(c) { return c.dataIndex !== '' && c.checked; });
            if(!cols || cols.length <= 0)
                return null;

            var filterCol = "";
            _.each(cols, function(c) { filterCol += c.dataIndex + "|^|"; });

            var filter = {
                column: filterCol,
                value: f.value,
                condition: 'ct',
                conjunction: 'or'
            };
            if(f.value !== "")
                filters.push(filter);
            var parentFilter = {
                column: 'intInventoryCountId',
                value: win.getViewModel().get('current.intInventoryCountId'),
                condition: 'eq',
                conjunction: 'and'
            };
            filters.push(parentFilter);
            //filters = filters.concat(ic.count.getFilter(win.viewModel.data.current));
            ic.count.loadDetails(me, win, win.context, true, filters);    
        }
    },

    onPageChange: function(pagingStatusBar, record, eOpts) {
        var me = this;
        var win = pagingStatusBar.up('window');
        var current = win.viewModel.data.current;
        var store = Ext.create('Inventory.store.BufferedInventoryCountDetail');
        var grdPhysicalCount = win.down("#grdPhysicalCount");
        var pagingtoolbar = win.down("#pgtCount");
        
        if (!current.phantom) {
            var filter = {
                column: 'intInventoryCountId',
                value: win.getViewModel().get('current.intInventoryCountId'),
                condition: 'eq',
                conjunction: 'and'
            };
            ic.count.loadDetails(me, win, win.context, true, [filter]);
        } else {
            grdPhysicalCount.store.data.clear();
        }
    },

    calculateGrossNet: function (lotQty, itemUOMConversionFactor, weightUOMConversionFactor, tareWeight) {
        var grossQty = 0.00;
        var me = this;
        if (itemUOMConversionFactor === weightUOMConversionFactor) {
            grossQty = lotQty;
        }
        else if (weightUOMConversionFactor !== 0) {
            grossQty = Inventory.Utils.Uom.convertQtyBetweenUOM(itemUOMConversionFactor, weightUOMConversionFactor, lotQty);
        }

        return {
            gross: grossQty,
            tare: tareWeight,
            net: grossQty - tareWeight
        };
    },

    attachOnEditListener: function(win, grdPhysicalCount) {
        var me = this;
        var plugin = grdPhysicalCount.getPlugin('cepPhysicalCount');
        plugin.on({
            edit: function(editor, context, eOpts) {
                grdPhysicalCount.store.sync();
            }
        });

        var component = Ext.create('iRely.grid.Manager', {
            grid: grdPhysicalCount,
            allowNewRow: true,
            createRecord: me.createLineItemRecord
        });
    },

    onDetachSelectedRows: function(e) {
        var msgAction = function (button) {
            if (button === 'yes') {
                var me = this;
                var win = e.up('window');
                var grid = win.down('#grdPhysicalCount');
                var store = grid.store;
                var selection = grid.getSelectionModel().getSelection();
                var extraParams = store.proxy.extraParams;
                store.proxy.extraParams = null;
                store.remove(selection);
                store.sync({
                    callback: function() {
                        store.proxy.extraParams = extraParams;
                        store.load();
                    }
                });
            }
        };
        iRely.Functions.showCustomDialog('question', 'yesno', 'Are you sure you want to delete the selected record(s)?', msgAction);
    },

    onDetachAll: function (e) {
        var msgAction = function (button) {
            if (button === 'yes') {
                var me = this;
                var win = e.up('window');
                var vm = win.getViewModel();
                var current = vm.get('current');
                var id = current.get('intInventoryCountId');
                win.down("#grdPhysicalCount").setLoading("Deleting records...");
                Inventory.Utils.ajax({
                    url: './inventory/api/inventorycount/deletealldetails',
                    method: 'DELETE',
                    params: {
                        intInventoryCountId: id
                    }
                }).subscribe(function (response) {
                    win.down("#grdPhysicalCount").setLoading(false);
                    var filter = [{
                        column: 'intInventoryCountId',
                        value: id,
                        condition: 'eq'
                    }];
                    ic.count.loadDetails(me, win, win.context, true, filter);
                });
            }
        };
        iRely.Functions.showCustomDialog('question', 'yesno', 'Are you sure you want to delete all record(s)?', msgAction);
    },

    onShowRow: function (e) {
        var me = this;
        var win = e.up('window');
        var vm = win.getViewModel();
        var grid = win.down('grid');
        var store = grid.store;

        iRely.Functions.openScreen('Inventory.view.InventoryCountDetails', {
            id: grid.selection.get('intInventoryCountDetailId'),
            viewConfig: {
                listeners: {
                    close: function (count) {
                        var filter = {
                            column: 'intInventoryCountId',
                            value: count.viewModel.data.inventoryCount.data.intInventoryCountId,
                            condition: 'eq',
                            conjunction: 'and'
                        };
                        ic.count.loadDetails(me, win, win.context, true, [filter]);
                    }
                }
            },
            action: 'edit',
            current: vm.get('current')
        });
    },

    onAttachNewRow: function(e) {
        var me = this;
        var win = e.up('window');
        var vm = win.getViewModel();
        var grid = win.down('grid');
        var store = grid.store;

        win.context.data.saveRecord({
            callbackFn: function (batch, eOpts, success) {
                me.createLineItemRecord(win.getViewModel().getView().context.configuration, function(record) {
                    iRely.Functions.openScreen('Inventory.view.InventoryCountDetails', { 
                        viewConfig: {
                            listeners: {
                                close: function(count) {
                                    var filter = {
                                        column: 'intInventoryCountId',
                                        value: count.viewModel.data.inventoryCount.data.intInventoryCountId,
                                        condition: 'eq',
                                        conjunction: 'and'
                                    };
                                    ic.count.loadDetails(me, win, win.context, true, [filter]);
                                    // store.proxy.extraParams = { filter: iRely.Functions.encodeFilters([filter]) }

                                    // store.load({
                                    //     filters: filter,
                                    //     params: {
                                    //         start: 0,
                                    //         limit: win.viewModel.data.pageSize
                                    //     },
                                    //     callback: function(records, opts, success) {
                                    //         win.setLoading(false);
                                    //     }
                                    // });
                                }
                            }
                        },
                        action: 'new',
                        current: vm.get('current') 
                    });
                });
            }
        });
    },

    onRecountCheckChange: function(column, index, value, record) {
        var store = record.store;
        store.sync();
    },

    onCountBySelect: function(field, record) {
        var win = field.up('window');
        var vm = win.getViewModel();
        var current = vm.get('current');
        var grid = win.down("grid");
        var store = grid.getStore();
        if(record.get('strName') === 'Pack') {
            var records = store.getRange(0, store.getTotalCount());
            _.each(records, function(r) {
                r.set('strCountGroup', null);
                r.set('intCountGroupId', -1);
                r.set('intLotId', -1);
                r.set('intItemUOMId', -1);
                r.set('strItemNo', null);
                r.set('intItemId', -1);
                r.set('strLotAlias', null);
                r.set('strLotNumber', null);
                r.set('strUnitMeasure', null);
                r.set('intItemLocationId', -1);
            });

            store.removeAll(true);
            store.add(records);
            store.sync();
        }
    },

    onFetchClick: function (button) {
        var win = button.up('window');
        var vm = win.getViewModel();
        var current = vm.data.current;
        var itemList = vm.storeInfo.itemList;
        var data = win.context.data;
        var me = this;

        if (!data) return;
        data.saveRecord({ callbackFn: function (batch, eOpts, success) {
            win.setLoading(false);
            win.setLoading('Fetching Items...');
            if (itemList) {
                var filter = ic.count.getFilter(current, true);
                var params = [];
                win.setLoading('Updating details...');

                var resource = "UpdateDetails";
                var requestParams = {
                    intInventoryCountId: current.get('intInventoryCountId'),
                    intEntityUserSecurityId: iRely.config.Security.EntityId,
                    strHeaderNo: current.get('strCountNo'),
                    intLocationId: current.get('intLocationId'),
                    intCategoryId: current.get('intCategoryId'),
                    intCommodityId: current.get('intCommodityId'),
                    intCountGroupId: current.get('intCountGroupId'),
                    intSubLocationId: current.get('intSubLocationId'),
                    intStorageLocationId: current.get('intStorageLocationId'),
                    ysnIncludeZeroOnHand: current.get('ysnIncludeZeroOnHand'),
                    ysnCountByLots: current.get('ysnCountByLots'),
                    dtmAsOfDate: current.get('dtmCountDate')
                };

                if(current.get('strCountBy') === 'Pack') {
                    resource = "UpdateShiftCountDetails";
                    requestParams = {
                        intInventoryCountId: current.get('intInventoryCountId'),
                        intEntityUserSecurityId: iRely.config.Security.EntityId,
                        strHeaderNo: current.get('strCountNo'),
                        intLocationId: current.get('intLocationId'),
                        intCountGroupId: current.get('intCountGroupId')
                    };
                }

                var rx = Inventory.Utils.ajax({
                    url: "./inventory/api/inventorycount/" + resource,
                    method: "PUT",
                    params: requestParams
                })
                .subscribe(function(data) {
                    win.setLoading('Loading Items...');
                    var defaultFilter = ic.count.getFilter(current, true);
                    defaultFilter.push({
                        column: 'intInventoryCountId',
                        value: current.get('intInventoryCountId')
                    });
                    ic.count.loadDetails(me, win, win.context, true, defaultFilter);
                }, function(failed) {
                    win.setLoading(false);    
                    var json = JSON.parse(failed.responseText);
                    iRely.Functions.showCustomDialog('error', 'ok', json.message, function() {

                    });
                });
            }
        } });
    },
    
    onPrintVarianceClick: function (button) {
        var win = button.up('window');
        var me = win.controller;
        var vm = win.getViewModel();
        var current = vm.data.current;
        var CountId = current.get('intInventoryCountId');
     /*   var filters = [
            {
                column: 'intInventoryCountId',
                value: current.get('intInventoryCountId')
            }
        ];*/
        
        if (current) {
            var showAddScreen = function () {
                var search = i21.ModuleMgr.Search;
                search.scope = me;
                search.url = './inventory/api/inventorycount/getprintvariance?countid=' + countid;
               // search.filter = filters;

                if (current.get('ysnIncludeOnHand')) {
                    search.columns = [
                        { dataIndex: 'intInventoryCountDetailId', text: 'Inventory Count Detail Id', dataType: 'numeric', defaultSort: true, hidden: true, key: true},
                        { dataIndex: 'strLocationName', text: 'Location Name', dataType: 'string', hidden: true },
                        { dataIndex: 'strCategory', text: 'Category', dataType: 'string', hidden: true },
                        { dataIndex: 'strCommodity', text: 'Commodity', dataType: 'string', hidden: true },
                        { dataIndex: 'strCountNo', text: 'Count No', dataType: 'string', hidden: true },
                        { dataIndex: 'dtmCountDate', text: 'Count Date', dataType: 'date', xtype: 'datecolumn', hidden: true },

                        { dataIndex: 'strCountLine', text: 'Count Line No', dataType: 'string' },
                        { dataIndex: 'strItemNo', text: 'Item No', dataType: 'string' },
                        { dataIndex: 'strItemDescription', text: 'Description', dataType: 'string' },
                        { dataIndex: 'strSubLocationName', text: 'Storage Location', dataType: 'string' },
                        { dataIndex: 'strStorageLocationName', text: 'Storage Unit', dataType: 'string' },
                        { dataIndex: 'strLotNumber', text: 'Lot Name', dataType: 'string' },
                        { dataIndex: 'strLotAlias', text: 'Lot Alias', dataType: 'string' },
                        { dataIndex: 'dblSystemCount', text: 'System Count', dataType: 'numeric' },
                        { dataIndex: 'dblLastCost', text: 'Last Cost', dataType: 'numeric', hidden:true},
                        { dataIndex: 'dblPallets', text: 'No of Pallets', dataType: 'numeric' },
                        { dataIndex: 'dblQtyPerPallet', text: 'Qty Per Pallet', dataType: 'numeric' },
                        { dataIndex: 'dblPhysicalCount', text: 'Physical Count', dataType: 'numeric' },
                        { dataIndex: 'strUnitMeasure', text: 'UOM', dataType: 'string' },
                        { dataIndex: 'dblPhysicalCountStockUnit', text: 'Physical Count in Stock Unit', dataType: 'numeric'},
                        { dataIndex: 'dblVariance', text: 'Variance', dataType: 'numeric', hidden:true},
                        { dataIndex: 'strUserName', text: 'Entered By', dataType: 'string', hidden:true }
                    ];
                }
                else {
                    search.columns = [
                        { dataIndex: 'intInventoryCountDetailId', text: 'Inventory Count Detail Id', dataType: 'numeric', defaultSort: true, hidden: true, key: true},
                        { dataIndex: 'strLocationName', text: 'Location Name', dataType: 'string', hidden: true },
                        { dataIndex: 'strCategory', text: 'Category', dataType: 'string', hidden: true },
                        { dataIndex: 'strCommodity', text: 'Commodity', dataType: 'string', hidden: true },
                        { dataIndex: 'strCountNo', text: 'Count No', dataType: 'string', hidden: true },
                        { dataIndex: 'dtmCountDate', text: 'Count Date', dataType: 'date', xtype: 'datecolumn', hidden: true },

                        { dataIndex: 'strCountLine', text: 'Count Line No', dataType: 'string' },
                        { dataIndex: 'strItemNo', text: 'Item No', dataType: 'string' },
                        { dataIndex: 'strItemDescription', text: 'Description', dataType: 'string' },
                        { dataIndex: 'strSubLocationName', text: 'Storage Location', dataType: 'string' },
                        { dataIndex: 'strStorageLocationName', text: 'Storage Unit', dataType: 'string' },
                        { dataIndex: 'strLotNumber', text: 'Lot Name', dataType: 'string' },
                        { dataIndex: 'strLotAlias', text: 'Lot Alias', dataType: 'string' },
                        { dataIndex: 'dblLastCost', text: 'Last Cost', dataType: 'numeric', hidden:true},
                        { dataIndex: 'dblPallets', text: 'No of Pallets', dataType: 'numeric' },
                        { dataIndex: 'dblQtyPerPallet', text: 'Qty Per Pallet', dataType: 'numeric' },
                        { dataIndex: 'dblPhysicalCount', text: 'Physical Count', dataType: 'numeric' },
                        { dataIndex: 'strUnitMeasure', text: 'UOM', dataType: 'string' },
                       // { dataIndex: 'dblPhysicalCountStockUnit', text: 'Physical Count in Stock Unit', dataType: 'numeric'},
                        { dataIndex: 'dblVariance', text: 'Variance', dataType: 'numeric', hidden:true },
                        { dataIndex: 'strUserName', text: 'Entered By', dataType: 'string', hidden:true }
                    ];
                }

                search.title = "Print Variance";
                search.showNew = false;
                search.showOpenSelected = false;
                search.showExport = true;
                search.multi = false;
                search.show();
            };
            /*if (button.itemId === 'btnPrintCountSheets') {
                current.set('intStatus', 2);
            }*/
            
            //Save the record first before showing the Print Count Sheets screen
            if(!current.dirty)
                showAddScreen();
            else {
                win.context.data.saveRecord ({
                    successFn: function () {
                        showAddScreen();
                    }
                });
            }
        }
    },

    onLockInventoryClick: function (button) {
        var win = button.up('window');
        var vm = win.getViewModel();
        var current = vm.data.current;
        var context = win.context;
        var isLock = true;
        if (button.text === 'Unlock Inventory') {
            isLock = false;
        } 

        var doLock = function () {
            if (current) {
                Inventory.Utils.ajax({
                    timeout: 120000,
                    url: './inventory/api/inventorycount/lockinventory?inventorycountid',
                    method: 'POST',
                    params: {
                        intInventoryCountId: current.get('intInventoryCountId'),
                        ysnLock: isLock
                    }
                })
                .subscribe(
                    function(response) {
                        var jsonData = Ext.decode(response.responseText);
                        if (!jsonData.success) {
                            iRely.Functions.showErrorDialog(jsonData.message.statusText);
                        }
                        else {
                            context.configuration.paging.store.load();
                        }
                    },
                    function(response) {
                        var jsonData = Ext.decode(response.responseText);
                        iRely.Functions.showErrorDialog(jsonData.ExceptionMessage);
                    }
                );
            }
        };

        // Save has data changes first before doing the post.
        context.data.saveRecord({
            callbackFn: function (batch, eOpts, success) {
                doLock();
            }
        });
    },

    onPostClick: function(button, e, oOpts) {
        var me = this;
        var win = button.up('window');
        var context = win.context;
        var currentRecord = win.viewModel.data.current;
        var tabInventoryCount = win.down('#tabInventoryCount');
        var activeTab = tabInventoryCount.getActiveTab();       
        var paging = win.down('ipagingstatusbar');
        var grd = win.down('#grdPhysicalCount');
        
        var doPost = function (){
            var current = currentRecord; 
            Inventory.Utils.ajax({
                url: './inventory/api/inventorycount/posttransaction',
                params:{
                    strTransactionId: current.get('strCountNo'),
                    isPost: current.get('ysnPosted') ? false : true,
                    isRecap: false
                },
                method: 'post'
            })
            .subscribe(
                function(successResponse) {
                    grd.getSelectionModel().deselectAll();
                    paging.doRefresh();

                    // Check what is the active tab. If it is the Post Preview tab, load the recap data. 
                    if (activeTab.itemId == 'pgePostPreview'){
                        var cfg = {
                            isAfterPostCall: true,
                            ysnPosted: current.get('ysnPosted') ? true : false
                        };
                        me.doPostPreview(win, cfg);
                    }
                    iRely.Functions.refreshFloatingSearch('Inventory.view.InventoryCount');
                }
                ,function(failureResponse) {
                    var responseText = Ext.decode(failureResponse.responseText);
                    var message = responseText ? responseText.message : {}; 
                    var statusText = message ? message.statusText : 'Oh no! Something went wrong while posting the inventory count.';
                    iRely.Functions.showErrorDialog(statusText);   

                    grd.getSelectionModel().deselectAll();
                    paging.doRefresh();
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
                            doPost();             
                        }
                    });
                }
            });            
        }
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

        var doRecap = function (currentRecord){
            Inventory.Utils.ajax({
                url: './inventory/api/inventorycount/posttransaction',
                params:{
                    strTransactionId: currentRecord.get('strCountNo'),
                    isPost: isAfterPostCall ? ysnPosted : currentRecord.get('ysnPosted') ? false : true,
                    isRecap: true
                },
                method: 'post'
            })
            .subscribe(
                function(successResponse) {
                    var postResult = Ext.decode(successResponse.responseText);
                    if(postResult.success === false) {
                        iRely.Functions.showErrorDialog(postResult.message.statusText);                    
                    } else {
                        var batchId = postResult.data.strBatchId;
                        if (batchId) {
                            me.bindRecapGrid(batchId);
                        }       
                    }             
                }
                ,function(failureResponse) {
                    // Show Post Preview failed.
                    var jsonData = Ext.decode(failureResponse.responseText);
                    iRely.Functions.showErrorDialog(jsonData.message.statusText);                    
                }
            )
        };    

        // If there is no data change, calculate the charge and do the recap. 
        if (!context.data.hasChanges()) {
            doRecap(win.viewModel.data.current);
        }

        // Save has data changes first before anything else. 
        context.data.saveRecord({
            successFn: function () {
                doRecap(win.viewModel.data.current);             
            }
        });        
    },    

    onPostClick2: function (button, e, eOpts) {
        var me = this;
        var win = button.up('window');
        var context = win.context;
        var store = win.down("#grdPhysicalCount").store;
        var currentCountItems = win.viewModel.data.current;
        var countDetail = store.data.items;
        var countItemsToPost = 0;  
        var countItemsNotPosted = 0;
        var itemIndex = 0; 
        var itemsNotPosted = new Array();

        var doPost = function () {
            var strCountNo = win.viewModel.data.current.get('strCountNo');
            var posted = win.viewModel.data.current.get('ysnPosted');

            var options = {
                posturl: './inventory/api/inventorycount/posttransaction',
                strTransactionId: strCountNo,
                isPost: !posted,
                isRecap: false,
                callback: me.onAfterPost,
                scope: me
            };

            CashManagement.common.BusinessRules.callPostRequest(options);
        };
        
        var validatePost = function() {
            if(countDetail.length == 0) {
                //Show error message if there are no items in the grid except for the dummy
                iRely.Functions.showErrorDialog('There are no items to post.');
                return;
            }
            else {
                Ext.Array.each(countDetail, function (item) {
                        
                    itemIndex++;
                        
                    if (item.get('ysnRecount') === false)
                        {
                            if (!item.dummy)
                                {
                                     countItemsToPost++;
                                }        
                        }
                        
                    else
                        {
                            if (!item.dummy)
                                {
                                    itemsNotPosted[countItemsNotPosted] = item.get('strItemNo');
                                    countItemsNotPosted++;
                                }    
                        }
                        
                    if(itemIndex === countDetail.length)
                        {
                            if(countItemsNotPosted > 0)
                                {
                                        if(countItemsNotPosted === 1) {
                                            iRely.Functions.showCustomDialog('Warning','ok','Item ' + itemsNotPosted[0] + ' cannot be processed since it is subject for recounting.');
                                        }
                                        
                                        if(countItemsNotPosted > 1)
                                            {
                                                var listItems = '<br><br>';
                                                
                                                for (var i=0; i<= countItemsNotPosted-1; i++)
                                                    {
                                                        listItems = listItems + itemsNotPosted[i] + '<br>';
                                                    }
                                                
                                                iRely.Functions.showCustomDialog('Warning','ok','The following items cannot be processed since they are subject for recounting:' + listItems);
                                            }
                                }
                            
                            if(countItemsToPost > 0)
                                {
                                        doPost();
                                }
                        }
                });   
            }
        };

        // If there is no data change, do the post.
        if (!context.data.hasChanges()) {
             validatePost();
        }

        // Save has data changes first before doing the post.
        context.data.saveRecord({
            successFn: function () {
                validatePost();
           }
        });
    },

    onRecapClick: function (button, e, eOpts) {
        var me = this;
        var win = button.up('window');
        var context = win.context;

        var doRecap = function (recapButton, currentRecord, currency) {

            // Call the buildRecapData to generate the recap data
            CashManagement.common.BusinessRules.buildRecapData({
                posturl: './inventory/api/inventorycount/posttransaction',
                strTransactionId: currentRecord.get('strCountNo'),
                ysnPosted: currentRecord.get('ysnPosted'),
                scope: me,
                success: function () {
                    // If data is generated, show the recap screen.
                    CashManagement.common.BusinessRules.showRecap({
                        strTransactionId: currentRecord.get('strCountNo'),
                        ysnPosted: currentRecord.get('ysnPosted'),
                        dtmDate: currentRecord.get('dtmCountDate'),
                        strCurrencyId: currency,
                        dblExchangeRate: 1,
                        scope: me,
                        postCallback: function () {
                            me.onPostClick(recapButton);
                        },
                        unpostCallback: function () {
                            me.onPostClick(recapButton);
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
            doRecap(button, win.viewModel.data.current, null);
            return;
        }

        // Save has data changes first before doing the post.
        context.data.saveRecord({
            successFn: function () {
                doRecap(button, win.viewModel.data.current, null);
            }
        });
    },

    onAfterPost: function (success, message) {
        if (success === true) {
            var me = this;
            var win = me.view;
            var paging = win.down('ipagingstatusbar');

            paging.doRefresh();
        }
        else {
            iRely.Functions.showCustomDialog(iRely.Functions.dialogType.ERROR, iRely.Functions.dialogButtonType.OK, message);
        }
    },

    onViewItemNo: function (value, record) {
        var itemId = record.get('intItemId');
        i21.ModuleMgr.Inventory.showScreen(itemId, 'ItemId');
    },

    onViewItemDescription: function (value, record) {
        var itemId = record.get('intItemId');
        i21.ModuleMgr.Inventory.showScreen(itemId, 'ItemId');
    },

    onViewCategory: function (value, record) {
        var category = record.get('strCategory');
        i21.ModuleMgr.Inventory.showScreen(category, 'Category');
    },

    onInventoryCountDetailSelect: function (combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var grid = combo.up('grid');
        var plugin = grid ? grid.getPlugin('cepPhysicalCount') : null;
        var current = plugin ? plugin.getActiveRecord() : null;
        var me = this;
        var vm = win.getViewModel();

        if (current) {
            switch (combo.itemId) {
                case 'cboItem':
                    current.set('strItemDescription', records[0].get('strDescription'));
                    current.set('strCategory', records[0].get('strCategoryCode'));
                    current.set('intCategoryId', records[0].get('intCategoryId'));
                    current.set('strCategory', records[0].get('strCategoryCode'));
                    current.set('strStorageLocationName', null);
                    current.set('intStorageLocationId', null);
                    current.set('strSubLocationName', null);
                    current.set('intSubLocationId', null);
                    current.set('dblSystemCount', null);
                    current.set('intLotId', null);
                    current.set('strLotNo', null);
                    current.set('strLotAlias', null);
                    current.set('intWeightUOMId', null);
                    current.set('strWeightUOM', null);
                    current.set('dblWeightQty', null);
                    current.set('dblWeightUOMConversionFactor', null);
                    current.set('dblItemUOMConversionFactor', records[0].get('dblStockUnitQty'));
                    current.set('strStockUOM', records[0].get('strStockUOM'));
                    current.set('intStockUOMId', records[0].get('intStockUOMId'));
                    current.set('intItemUOMId', records[0].get('intStockUOMId'));
                    current.set('strUnitMeasure', records[0].get('strStockUOM'));
                    //current.set('selectedLot', null); // @TODO
                    // current.set('intItemUOMId', records[0].get('intStockUOMId'));
                    // current.set('strUnitMeasure', records[0].get('strStockUOM'));

                    //current.set('isLotted', rec.get('strLotTracking') !== 'No'); // @TODO

                    me.getTotalLocationStockOnHand(
                        vm.get('current.intLocationId'),
                        current.get('intItemId'),
                        current.get('intSubLocationId'),
                        current.get('intStorageLocationId'),
                        current.get('intLotId'),
                        current.get('intItemUOMId'),
                        function (quantity) {
                            current.set('dblSystemCount', quantity);
                        }
                    );

                    if (current.get('strCountLine') === '' || current.get('strCountLine') === null) {
                        var win = combo.up('window');
                        var currentItems = win.viewModel.data.current;
                        var countDetail = currentItems.tblICInventoryCountDetails().data.items;
                        var count = countDetail.length;
                        var strCountLine = currentItems.get('strCountNo') + '-' + count;
                        var countLength = 0;

                        if (count === 1) {
                            current.set('strCountLine', strCountLine);
                        }

                        if (count > 1) {
                            Ext.Array.each(currentItems.tblICInventoryCountDetails().data.items, function (item) {
                                if (!item.dummy) {
                                    countLength++;
                                    if (countLength == count - 1) {
                                        var itemCountLine = item.get('strCountLine') + '';
                                        var strCountLineSplit = itemCountLine.split('-');
                                        count = parseInt(strCountLineSplit[2]) + 1;
                                        strCountLine = currentItems.get('strCountNo') + '-' + count;
                                        current.set('strCountLine', strCountLine);
                                    }
                                }

                            });
                        }

                    }
                    break;
                case 'cboGrdSubLocation':
                    current.set('strStorageLocationName', null);
                    current.set('intStorageLocationId', null);
                    current.set('intItemLocationId', records[0].get('intItemLocationId'));
                    current.set('intLotId', null);
                    current.set('strLotNo', null);
                    current.set('strLotAlias', null);
                    current.set('dblSystemCount', null);
                    current.set('intItemUOMId', null);
                    current.set('strUnitMeasure', null);
                    //current.set('selectedLot', null); //@TODO
                    me.getTotalLocationStockOnHand(
                        vm.get('current.intLocationId'),
                        current.get('intItemId'),
                        current.get('intSubLocationId'),
                        current.get('intStorageLocationId'),
                        current.get('intLotId'),
                        current.get('intItemUOMId'),
                        function (quantity) {
                            current.set('dblSystemCount', quantity);
                        }
                    );
                    break;
                case 'cboGrdStorageLocation':
                    vm.set('intLotId', null);
                    vm.set('strLotNo', null);
                    vm.set('strLotAlias', null);
                    current.set('dblSystemCount', null);
                    current.set('intItemUOMId', null);
                    current.set('strUnitMeasure', null);

                    me.getTotalLocationStockOnHand(
                        vm.get('current.intLocationId'),
                        current.get('intItemId'),
                        current.get('intSubLocationId'),
                        current.get('intStorageLocationId'),
                        current.get('intLotId'),
                        current.get('intItemUOMId'),
                        function (quantity) {
                            current.set('dblSystemCount', quantity);
                        }
                    );
                    break;
                case 'cboLotNo':
                    current.set('dblSystemCount', null);
                    current.set('strUnitMeasure', records[0].get('strItemUOM'));
                    current.set('intItemUOMId', records[0].get('intItemUOMId'));
                    current.set('strLotAlias', records[0].get('strLotAlias'));
                    current.set('dblSystemCount', records[0].get('dblQty'));
                    current.set('dblItemUOMConversionFactor', records[0].get('dblItemUOMConv'));
                    current.set('intWeightUOMId', null);
                    current.set('dblWeightQty', null);
                    current.set('dblNetQty', null);
                    current.set('strWeightUOM', null);
                    //current.set('dblWeightUOMConversionFactor', null);
                    me.getTotalLocationStockOnHand(
                        vm.get('current.intLocationId'),
                        current.get('intItemId'),
                        current.get('intSubLocationId'),
                        current.get('intStorageLocationId'),
                        current.get('intLotId'),
                        current.get('intItemUOMId'),
                        function (quantity) {
                            current.set('dblSystemCount', quantity);
                        }
                    );
                    me.mapGrossNet(current);
                    break;
                case 'cboWeightUOM':
                    current.set('dblWeightUOMConversionFactor', records[0].get('dblUnitQty'));
                    me.mapGrossNet(current);
                    break;
                case 'cboUOM':
                    current.set('dblItemUOMConversionFactor', records[0].get('dblUnitQty'));
                    if (current.get('intLotId')) {
                        current.set('dblSystemCount', records[0].get('dblOnHand'));
                        me.getTotalLocationStockOnHand(
                            vm.get('current.intLocationId'),
                            current.get('intItemId'),
                            current.get('intSubLocationId'),
                            current.get('intStorageLocationId'),
                            current.get('intLotId'),
                            current.get('intItemUOMId'),
                            function (quantity) {
                                current.set('dblSystemCount', quantity);
                            }
                        );
                    } else {
                        current.set('dblSystemCount', 0.00);
                    }

                    me.mapGrossNet(current);
                    break;
            }
        }
    },

    mapGrossNet: function (current) {
        var gn = this.calculateGrossNet(current.get('dblPhysicalCount'), current.get('dblItemUOMConversionFactor'), current.get('dblWeightUOMConversionFactor'), 0.00);
        current.set('dblWeightQty', gn.gross);
        current.set('dblNetQty', gn.gross);
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

    onCountGroupClick: function () {
        iRely.Functions.openScreen('Inventory.view.InventoryCountGroup', { action: 'new', viewConfig: { modal: true }});
    },
    
    onGrdPhysicalClick: function(view, record, cellIndex, e, eOpts) {
         var win = view.up('window');    
         var current = win.viewModel.data.current;
         var grid = view.up('grid');
        
        //Check if column is Item 
        if(cellIndex === 1)
            {
               if(current.get('strCountNo') === null || current.get('strCountNo') === '')
                {
                    win.context.data.saveRecord ();
                }
            }
    },
    onPrintPhysicalCount: function (button) {
        var win = button.up('window');
        var vm = win.getViewModel();
        var current = vm.data.current;
        // Save has data changes first before doing the post.
        win.context.data.saveRecord({
            callbackFn: function() { 
                var filters = [{
                    Name: 'strCountNo',
                    Type: 'string',
                    Condition: 'EQUAL TO',
                    From: current.get('strCountNo'),
                    Operator: 'AND'
                }];

                iRely.Functions.openScreen('Reporting.view.ReportViewer', {
                    selectedReport: 'PhysicalInventoryCount',
                    selectedGroup: 'Inventory',
                    selectedParameters: filters,
                    viewConfig: { maximized: true }
                });
            }
        });

         if (button.itemId === 'btnPrintCountSheets' && current.get('intStatus') !== 4) {
                current.set('intStatus', 2);
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

        Inventory.Utils.ajax({
            timeout: 120000,   
            url: './inventory/api/item/getitemstockuomsummary',
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
                record.set('dblSystemCount', qty);
            },
            function(error) {
                var json = Ext.decode(error.responseText);
                iRely.Functions.showErrorDialog(json.ExceptionMessage);
            }
        );
    },

    onSubLocationChange: function (control, newValue, oldValue, eOpts) {
        var me = this;
        var grid = control.up('grid');
        var plugin = grid.getPlugin('cepPhysicalCount');
        var current = plugin.getActiveRecord();
        if (current && (newValue === null || newValue === '')) {
            current.set('dblSystemCount', 0);
            current.set('intSubLocationId', null);
        }
    },

     onStorageLocationChange: function (obj, newValue, oldValue, eOpts) {
        var me = this;
        var grid = obj.up('grid');
        var plugin = grid.getPlugin('cepPhysicalCount');
        var current = plugin.getActiveRecord();
        var win = obj.up('window');

         if (current && (newValue === null || newValue === '')) {
            current.set('intStorageLocationId', null);
            me.getStockQuantity(current, win);
        }
    },

    onInventoryCountTabChange: function(tabPanel, newCard, oldCard, eOpts){
        var me = this;
        var win = tabPanel.up('window');
        var context = win.context;
        var current = win.viewModel.data.current;        
        switch (newCard.itemId) {
            case 'pgePostPreview': 
                me.doPostPreview(win);
        }
    },

    onItemBeforeQuery: function (obj) {
        if (obj.combo) {
            if (obj.combo.itemId === 'cboItem') {
                var vm = obj.combo.up('window').getViewModel();
                var current = vm.get('current');
                var locationId = current.get('intLocationId');

                obj.combo.defaultFilters = [
                    {
                        column: 'intLocationId',
                        value: locationId,
                        conjunction: 'and'
                    },
                    {
                        column: 'strLotTracking',
                        value: 'No',
                        conjunction: 'and',
                        condition: 'eq'
                    }
                ];

                if (current.get('ysnCountByLots')) {
                    obj.combo.defaultFilters = [
                        {
                            column: 'intLocationId',
                            value: locationId,
                            conjunction: 'and'
                        },
                        {
                            column: 'strLotTracking',
                            value: 'No',
                            conjunction: 'and',
                            condition: 'noteq'
                        }
                    ];
                }
            }
        }
    },

    onUOMBeforeQuery: function (obj) {
        if (obj.combo) {
            if (obj.combo.itemId === 'cboUOM') {
                var vm = obj.combo.up('window').getViewModel();
                var current = vm.get('current');
                var locationId = current.get('intLocationId');
                var grdPhysicalCount = obj.combo.up('window').down('#grdPhysicalCount');

                obj.combo.defaultFilters = [
                    {
                        column: 'intItemId',
                        value: grdPhysicalCount.selection.get('intItemId'),
                        conjunction: 'and'
                    },
                    {
                        column: 'intLocationId',
                        value: locationId,
                        conjunction: 'and'
                    }
                ];

                if (grdPhysicalCount.selection.get('intLotId')) {
                    if (grdPhysicalCount.selection.get('intLotId')) {
                        obj.combo.defaultFilters = [
                            {
                                column: 'intItemId',
                                value: grdPhysicalCount.selection.get('intItemId'),
                                conjunction: 'and'
                            },
                            {
                                column: 'intLocationId',
                                value: locationId,
                                conjunction: 'and'
                            },
                            {
                                column: 'intItemUOMId',
                                value: grdPhysicalCount.selection.get('intItemUOMId'),
                                conjunction: 'and',
                                condition: 'eq'
                            }
                        ];
                    }
                }
            }
        }
    },

    onPhysicalCountChange: function (config, column) {
        var me = this;
        var current = column.record;
        if (column.field === 'dblPhysicalCount')
            me.mapGrossNet(current);
        else if (column.field === "dblQtyPerPallet" || column.field === "dblPallets") {
            var calcPallet = current.get('dblPallets') !== 0 && current.get('dblQtyPerPallet') !== 0;
            if (calcPallet) {
                current.set('dblPhysicalCount', current.get('dblPallets') * current.get('dblQtyPerPallet'));
            }
        }
    },
    
    init: function (application) {
        this.control({
            "#cboUOM": {
                //  beforequery: this.onUOMBeforeQuery,
                select: this.onInventoryCountDetailSelect
            },
            "#cboWeightUOM": {
                select: this.onInventoryCountDetailSelect
            },
            "#cboCountGroup": {
                select: this.onCountGroupSelect
            },
            "#btnFetch": {
                click: this.onFetchClick
            },
            "#btnFetchDetails": {
                click: this.onFetchClick
            },
            "#btnPrintCountSheets": {
                click: this.onPrintPhysicalCount
            },
            "#btnPrintVariance": {
                click: this.onPrintVarianceClick
            },
            "#btnLockInventory": {
                click: this.onLockInventoryClick
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
            "#cboItem": {
                beforequery: this.onItemBeforeQuery,
                select: this.onInventoryCountDetailSelect
            },
            "#cboGrdSubLocation": {
                select: this.onInventoryCountDetailSelect,
                change: this.onSubLocationChange
            },
            "#cboGrdStorageLocation": {
                select: this.onInventoryCountDetailSelect,
                change: this.onStorageLocationChange
            },
            "#cboLotNo": {
                select: this.onInventoryCountDetailSelect
            },
            "#grdPhysicalCount": {
                cellclick: this.onGrdPhysicalClick
            },
            "#colRecount": {
                checkchange: this.onRecountCheckChange
            },
            "#txtSearchFilter": {
                specialkey: this.onSearchFilter
            },
            "#cboPageSize": {
                change: function(combo) {
                    /* Seriously, don't do this shit! This causes the screen to send a server request twice!!*/
                    //var win = combo.up('window');
                    //ic.count.loadDetails(this, win, win.context, true, ic.count.getFilter(win.viewModel.data.current));
                }
            },
            "#btnDetachSelectedRows": {
                click: this.onDetachSelectedRows
            },
            "#btnDetachAll": {
                click: this.onDetachAll
            },
            "#btnAttachNewRow": {
                click: this.onAttachNewRow
            },
            "#cboCountBy": {
                select: this.onCountBySelect
            },
            "#tabInventoryCount": {
                tabChange: this.onInventoryCountTabChange
            },
            "#btnShowRow": {
                click: this.onShowRow
            }
        });
    }
});
