Ext.define('Inventory.view.StockDetailViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icstockdetail',
    require: [
        //'Inventory.custom.ux.grid.SubTable',
        'Inventory.view.BinVisualization'
    ],
    config: {
    },

    show: function(config){
        var me = this,
            win = this.getView();
        this.ownerWindow = win;
        if (config && config.action) {
            win.showNew = false;
            win.modal = (!config.param || !config.param.modalMode) ? false : config.param.modalMode;
            win.show();

            var context = me.setupContext({ window: win});

            switch(config.action) {
                case 'view':
                    context.data.load({
                        filters: config.filters
                    });
                    break;
            }
        }
    },

    setupContext: function(options){
        var me = this,
            win = options.window;

        var context =
            Ext.create('iRely.Engine', {
                window : win,
                store  : Ext.create('Inventory.store.BufferedItemStockView'),
                binding: me.config.binding,
                showNew: false
            });

        win.context = context;
        return context;
    },

    onViewCategory: function (value, record) {
        var locationName = record.get('strCategoryCode');
        i21.ModuleMgr.Inventory.showScreen(locationName, 'Category');
    },

    onViewLocation: function (value, record) {
        var locationName = record.get('strLocationName');
        i21.ModuleMgr.Inventory.showScreen(locationName, 'LocationName');
    },

    onViewItem: function (value, record) {
        var itemNo = record.get('strItemNo');
        i21.ModuleMgr.Inventory.showScreen(itemNo, 'ItemNo');
    },

    onViewBinLocation: function (value, record) {
        var locationName = record.get('strLocation');
        i21.ModuleMgr.Inventory.showScreen(locationName, 'LocationName');
    },

    onViewBinStorageLocation: function(value, record) {
        var locationName = record.get('strStorageLocation');
        i21.ModuleMgr.Inventory.showScreen(locationName, 'StorageLocation');
    },

    onViewBinUOM: function(value, record) {
        var locationName = record.get('strUOM');
        i21.ModuleMgr.Inventory.showScreen(locationName, 'UOM');
    },

    onViewDiscountCodes: function(value, record) {
        iRely.Functions.openScreen('Grain.view.QualityTicketDiscount', {
            strSourceType: 'Storage Measurement Reading',
            intTicketFileId: record.get('intStorageMeasurementReadingConversionId')
        });
    },

    onViewUOM: function(value, record) {
        var uom = record.get('strStockUOM');
        i21.ModuleMgr.Inventory.showScreen(uom, 'UOM');
    },

    onViewMeasurementReading: function(button, e, opts) {
        "use strict";
        var today = new i21.ModuleMgr.Inventory.getTodayDate();
        var grid = Ext.ComponentQuery.query("#grdSearch")[2];
        if (grid.getStore().data.first == null || grid.getStore().data.first == 'undefined') {
            iRely.Functions.showErrorDialog('Please select an item from the graph to load measurement reading.');
            return;
        }

        var locationId = grid.getStore().data.first.value[0].data.intCompanyLocationId;
        var storageLocationId = grid.getStore().data.first.value[0].data.intStorageLocationId;

        var record = Ext.create('Inventory.model.StorageMeasurementReading');
        record.set('dtmDate', today);
        record.set("intLocationId", locationId);

        var screenName = 'Inventory.view.StorageMeasurementReading',
            action = 'new';

        if (screenName != '') {
            iRely.Functions.openScreen(screenName, {
                modalMode: true,
                action: action,
                mustLoadRecordParams: true,
                record: record,
                intStorageLocationId: storageLocationId//,
                //details: grid.getStore().data.first
            });
        }
    }
});