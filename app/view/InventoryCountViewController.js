Ext.define('Inventory.view.InventoryCountViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icinventorycount',

    config: {
        searchConfig: {
            title: 'Search InventoryCount',
            type: 'Inventory.InventoryCount',
            api: {
                read: '../Inventory/api/InventoryCount/Search'
            },
            columns: [
                {dataIndex: 'intInventoryCountId', text: "Count Id", flex: 1, defaultSort: true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strCountNo', text: 'Count No', flex: 1, dataType: 'string'},
                {dataIndex: 'strLocationName', text: 'Location', flex: 1, dataType: 'string'},
                {dataIndex: 'strCategory', text: 'Category', flex: 1, dataType: 'string'},
                {dataIndex: 'strCommodity', text: 'Commodity', flex: 1, dataType: 'string'},
                {dataIndex: 'strCountGroup', text: 'Count Group', flex: 1, dataType: 'string'},
                {dataIndex: 'dtmCountDate', text: 'Count Date', flex: 1, dataType: 'date', xtype: 'datecolumn'},
                {dataIndex: 'strSubLocationName', text: 'Sub Location', flex: 1, dataType: 'string'},
                {dataIndex: 'strStorageLocationName', text: 'Storage Location', flex: 1, dataType: 'string'},
                {dataIndex: 'strStatus', text: 'Status', flex: 1, dataType: 'string'}
            ]
        },
        binding: {
            bind: {
                title: 'InventoryCount - {current.strCountNo}'
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
                defaultFilters: [{
                    column: 'intCompanyLocationId',
                    value: '{current.intLocationId}',
                    conjunction: 'and'
                },{
                    column: 'strClassification',
                    value: 'Inventory',
                    conjunction: 'and'
                }]
            },
            cboStorageLocation: {
                value: '{current.intStorageLocationId}',
                store: '{storageLocation}',
                defaultFilters: [{
                    column: 'intLocationId',
                    value: '{current.intLocationId}',
                    conjunction: 'and'
                },{
                    column: 'intSubLocationId',
                    value: '{current.intSubLocationId}',
                    conjunction: 'and'
                }]
            },
            txtDescription: '{current.strDescription}',

            chkIncludeZeroOnHand: '{current.ysnIncludeZeroOnHand}',
            chkIncludeOnHand: '{current.ysnIncludeOnHand}',
            chkScannedCountEntry: '{current.ysnScannedCountEntry}',
            chkCountByLots: '{current.ysnCountByLots}',
            chkCountByPallets: '{current.ysnCountByPallets}',
            chkRecountMismatch: '{current.ysnRecountMismatch}',
            chkExternal: '{current.ysnExternal}',
            chkRecount: '{current.ysnRecount}',

            txtReferenceCountNo: '{current.intRecountReferenceId}',
            cboStatus: {
                value: '{current.intStatus}',
                store: '{status}'
            },

            grdPhysicalCount: {
                colItem: 'strItemNo',
                colDescription: 'strItemDescription',
                colCategory: 'strCategory',
                colSubLocation: 'strSubLocationName',
                colStorageLocation: 'strStorageLocationName',
                colLotNo: 'strLotNumber',
                colLotAlias: 'strLotAlias',
                colSystemCount: 'dblSystemCount',
                colLastCost: 'dblLastCost',
                colCountLineNo: 'strCountLine',
                colNoPallets: 'dblPallets',
                colQtyPerPallet: 'dblQtyPerPallet',
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

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.InventoryCount', { pageSize: 1 });

        win.context = Ext.create('iRely.mvvm.Engine', {
            window : win,
            store  : store,
            include: 'tblICInventoryCountDetails.vyuICGetInventoryCountDetail',
            createRecord : me.createRecord,
            binding: me.config.binding,
            details: [
                {
                    key: 'tblICInventoryCountDetails',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: win.down('#grdPhysicalCount'),
                        deleteButton : win.down('#btnRemove')
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
                        column: 'intInventoryCountId',
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
        var record = Ext.create('Inventory.model.InventoryCount');

        record.set('dtmCountDate', today);
        record.set('intStatus', 1);
        if (app.DefaultLocation > 0)
            record.set('intLocationId', app.DefaultLocation);

        action(record);
    },

    onCountGroupSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) {
//            current.set('ysnIncludeZeroOnHand', records[0].get('ysnIncludeZeroOnHand'));
            current.set('ysnIncludeOnHand', records[0].get('ysnIncludeOnHand'));
            current.set('ysnScannedCountEntry', records[0].get('ysnScannedCountEntry'));
            current.set('ysnCountByLots', records[0].get('ysnCountByLots'));
            current.set('ysnCountByPallets', records[0].get('ysnCountByPallets'));
            current.set('ysnRecountMismatch', records[0].get('ysnRecountMismatch'));
            current.set('ysnExternal', records[0].get('ysnExternal'));
        }
    },

    init: function(application) {
        this.control({
            "#cboUOM": {
                select: this.onUOMSelect
            },
            "#cboCountGroup": {
                select: this.onCountGroupSelect
            }
        });
    }
});
