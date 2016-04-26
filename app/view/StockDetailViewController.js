Ext.define('Inventory.view.StockDetailViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icstockdetail',

    config: {
        searchConfig: {
            title: 'Stock Details',
            url: '../Inventory/api/Item/GetItemStocks',
            columns: [
                { dataIndex: 'strItemNo', text: 'Item No', flex: 1, dataType: 'string', key: true, drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                { dataIndex: 'strDescription', text: 'Description', flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                { dataIndex: 'strType', text: 'Item Type', flex: 1, dataType: 'string' },
                { dataIndex: 'strCategoryCode', text: 'Category', flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewCategory' },
                { dataIndex: 'strLocationName', text: 'Location Name', flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewLocation' },
                { xtype: 'numbercolumn', summaryType: 'sum', dataIndex: 'dblUnitOnHand', text: 'On Hand', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', summaryType: 'sum', dataIndex: 'dblOnOrder', text: 'On Order', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', summaryType: 'sum', dataIndex: 'dblOrderCommitted', text: 'Committed', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', summaryType: 'sum', dataIndex: 'dblUnitReserved', text: 'Reserved', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', summaryType: 'sum', dataIndex: 'dblInTransitInbound', text: 'In Transit Inbound', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', summaryType: 'sum', dataIndex: 'dblInTransitOutbound', text: 'In Transit Outbound', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', summaryType: 'sum', dataIndex: 'dblUnitStorage', text: 'On Storage', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', summaryType: 'sum', dataIndex: 'dblConsignedPurchase', text: 'Consigned Purchase', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', summaryType: 'sum', dataIndex: 'dblConsignedSale', text: 'Consigned Sale', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', summaryType: 'sum', dataIndex: 'dblAvailable', text: 'Available', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', summaryType: 'sum', dataIndex: 'dblReorderPoint', text: 'Reorder Point', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', format: '#,##0.0000', dataIndex: 'dblLastCost', text: 'Last Cost', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', format: '#,##0.0000', dataIndex: 'dblAverageCost', text: 'Average Cost', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', format: '#,##0.0000', dataIndex: 'dblStandardCost', text: 'Standard Cost', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', dataIndex: 'dblSalePrice', text: 'Retail Price', flex: 1, dataType: 'float' }
            ],
            showNew: false,
            showOpenSelected: false,
            enableDblClick: false,

            searchConfig: [
                {
                    showNew: false,
                    showOpenSelected: false,
                    enableDblClick: false,
                    title: 'Storage Bins',
                    api: {
                        read: '../Inventory/api/StorageLocation/GetStorageBinDetails'
                    },
                    columns: [
                        { dataIndex: 'intItemId', text: 'Item Id', width: 100, flex: 1, hidden: true, key: true },
                        { dataIndex: 'intStorageLocationId', text: 'Storage Location Id', width: 100, flex: 1, hidden: true },
                        { dataIndex: 'intCompanyLocationId', text: 'Company Location Id', width: 100, flex: 1, hidden: true },
                        { dataIndex: 'intCompanyLocationSubLocationId', text: 'Company Sub Location Id', width: 100, flex: 1, hidden: true },
                        { dataIndex: 'intCommodityId', text: 'Commodity Id', width: 100, flex: 1, hidden: true },
                        { dataIndex: 'strItemNo', text: 'Item No', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                        { dataIndex: 'strItemDescription', text: 'Item Description', width: 100, flex: 1 },
                        { dataIndex: 'strLocation', text: 'Location', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewBinLocation' },
                        { dataIndex: 'strSubLocation', text: 'Sub Location', width: 100, flex: 1 },
                        { dataIndex: 'strStorageLocation', text: 'Storage Location', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewBinStorageLocation' },
                        { dataIndex: 'dblStock', text: 'Stock', xtype: 'numbercolumn', summaryType: 'sum', width: 100, flex: 1 },
                        { dataIndex: 'strUOM', text: 'UOM', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewBinUOM' },
                        { dataIndex: 'strCommodityCode', text: 'Commodity', width: 100, flex: 1, hidden: true },
                        { dataIndex: 'dblAvailable', xtype: 'numbercolumn', summaryType: 'sum', text: 'Space Available', width: 100, flex: 1 },
                        { dataIndex: 'dblEffectiveDepth', xtype: 'numbercolumn', summaryType: 'sum', text: 'Effective Depth', width: 100, flex: 1, hidden: true }
                    ],
                    buttons: [
                        {
                            text: 'Measurement Reading',
                            clickHandler: 'onViewMeasurementReading',
                            width: 50,
                            height: 57,
                            iconCls: 'large-document-view'
                        }
                    ],
                    chart: {
                        url: '../Inventory/api/StorageLocation/GetStorageBins',
                        valueAxes: [
                            {
                                id: 'axis',
                                position: 'left',
                                title: 'Stock',
                                stackType: "regular"
                            }
                        ],
                        graphs: [
                            {
                                balloonText: "[[title]] of [[category]]:[[value]]",
                                type: 'column',
                                title: 'Stock',
                                valueField: 'dblStock',
                                valueAxis: 'axis',
                                topRadius: 1,
                                fillAlphas: 0.8,
                                fillColors: "#FCD202",
                                lineAlpha: 0.5,
                                lineColor: "#FFFFFF",
                                lineThickness: 1
                            },
                            {
                                balloonText: "[[title]] storage for [[category]]:[[value]]",
                                type: 'column',
                                title: 'Available',
                                valueField: 'dblAvailable',
                                valueAxis: 'axis',
                                topRadius: 1,
                                fillAlphas: 0.7,
                                fillColors: "#cdcdcd",
                                lineAlpha: 0.5,
                                lineColor: "#cdcdcd",
                                lineThickness: 1
                            }
                        ],
                        legend: {
                            enabled: true,
                            useGraphSettings: true
                        },
                        angle: 30,
                        depth3D: 30,
                        categoryAxis: {
                            title: 'Storage Location',
                            labelRotation: 45
                        },
                        categoryField: 'strStorageLocation'
                    }
                }
            ]
        }
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
            Ext.create('iRely.mvvm.Engine', {
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
