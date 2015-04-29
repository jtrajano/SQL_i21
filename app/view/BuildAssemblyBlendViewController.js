Ext.define('Inventory.view.BuildAssemblyBlendViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icbuildassemblyblend',

    config: {
        searchConfig: {
            title: 'Search Build Assemblies',
            type: 'Inventory.BuildAssembly',
            api: {
                read: '../Inventory/api/BuildAssembly/SearchBuildAssemblies'
            },
            columns: [
                {dataIndex: 'intBuildAssemblyId', text: "Build Assembly Id", flex: 1, defaultSort: true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strBuildNo', text: 'Build No', flex: 1, dataType: 'string'},
                {dataIndex: 'dtmBuildDate', text: 'Build Date', flex: 1,  dataType: 'date', xtype: 'datecolumn'},
                {dataIndex: 'strItemNo', text: 'Item No', flex: 1, dataType: 'string'},
                {dataIndex: 'strLocationName', text: 'Location Name', flex: 1, dataType: 'string'},
                {dataIndex: 'strSubLocationName', text: 'Sub Location Name', flex: 1, dataType: 'string'},
                {dataIndex: 'strItemUOM', text: 'Item UOM', flex: 1, dataType: 'string'},
                {dataIndex: 'strDescription', text: 'Description', flex: 1, dataType: 'string'}
            ]
        },
        binding: {
            bind: {
                title: 'Build Assembly - {current.strBuildNo}'
            },
            dtmBuildDate: '{current.dtmBuildDate}',
            cboLocation: {
                value: '{current.intLocationId}',
                store: '{location}'
            },
            cboSubLocation: {
                value: '{current.intSubLocationId}',
                store: '{subLocation}',
                defaultFilters: [{
                    column: 'intCompanyLocationId',
                    value: '{current.intLocationId}',
                    conjunction: 'and'
                }]
            },
            cboItemNumber: {
                value: '{current.intItemId}',
                store: '{item}',
                defaultFilters: [{
                    column: 'intLocationId',
                    value: '{current.intLocationId}',
                    conjunction: 'and'
                }]
            },
            txtBuildQuantity: '{current.dblBuildQuantity}',
            cboUOM: {
                value: '{current.intItemUOMId}',
                store: '{itemUOM}',
                defaultFilters: [{
                    column: 'intItemId',
                    value: '{current.intItemId}',
                    conjunction: 'and'
                }]
            },
            txtBuildNumber: '{current.strBuildNo}',
            txtCost: '{current.dblCost}',
            txtDescription: '{current.strDescription}',

            grdBuildAssemblyBlend: {
                colItemNo: 'strItemNo',
                colDescription: 'strItemDescription',
                colSubLocation: {
                    dataIndex: 'strSubLocationName',
                    editor: {
                        store: '{stockUOM}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdBuildAssemblyBlend.selection.intItemId}',
                            conjunction: 'and'
                        },{
                            column: 'intLocationId',
                            value: '{current.intLocationId}',
                            conjunction: 'and'
                        },{
                            column: 'intItemUOMId',
                            value: '{grdBuildAssemblyBlend.selection.intItemUOMId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colStock: 'dblStock',
                colQuantity: 'dblQuantity',
                colUOM: 'strUnitMeasure',
                colCost: 'dblCost'
            }
        }
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.BuildAssembly', { pageSize: 1 });

        var grdBuildAssemblyBlend = win.down('#grdBuildAssemblyBlend');

        win.context = Ext.create('iRely.Engine', {
            window : win,
            store  : store,
            createRecord : me.createRecord,
            binding: me.config.binding,
            details: [
                {
                    key: 'tblICBuildAssemblyDetails',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdBuildAssemblyBlend,
                        deleteButton : win.down('#btnRemove'),
                        position: 'none'
                    })
                }
            ]
        });

        var colStock = grdBuildAssemblyBlend.columns[3];
        colStock.renderer = this.AvailableStockRenderer;

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
                win.controller.itemId = config.itemId;
                win.controller.itemSetup = config.itemSetup;
                context.data.addRecord();
            } else {
                if (config.id) {
                    config.filters = [{
                        column: 'intBuildAssemblyId',
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
        var record = Ext.create('Inventory.model.BuildAssembly');
        if (app.DefaultLocation > 0)
            record.set('intLocationId', app.DefaultLocation);
        record.set('dtmBuildDate', today);
        if (config.controller.itemId)
            record.set('intItemId', config.controller.itemId);
        if (config.controller.itemSetup) {
            Ext.Array.each(config.controller.itemSetup, function(row) {
                if (!row.dummy){
                    var newDetail = Ext.create('Inventory.model.BuildAssemblyDetail');
                    newDetail.set('intItemId', row.get('intAssemblyItemId'));
                    newDetail.set('strItemNo', row.get('strItemNo'));
                    newDetail.set('strItemDescription', row.get('strItemDescription'));
                    newDetail.set('intSubLocationId', null);
                    newDetail.set('dblQuantity', row.get('dblQuantity'));
                    newDetail.set('intItemUOMId', row.get('intItemUnitMeasureId'));
                    newDetail.set('strUnitMeasure', row.get('strUnitMeasure'));
                    newDetail.set('dblCost', row.get('dblCost'));
                    newDetail.set('intSort', row.get('intSort'));
                    record.tblICBuildAssemblyDetails().add(newDetail);
                }
            });
        }
        action(record);
    },

    onItemSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;
        var record = records[0];

        if (current) {
            var assemblyItem = record.data.tblICItemAssemblies;
            if (assemblyItem) {
                Ext.Array.each(assemblyItem, function(row) {
                    var newRecord = Ext.create('Inventory.model.BuildAssemblyDetail');
                    newRecord.set('intItemId', row.intAssemblyItemId);
                    newRecord.set('strItemNo', row.strItemNo);
                    newRecord.set('strItemDescription', row.strItemDescription);
                    newRecord.set('intSubLocationId', null);
                    newRecord.set('dblQuantity', row.dblQuantity);
                    newRecord.set('intItemUOMId', row.intItemUnitMeasureId);
                    newRecord.set('strUnitMeasure', row.strUnitMeasure);
                    newRecord.set('dblCost', row.dblCost);
                    newRecord.set('intSort', row.intSort);
                    current.tblICBuildAssemblyDetails().add(newRecord);
                });
            }
        }
    },

    onItemSubLocationSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();

        if (current) {
            current.set('intSubLocationId', records[0].get('intSubLocationId'));
            current.set('dblStock', records[0].get('dblOnHand'));
        }
    },

    AvailableStockRenderer: function (value, metadata, record) {
        var grid = metadata.column.up('grid');
        var win = grid.up('window');
        var items = win.viewModel.storeInfo.stockUOM;
        var currentMaster = win.viewModel.data.current;

        if (currentMaster) {
            if (record) {
                if (items) {
                    var index = items.data.findIndexBy(function (row) {
                        if (row.get('intItemId') === record.get('intItemId') &&
                            row.get('intLocationId') === currentMaster.get('intLocationId') &&
                            row.get('intItemUOMId') === record.get('intItemUOMId') &&
                            row.get('intSubLocationId') === record.get('intSubLocationId')) {
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

    init: function(application) {
        this.control({
            "#cboItemNumber" : {
                select: this.onItemSelect
            },
            "#cboItemSubLocation" : {
                select: this.onItemSubLocationSelect
            }
        });
    }
});
