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

            var context = win.context ? win.context.initialize() : me.setupContext();

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
            win = me.getView();

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