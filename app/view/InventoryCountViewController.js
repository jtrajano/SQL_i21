Ext.define('Inventory.view.InventoryCountViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icinventorycount',
    requires: [
        'CashManagement.common.Text',
        'CashManagement.common.BusinessRules'
    ],

    config: {
        searchConfig: {
            title: 'Search Inventory Count',
            type: 'Inventory.InventoryCount',
            api: {
                read: '../Inventory/api/InventoryCount/Search'
            },
            columns: [
                {dataIndex: 'intInventoryCountId', text: "Count Id", flex: 1, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strCountNo', text: 'Count No', flex: 1, dataType: 'string'},
                {dataIndex: 'strLocationName', text: 'Location', flex: 1, dataType: 'string'},
                {dataIndex: 'strCategory', text: 'Category', flex: 1, dataType: 'string'},
                {dataIndex: 'strCommodity', text: 'Commodity', flex: 1, dataType: 'string'},
                {dataIndex: 'strCountGroup', text: 'Count Group', flex: 1, dataType: 'string'},
                {dataIndex: 'dtmCountDate', text: 'Count Date', flex: 1, dataType: 'date', xtype: 'datecolumn'},
                {dataIndex: 'strSubLocationName', text: 'Sub Location', flex: 1, dataType: 'string'},
                {dataIndex: 'strStorageLocationName', text: 'Storage Location', flex: 1, dataType: 'string'},
                {dataIndex: 'strStatus', text: 'Status', flex: 1, dataType: 'string'}
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
                },
                {
                    text: 'Count Group',
                    itemId: 'btnCountGroup',
                    clickHandler: 'onCountGroupClick',
                    width: 80
                }
            ]
        },
        binding: {
            bind: {
                title: 'Inventory Count - {current.strCountNo}'
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
                text: '{getPostText}',
                hidden: '{checkPost}'
            },
            btnRecap: {
                hidden: '{checkPost}'
            },
            btnRecount: {
                hidden: '{checkRecount}'
            },
            btnFetch: {
                disabled: '{checkPrintCountSheet}'
            },

            cboLocation: {
                value: '{current.intLocationId}',
                store: '{location}'
            },
            cboCategory: {
                value: '{current.intCategoryId}',
                store: '{category}'
            },
            cboCommodity: {
                value: '{current.intCommodityId}',
                store: '{commodity}'
            },
            cboCountGroup: {
                value: '{current.intCountGroupId}',
                store: '{countGroup}'
            },
            dtpCountDate: '{current.dtmCountDate}',
            txtCountNumber: '{current.strCountNo}',
            cboSubLocation: {
                value: '{current.intSubLocationId}',
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
            },
            cboStorageLocation: {
                value: '{current.intStorageLocationId}',
                store: '{storageLocation}',
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

            chkIncludeZeroOnHand: '{current.ysnIncludeZeroOnHand}',
            chkIncludeOnHand: {
                value: '{current.ysnIncludeOnHand}',
                readOnly: '{hasCountGroup}'
            },
            chkScannedCountEntry: {
                value: '{current.ysnScannedCountEntry}',
                readOnly: '{hasCountGroup}'
            },
            chkCountByLots: {
                value: '{current.ysnCountByLots}',
                readOnly: '{hasCountGroup}'
            },
            chkCountByPallets: {
                value: '{current.ysnCountByPallets}',
                readOnly: '{hasCountGroup}'
            },
            chkRecountMismatch: {
                value: '{current.ysnRecountMismatch}',
                readOnly: '{hasCountGroup}'
            },
            chkExternal: {
                value: '{current.ysnExternal}',
                readOnly: '{hasCountGroup}'
            },
            chkRecount: '{current.ysnRecount}',

            txtReferenceCountNo: '{current.intRecountReferenceId}',
            cboStatus: {
                value: '{current.intStatus}',
                store: '{status}'
            },

            grdPhysicalCount: {
                colItem: {
                    dataIndex: 'strItemNo',
                    editor: {
                        store: '{itemStock}',
                        origValueField: 'intItemId',
                        origUpdateField: 'intItemId',
                        defaultFilters: [
                            {
                                column: 'intLocationId',
                                value: '{current.intLocationId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colDescription: {
                    dataIndex: 'strItemDescription',
                    drillDownText: 'View Item',
                    drillDownClick: 'onViewItemDescription'
                },
                colCategory: {
                    dataIndex: 'strCategory',
                    drillDownText: 'View Category',
                    drillDownClick: 'onViewCategory'
                },
                colSubLocation: {
                    dataIndex: 'strSubLocationName',
                    editor: {
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
                                column: 'dblOnHand',
                                value: '0',
                                conjunction: 'and',
                                condition: 'gt'
                            },
                            {
                                column: 'ysnStockUnit',
                                value: true,
                                conjunction: 'and',
                                condition: 'eq'
                            }
                        ]
                    }
                },
                colStorageLocation: {
                    dataIndex: 'strStorageLocationName',
                    editor: {
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
                    dataIndex: 'strLotNumber',
                    hidden: '{!current.ysnCountByLots}',
                    editor: {
                        store: '{lot}',
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
                    hidden: '{!current.ysnCountByLots}'
                },
                colSystemCount: 'dblSystemCount',
                colLastCost: 'dblLastCost',
                colCountLineNo: 'strCountLine',
                colNoPallets: {
                    dataIndex: 'dblPallets',
                    hidden: '{!current.ysnCountByPallets}'
                },
                colQtyPerPallet: {
                    dataIndex: 'dblQtyPerPallet',
                    hidden: '{!current.ysnCountByPallets}'
                },
                colPhysicalCount: 'dblPhysicalCount',
                colUOM: {
                    dataIndex: 'strUnitMeasure'
                },
                colPhysicalCountStockUnit: 'dblPhysicalCountStockUnit',
                colVariance: 'dblVariance',
                colRecount: 'ysnRecount',
                colEnteredBy: 'strUserName'
            }
        }
    },

    setupContext: function (options) {
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.InventoryCount', { pageSize: 1 });

        win.context = Ext.create('iRely.mvvm.Engine', {
            window: win,
            store: store,
            include: 'tblICInventoryCountDetails.vyuICGetInventoryCountDetail',
            createRecord: me.createRecord,
            binding: me.config.binding,
            details: [
                {
                    key: 'tblICInventoryCountDetails',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: win.down('#grdPhysicalCount'),
                        deleteButton: win.down('#btnRemove'),
                        createRecord: me.createLineItemRecord
                    })
                }
            ]
        });

        return win.context;
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
                            column: 'intInventoryCountId',
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
        var record = Ext.create('Inventory.model.InventoryCount');

        record.set('dtmCountDate', today);
        record.set('intStatus', 1);
        if (app.DefaultLocation > 0)
            record.set('intLocationId', app.DefaultLocation);

        action(record);
    },

    createLineItemRecord: function (config, action) {
        var record = Ext.create('Inventory.model.InventoryCountDetail');
        var strCountLine = '';

        record.set('strCountLine', strCountLine);
        record.set('intEntityUserSecurityId', iRely.config.Security.EntityId);
        record.set('strUserName', iRely.config.Security.UserName);

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

    onFetchClick: function (button) {
        var win = button.up('window');
        var vm = win.getViewModel();
        var current = vm.data.current;
        var itemList = vm.storeInfo.itemList;
        var data = win.context.data;

        if (!data) return;
        data.saveRecord({ callbackFn: function (batch, eOpts, success) {
            win.setLoading('Fetching Items...');
            if (itemList) {
                var filter = [];
                if (!iRely.Functions.isEmpty(current.get('intLocationId'))) {
                    filter.push({
                        column: 'intLocationId',
                        value: current.get('intLocationId'),
                        conjunction: 'and'
                    });
                }
                ;
                if (!iRely.Functions.isEmpty(current.get('intCategoryId'))) {
                    filter.push({
                        column: 'intCategoryId',
                        value: current.get('intCategoryId'),
                        conjunction: 'and'
                    });
                }
                ;
                if (!iRely.Functions.isEmpty(current.get('intCommodityId'))) {
                    filter.push({
                        column: 'intCommodityId',
                        value: current.get('intCommodityId'),
                        conjunction: 'and'
                    });
                }
                ;
                if (!iRely.Functions.isEmpty(current.get('intCountGroupId'))) {
                    filter.push({
                        column: 'intCountGroupId',
                        value: current.get('intCountGroupId'),
                        conjunction: 'and'
                    });
                }
                ;
                if (!iRely.Functions.isEmpty(current.get('intSubLocationId'))) {
                    filter.push({
                        column: 'intSubLocationId',
                        value: current.get('intSubLocationId'),
                        conjunction: 'and'
                    });
                }
                ;
                if (!iRely.Functions.isEmpty(current.get('intStorageLocationId'))) {
                    filter.push({
                        column: 'intStorageLocationId',
                        value: current.get('intStorageLocationId'),
                        conjunction: 'and'
                    });
                }
                ;

                if (current.get('ysnCountByLots')) {
                    itemList = vm.storeInfo.itemListByLot;
                }

                itemList.load({
                    filters: filter,
                    callback: function (records, eOpts, success) {
                        if (success) {
                            if (records) {
                                current.tblICInventoryCountDetails().removeAll();
                                var count = 1;
                                Ext.Array.each(records, function (record) {
                                    var newItem = Ext.create('Inventory.model.InventoryCountDetail', {
                                        intItemId: record.get('intItemId'),
                                        intItemLocationId: record.get('intItemLocationId'),
                                        intSubLocationId: record.get('intSubLocationId'),
                                        intStorageLocationId: record.get('intStorageLocationId'),
                                        intLotId: record.get('intLotId'),
                                        dblSystemCount: record.get('dblOnHand'),
                                        dblLastCost: record.get('dblLastCost'),
                                        strCountLine: current.get('strCountNo') + '-' + count,
                                        intItemUOMId: record.get('intItemUOMId'),
                                        ysnRecount: false,
                                        intEntityUserSecurityId: iRely.config.Security.EntityId,

                                        strItemNo: record.get('strItemNo'),
                                        strItemDescription: record.get('strItemDescription'),
                                        strLotTracking: record.get('strLotTracking'),
                                        strCategory: record.get('strCategoryCode'),
                                        strLocationName: record.get('strLocationName'),
                                        strSubLocationName: record.get('strSubLocationName'),
                                        strStorageLocationName: record.get('strStorageLocationName'),
                                        strLotNumber: record.get('strLotNumber'),
                                        strLotAlias: record.get('strLotAlias'),
                                        strUnitMeasure: record.get('strUnitMeasure'),
                                        strUserName: iRely.config.Security.UserName
                                    });
                                    current.tblICInventoryCountDetails().add(newItem);
                                    count++;
                                });
                            }
                        }
                        win.setLoading(false);
                    }
                });
            }
        } });
    },

    onPrintCountSheetsClick: function (button) {
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
                search.url = '../Inventory/api/InventoryCount/GetCountSheets?CountId=' + CountId;
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
                        { dataIndex: 'strSubLocationName', text: 'Sub Location', dataType: 'string' },
                        { dataIndex: 'strStorageLocationName', text: 'Storage Location', dataType: 'string' },
                        { dataIndex: 'strLotNumber', text: 'Lot Name', dataType: 'string' },
                        { dataIndex: 'strLotAlias', text: 'Lot Alias', dataType: 'string' },
                        { dataIndex: 'dblSystemCount', text: 'System Count', dataType: 'numeric' },
                        { dataIndex: 'dblLastCost', text: 'Last Cost', dataType: 'numeric', hidden:true},
                        { dataIndex: 'dblPalletsBlank', text: 'No of Pallets', dataType: 'numeric' },
                        { dataIndex: 'dblQtyPerPalletBlank', text: 'Qty Per Pallet', dataType: 'numeric' },
                        { dataIndex: 'dblPhysicalCountBlank', text: 'Physical Count', dataType: 'numeric' },
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
                        { dataIndex: 'strSubLocationName', text: 'Sub Location', dataType: 'string' },
                        { dataIndex: 'strStorageLocationName', text: 'Storage Location', dataType: 'string' },
                        { dataIndex: 'strLotNumber', text: 'Lot Name', dataType: 'string' },
                        { dataIndex: 'strLotAlias', text: 'Lot Alias', dataType: 'string' },
                        { dataIndex: 'dblLastCost', text: 'Last Cost', dataType: 'numeric', hidden:true},
                        { dataIndex: 'dblPalletsBlank', text: 'No of Pallets', dataType: 'numeric' },
                        { dataIndex: 'dblQtyPerPalletBlank', text: 'Qty Per Pallet', dataType: 'numeric' },
                        { dataIndex: 'dblPhysicalCountBlank', text: 'Physical Count', dataType: 'numeric' },
                        { dataIndex: 'strUnitMeasure', text: 'UOM', dataType: 'string' },
                       // { dataIndex: 'dblPhysicalCountStockUnit', text: 'Physical Count in Stock Unit', dataType: 'numeric'},
                        { dataIndex: 'dblVariance', text: 'Variance', dataType: 'numeric', hidden:true },
                        { dataIndex: 'strUserName', text: 'Entered By', dataType: 'string', hidden:true }
                    ];
                }

                search.title = "Print Count Sheets";
                search.showNew = false;
                search.showOpenSelected = false;
                search.showExport = true;
                search.multi = false;
                search.show();
            };
            if (button.itemId === 'btnPrintCountSheets') {
                current.set('intStatus', 2);
            }
           
            //Save the record first before showing the Print Count Sheets screen
            win.context.data.saveRecord ({
            successFn: function () {
                showAddScreen();
                }
            });
        }
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
                search.url = '../Inventory/api/InventoryCount/GetCountSheets?CountId=' + CountId;
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
                        { dataIndex: 'strSubLocationName', text: 'Sub Location', dataType: 'string' },
                        { dataIndex: 'strStorageLocationName', text: 'Storage Location', dataType: 'string' },
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
                        { dataIndex: 'strSubLocationName', text: 'Sub Location', dataType: 'string' },
                        { dataIndex: 'strStorageLocationName', text: 'Storage Location', dataType: 'string' },
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
            if (button.itemId === 'btnPrintCountSheets') {
                current.set('intStatus', 2);
            }
            showAddScreen();
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
                Ext.Ajax.request({
                    timeout: 120000,
                    url: '../Inventory/api/InventoryCount/LockInventory?inventoryCountId=' + current.get('intInventoryCountId') + '&ysnLock=' + isLock,
                    method: 'post',
                    success: function (response) {
                        var jsonData = Ext.decode(response.responseText);
                        if (!jsonData.success) {
                            iRely.Functions.showErrorDialog(jsonData.message.statusText);
                        }
                        else {
                            context.configuration.paging.store.load();
                        }
                    },
                    failure: function (response) {
                        var jsonData = Ext.decode(response.responseText);
                        iRely.Functions.showErrorDialog(jsonData.ExceptionMessage);
                    }
                });
            }
        };

        // Save has data changes first before doing the post.
        context.data.saveRecord({
            callbackFn: function (batch, eOpts, success) {
                doLock();
            }
        });
    },

    onPostClick: function (button, e, eOpts) {
        var me = this;
        var win = button.up('window');
        var context = win.context;

        var doPost = function () {
            var strCountNo = win.viewModel.data.current.get('strCountNo');
            var posted = win.viewModel.data.current.get('ysnPosted');

            var options = {
                postURL: '../Inventory/api/InventoryCount/PostTransaction',
                strTransactionId: strCountNo,
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
        var context = win.context;

        var doRecap = function (recapButton, currentRecord, currency) {

            // Call the buildRecapData to generate the recap data
            CashManagement.common.BusinessRules.buildRecapData({
                postURL: '../Inventory/api/InventoryCount/PostTransaction',
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

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepPhysicalCount');
        var current = plugin.getActiveRecord();

        if (current) {
            switch (combo.itemId) {
                case 'cboItem':
                    current.set('strItemDescription', records[0].get('strDescription'));
                    current.set('intCategoryId', records[0].get('intCategoryId'));
                    current.set('strCategory', records[0].get('strCategoryCode'));
                    current.set('strStorageLocationName', null);
                    current.set('intStorageLocationId', null);
                    current.set('strSubLocationName', null);
                    current.set('intSubLocationId', null);
                    current.set('dblSystemCount', null);
                    
                    if(current.get('strCountLine') === '' || current.get('strCountLine') === null)
                        {
                            var win = combo.up('window');
                            var currentItems = win.viewModel.data.current;
                            var countDetail = currentItems.tblICInventoryCountDetails().data.items;
                            var count = countDetail.length;

                            current.set('strCountLine', currentItems.get('strCountNo') + '-' + count);
                        }
                    break;
                case 'cboSubLocation':
                    current.set('strStorageLocationName', records[0].get('strStorageLocationName'));
                    current.set('intStorageLocationId', records[0].get('intStorageLocationId'));
                    current.set('dblSystemCount', records[0].get('dblOnHand'));
                    break;
                case 'cboStorageLocation':
                    current.set('strSubLocationName', records[0].get('strSubLocationName'));
                    current.set('intSubLocationId', records[0].get('intSubLocationId'));
                    current.set('dblSystemCount', records[0].get('dblOnHand'));
                    break;
                case 'cboLot':
                    current.set('strLotAlias', records[0].get('strLotAlias'));
                    current.set('dblSystemCount', records[0].get('dblOnHand'));
                    break;
            }
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

    init: function (application) {
        this.control({
            "#cboUOM": {
                select: this.onUOMSelect
            },
            "#cboCountGroup": {
                select: this.onCountGroupSelect
            },
            "#btnFetch": {
                click: this.onFetchClick
            },
            "#btnPrintCountSheets": {
                click: this.onPrintCountSheetsClick
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
            "#btnRecap": {
                click: this.onPostClick
            },
            "#cboItem": {
                select: this.onInventoryCountDetailSelect
            },
            "#cboSubLocation": {
                select: this.onInventoryCountDetailSelect
            },
            "#cboStorageLocation": {
                select: this.onInventoryCountDetailSelect
            },
            "#cboLot": {
                select: this.onInventoryCountDetailSelect
            },
            "#grdPhysicalCount": {
                cellclick: this.onGrdPhysicalClick
            }
        });
    }
});
