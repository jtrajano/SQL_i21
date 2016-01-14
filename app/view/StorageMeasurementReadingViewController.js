Ext.define('Inventory.view.StorageMeasurementReadingViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icstoragemeasurementreading',

    config: {
        searchConfig: {
            title:  'Search Storage Measurement Reading',
            type: 'Inventory.StorageMeasurementReading',
            api: {
                read: '../Inventory/api/StorageMeasurementReading/Search'
            },
            columns: [
                {dataIndex: 'intLocationId',text: 'Location', flex: 1, defaultSort:true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strLocationName',text: 'Location', flex: 1, dataType: 'string'},
                {dataIndex: 'dtmDate', text: 'Date', flex: 1,  dataType: 'datetime', xtype: 'datecolumn'},
                {dataIndex: 'strReadingNo', text: 'Reading No', flex: 1,  dataType: 'string'}
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
            ]
        },
        binding: {
            bind: {
                title: 'Storage Measurement Reading - {current.strReadingNo}'
            },
            cboLocation: {
                value: '{current.intLocationId}',
                store: '{location}'
            },
            dtmDate: '{current.dtmDate}',
            txtReadingNumber: '{current.strReadingNo}',

            grdStorageMeasurementReading: {
                colCommodity: {
                    dataIndex: 'strCommodity',
                    editor: {
                        origValueField: 'intCommodityId',
                        origUpdateField: 'intCommodityId',
                        store: '{commodity}'
                    }
                },
                colItem: {
                    dataIndex: 'strItemNo',
                    editor: {
                        origValueField: 'intItemId',
                        origUpdateField: 'intItemId',
                        store: '{item}',
                        defaultFilters: [
                            {
                                column: 'intLocationId',
                                value: '{current.intLocationId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'intCommodityId',
                                value: '{grdStorageMeasurementReading.selection.intCommodityId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colStorageLocation: {
                    dataIndex: 'strStorageLocationName',
                    editor: {
                        origValueField: 'intStorageLocationId',
                        origUpdateField: 'intStorageLocationId',
                        store: '{storageLocation}',
                        defaultFilters: [
                            {
                                column: 'intLocationId',
                                value: '{current.intLocationId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colSubLocation: 'strSubLocationName',
                colEffectiveDepth: 'dblEffectiveDepth',
                colAirSpaceReading: 'dblAirSpaceReading',
                colCashPrice: 'dblCashPrice'
            }
        }
    },

    setupContext : function(options){
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.StorageMeasurementReading', { pageSize: 1 });

        win.context = Ext.create('iRely.mvvm.Engine', {
            window : win,
            store  : store,
            include: 'tblICStorageMeasurementReadingConversions.vyuICGetStorageMeasurementReadingConversion',
            binding: me.config.binding,
            createRecord : me.createRecord,
            details: [
                {
                    key: 'tblICStorageMeasurementReadingConversions',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: win.down('#grdStorageMeasurementReading'),
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
                        column: 'intStorageMeasurementReadingId',
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
        var today = new i21.ModuleMgr.Inventory.getTodayDate();
        var record = Ext.create('Inventory.model.StorageMeasurementReading');
        record.set('dtmDate', today);
        action(record);
    },

    onStorageLocationSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var win = combo.up('window');
        var plugin = grid.getPlugin('cepStorageMeasurementReading');
        var current = plugin.getActiveRecord();

        current.set('intSubLocationId', records[0].get('intSubLocationId'));
        current.set('strSubLocationName', records[0].get('strSubLocationName'));
        current.set('dblEffectiveDepth', records[0].get('dblEffectiveDepth'));
    },

    onQualityClick: function(button, e, eOpts) {
        var grd = button.up('grid');

        var selected = grd.getSelectionModel().getSelection();

        if (selected) {
            if (selected.length > 0){
                var current = selected[0];
                if (!current.dummy)
                    iRely.Functions.openScreen('Grain.view.QualityTicketDiscount', { strSourceType: 'Storage Measurement Reading', intTicketFileId: current.get('intStorageMeasurementReadingConversionId') });
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

    init: function(application) {
        this.control({
            "#cboStorageLocation": {
                select: this.onStorageLocationSelect
            },
            "#btnQuality": {
                click: this.onQualityClick
            }
        });
    }
});
