Ext.define('Inventory.view.StockDetailViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icstockdetail',
    require: [
        //'Inventory.custom.ux.grid.SubTable',
        'Inventory.view.BinVisualization'
    ],
    config: {
        searchConfig: {
            mainTitle: 'Stock Details',
            title: 'Locations YTD',
            url: '../Inventory/api/Item/GetItemStocks',
            groupedOnLoad: true,
            columns: [
                { dataIndex: 'strItemNo', text: 'Item No', flex: 1, dataType: 'string', key: true, drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                { dataIndex: 'strDescription', text: 'Description', flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                { dataIndex: 'strType', text: 'Item Type', flex: 1, dataType: 'string' },
                { dataIndex: 'strCommodityCode', text: 'Commodity', flex: 1, dataType: 'string' },
                { dataIndex: 'strCategoryCode', text: 'Category', flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewCategory' },
                { dataIndex: 'strLocationName', text: 'Location', groupBy: true, flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewLocation' },
                { dataIndex: 'strSubLocationName', text: 'Storage Location', flex: 1, dataType: 'string' },
                { dataIndex: 'strStorageLocationName', text: 'Storage Unit', flex: 1, dataType: 'string' },
                { dataIndex: 'strStockUOM', text: 'Stock UOM', flex: 1, dataType: 'string', drillDownText: 'View UOM', drillDownClick: 'onViewUOM'},
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblUnitOnHand', text: 'On Hand', flex: 1, dataType: 'float', renderer: function(value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblOnOrder', text: 'On Order', flex: 1, dataType: 'float', renderer: function(value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblOrderCommitted', text: 'Committed', flex: 1, dataType: 'float', renderer: function(value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblUnitReserved', text: 'Reserved', flex: 1, dataType: 'float', renderer: function(value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblInTransitInbound', text: 'In Transit Inbound', flex: 1, dataType: 'float', renderer: function(value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblInTransitOutbound', text: 'In Transit Outbound', flex: 1, dataType: 'float', renderer: function(value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblUnitStorage', text: 'On Storage', flex: 1, dataType: 'float', renderer: function(value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblConsignedPurchase', text: 'Consigned Purchase', flex: 1, dataType: 'float', renderer: function(value) { return Ext.util.Format.usMoney(value); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblConsignedSale', text: 'Consigned Sale', flex: 1, dataType: 'float', renderer: function(value) { return Ext.util.Format.usMoney(value); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblAvailable', text: 'Available', flex: 1, dataType: 'float', renderer: function(value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblReorderPoint', text: 'Reorder Point', flex: 1, dataType: 'float', renderer: function(value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblLastCost', text: 'Last Cost', flex: 1, dataType: 'float', renderer: function(value) { return Ext.util.Format.number(value, '$#,##0.000000##'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblAverageCost', text: 'Average Cost', flex: 1, dataType: 'float', renderer: function(value) { return Ext.util.Format.number(value, '$#,##0.000000##'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblStandardCost', text: 'Standard Cost', flex: 1, dataType: 'float', renderer: function(value) { return Ext.util.Format.number(value, '$#,##0.000000##'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblSalePrice', text: 'Retail Price', flex: 1, dataType: 'float', renderer: function(value) { return Ext.util.Format.usMoney(value); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblExtendedCost', text: 'Extended Cost', flex: 1, dataType: 'float', renderer: function(value) { return Ext.util.Format.usMoney(value); } },
            ],
            showNew: false,
            showOpenSelected: false,
            enableDblClick: false,

            searchConfig: [
                {
                    showNew: false,
                    showOpenSelected: false,
                    enableDblClick: false,
                    title: 'Storage Locations YTD',
                    api: {
                        read: '../Inventory/api/StorageLocation/GetSubLocationBinDetails'
                    },
                    columns: [
                        { dataIndex: 'intItemId', text: 'Item Id', width: 100, flex: 1, hidden: true, key: true },
                        { dataIndex: 'intStorageLocationId', text: 'Storage Location Id', width: 100, flex: 1, hidden: true },
                        { dataIndex: 'intCompanyLocationId', text: 'Company Location Id', width: 100, flex: 1, hidden: true },
                        /*{ dataIndex: 'intCompanyLocationSubLocationId', text: 'Company Sub Location Id', width: 100, flex: 1, hidden: true },*/
                        /*{ dataIndex: 'intCommodityId', text: 'Commodity Id', width: 100, flex: 1, hidden: true },*/
                        { dataIndex: 'strCommodityCode', text: 'Commodity', width: 100, flex: 1, hidden: false },
                        { dataIndex: 'strItemNo', text: 'Item No', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                        { dataIndex: 'strItemDescription', text: 'Item Description', width: 100, flex: 1 },
                        { dataIndex: 'strLocation', text: 'Location', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewBinLocation' },
                        { dataIndex: 'strSubLocationName', text: 'Storage Location', width: 100, flex: 1 },
                        { dataIndex: 'strStorageLocation', text: 'Storage Unit', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewBinStorageLocation' },
                        { dataIndex: 'dblStock', text: 'Stock', xtype: 'numbercolumn', summaryType: 'sum', width: 100, flex: 1 },
                        { dataIndex: 'dblAirSpaceReading',  xtype: 'numbercolumn', text: 'Air Space Reading', width: 100, flex: 1, summaryType: 'sum' },
                        { dataIndex: 'dblPhysicalReading',  xtype: 'numbercolumn', text: 'Physical Reading', width: 100, flex: 1, summaryType: 'sum' },
                        { dataIndex: 'dblStockVariance',  xtype: 'numbercolumn', text: 'Stock Variance', width: 100, flex: 1, summaryType: 'sum' },
                        { dataIndex: 'strUOM', text: 'UOM', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewBinUOM' },
                        { dataIndex: 'dtmReadingDate', xtype: 'datecolumn', dataType: 'date', text: 'Reading Date', width: 100, flex: 1, hidden: false },
                        { dataIndex: 'dblCapacity',  xtype: 'numbercolumn', text: 'Capacity', width: 100, flex: 1, summaryType: 'sum' },
                        { dataIndex: 'dblAvailable', xtype: 'numbercolumn', summaryType: 'sum', text: 'Space Available', width: 100, flex: 1 },
                        { dataIndex: 'dblEffectiveDepth', xtype: 'numbercolumn', summaryType: 'sum', text: 'Effective Depth', width: 100, flex: 1, hidden: true },
                        { dataIndex: 'dblPackFactor', xtype: 'numbercolumn', summaryType: 'sum', text: 'Pack Factor', width: 100, flex: 1, hidden: true },
                        { dataIndex: 'dblUnitPerFoot', xtype: 'numbercolumn', summaryType: 'sum', text: 'Unit Per Foot', width: 100, flex: 1, hidden: true },
                        { dataIndex: 'strDiscountCode', text: 'Discount Schedule Id', width: 100, flex: 1, drillDownText: 'Discount Codes', drillDownClick: 'onViewDiscountCodes' },
                        { dataIndex: 'strDiscountDescription', text: 'Discount Schedule', width: 100, flex: 1, drillDownText: 'Discount Codes', drillDownClick: 'onViewDiscountCodes' },
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
                        url: '../Inventory/api/StorageLocation/GetSubLocationBins',
                        type: 'serial',
                        /*startDuration: 1,
                        startEffect: 'elastic',*/
                        mouseWheelZoomEnabled: true,
                        mouseWheelScrollEnabled: true,
                        valueAxes: [
                            {
                                id: 'axis',
                                position: 'left',
                                title: 'Stock',
                                stackType: "100%"
                            }
                        ],
                        graphs: [
                            {
                                id: 'stockGraph',
                                balloonText: "[[title]] of [[category]]:[[value]]",
                                type: 'column',
                                title: 'Stock',
                                valueField: 'dblStock',
                                valueAxis: 'axis',
                                topRadius: 1,
                                fillAlphas: 0.8,
                                fillColors: "#FCD202",
                                //fillColorsField: "strColor",
                                //alphaField: "strLocation",
                                //labelText: '[[value]]',
                                lineAlpha: 0.5,
                                lineColor: "#FFFFFF",
                                lineThickness: 1
                            },
                            {
                                id: 'spaceGraph',
                                balloonText: "[[title]] storage for [[category]]:[[value]]",
                                type: 'column',
                                title: 'Available',
                                valueField: 'dblAvailable',
                                //labelText: '[[value]]',
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
                            useGraphSettings: true,
                            position: 'right'
                        },
                        autoMarginOffset: 24,
                        angle: 30,
                        depth3D: 30,
                        categoryAxis: {
                            title: 'Storage Location',
                            labelRotation: 45,
                            //labelColorField: 'strColor',
                            boldLabels: false,
                            /*type: 'serial',*/
                            gridPosition: 'start'
                        },
                        categoryField: 'strSubLocation',
                        listeners: [
                            {
                                //event: 'clickGraphItem',
                                method: function(event) {
                                    var containerChart = iRely.Functions.getComponentByQuery('#searchTabPanel');

                                    var tab = containerChart.getActiveTab();
                                    var gridTab = tab.down('grid');

                                    var gridStore = Ext.create('Ext.data.Store', {
                                        fields: [
                                            { name: 'intSubLocationId', type: 'int' },
                                            { name: 'strLocation', type: 'string' },
                                            { name: 'strSubLocation', type: 'string' }
                                        ],
                                        autoLoad: true,
                                        proxy: {
                                            type: 'rest',
                                            api: {
                                                read: '../Inventory/api/StorageLocation/GetSubLocationBinDetails'
                                            },
                                            reader: {
                                                type: 'json',
                                                rootProperty: 'data',
                                                messageProperty: 'message'
                                            },
                                            writer: {
                                                type: 'json',
                                                allowSingle: false
                                            }
                                        },
                                    });

                                    var discountSchedules = Ext.create('Ext.data.Store', {
                                        fields: [
                                            { name: 'intStorageLocationId', type: 'int' },
                                            { name: 'strLocation', type: 'string' },
                                            { name: 'strStorageLocation', type: 'string' }
                                        ],
                                        autoLoad: true,
                                        proxy: {
                                            type: 'rest',
                                            api: {
                                                read: '../Inventory/api/StorageLocation/GetStorageBins'
                                            },
                                            reader: {
                                                type: 'json',
                                                rootProperty: 'data',
                                                messageProperty: 'message'
                                            },
                                            writer: {
                                                type: 'json',
                                                allowSingle: false
                                            }
                                        },
                                    });

                                    var plugin = Ext.create('Inventory.custom.ux.grid.SubTable', {
                                        headerWidth: 24,
                                        columns: [{
                                            text: 'Discount Code',
                                            dataIndex: 'strStorageLocation',
                                            width: 100
                                        }, {
                                            width: 100,
                                            text: 'Reading',
                                            dataIndex: 'strLocation'
                                        }],
                                        getAssociatedRecords: function(record) {
                                            var result = Ext.Array.filter(
                                                discountSchedules.data.items,
                                                function(r) { return 1 == 1 }
                                            );
                                            return result;
                                        }
                                    });

                                    var grid = Ext.create('GlobalComponentEngine.view.AdvanceSearchGrid', {
                                        collapsible: true,
                                        maximizable: false,
                                        split: true,
                                        store: gridStore,
                                        columns: [
                                            { dataIndex: 'intItemId', text: 'Item Id', width: 100, flex: 1, hidden: true, key: true },
                                            { dataIndex: 'intStorageLocationId', text: 'Storage Location Id', width: 100, flex: 1, hidden: true },
                                            { dataIndex: 'intCompanyLocationId', text: 'Company Location Id', width: 100, flex: 1, hidden: true },
                                            /*{ dataIndex: 'intCompanyLocationSubLocationId', text: 'Company Sub Location Id', width: 100, flex: 1, hidden: true },*/
                                            /*{ dataIndex: 'intCommodityId', text: 'Commodity Id', width: 100, flex: 1, hidden: true },*/
                                            { dataIndex: 'strItemNo', text: 'Item No', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                                            { dataIndex: 'strItemDescription', text: 'Item Description', width: 100, flex: 1 },
                                            { dataIndex: 'strLocation', text: 'Location', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewBinLocation' },
                                            /*{ dataIndex: 'strSubLocation', text: 'Sub Location', width: 100, flex: 1 },*/
                                            { dataIndex: 'strStorageLocation', text: 'Storage Location', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewBinStorageLocation' },
                                            { dataIndex: 'dblStock', text: 'Stock', xtype: 'numbercolumn', summaryType: 'sum', width: 100, flex: 1 },
                                            { dataIndex: 'strUOM', text: 'UOM', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewBinUOM' },
                                            { dataIndex: 'dblCapacity',  xtype: 'numbercolumn', text: 'Capacity', width: 100, flex: 1, summaryType: 'sum' },
                                            { dataIndex: 'dblAvailable', xtype: 'numbercolumn', summaryType: 'sum', text: 'Space Available', width: 100, flex: 1 },
                                            { dataIndex: 'dblEffectiveDepth', xtype: 'numbercolumn', summaryType: 'sum', text: 'Effective Depth', width: 100, flex: 1, hidden: true },
                                            { dataIndex: 'dblPackFactor', xtype: 'numbercolumn', summaryType: 'sum', text: 'Pack Factor', width: 100, flex: 1, hidden: true },
                                            { dataIndex: 'dblUnitPerFoot', xtype: 'numbercolumn', summaryType: 'sum', text: 'Unit Per Foot', width: 100, flex: 1, hidden: true }
                                        ],
                                        plugins: [
                                            {
                                                ptype: 'subtable',
                                                headerWidth: 24,
                                                columns: [{
                                                    text: 'Discount Code',
                                                    dataIndex: 'strStorageLocation',
                                                    width: 100
                                                }, {
                                                    width: 100,
                                                    text: 'Reading',
                                                    dataIndex: 'strLocation'
                                                }],
                                                getAssociatedRecords: function(record) {
                                                    var result = Ext.Array.filter(
                                                        discountSchedules.data.items,
                                                        function(r) { return 1 == 1 }
                                                    );
                                                    return result;
                                                }
                                            }
                                        ]
                                    });

                                    event.chart.events.clickGraphItem = [];
                                    event.chart.addListener("clickGraphItem", Ext.bind(function(event) {
                                        alert(this.grid);
                                    }, { grid: grid }));
                                }
                            }
                        ]
                    }
                },
                {
                    showNew: false,
                    showOpenSelected: false,
                    enableDblClick: false,
                    title: 'Storage Units YTD',
                    api: {
                        read: '../Inventory/api/StorageLocation/GetStorageBinDetails'
                    },
                    columns: [
                        { dataIndex: 'intItemId', text: 'Item Id', width: 100, flex: 1, hidden: true, key: true },
                        { dataIndex: 'intStorageLocationId', text: 'Storage Location Id', width: 100, flex: 1, hidden: true },
                        { dataIndex: 'intCompanyLocationId', text: 'Company Location Id', width: 100, flex: 1, hidden: true },
                        /*{ dataIndex: 'intCommodityId', text: 'Commodity Id', width: 100, flex: 1, hidden: true },*/
                        { dataIndex: 'strCommodityCode', text: 'Commodity', width: 100, flex: 1, hidden: false },
                        { dataIndex: 'strItemNo', text: 'Item No', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                        { dataIndex: 'strItemDescription', text: 'Item Description', width: 100, flex: 1 },
                        { dataIndex: 'strLocation', text: 'Location', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewBinLocation' },
                        { dataIndex: 'intSubLocationId', text: 'Storage Location Id', width: 100, flex: 1, hidden: true },
                        { dataIndex: 'strSubLocationName', text: 'Storage Location', width: 100, flex: 1 },
                        { dataIndex: 'strStorageLocation', text: 'Storage Unit', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewBinStorageLocation' },
                        { dataIndex: 'dblStock', text: 'Stock', xtype: 'numbercolumn', summaryType: 'sum', width: 100, flex: 1 },
                        { dataIndex: 'dblAirSpaceReading',  xtype: 'numbercolumn', text: 'Air Space Reading', width: 100, flex: 1, summaryType: 'sum' },
                        { dataIndex: 'dblPhysicalReading',  xtype: 'numbercolumn', text: 'Physical Reading', width: 100, flex: 1, summaryType: 'sum' },
                        { dataIndex: 'dblStockVariance',  xtype: 'numbercolumn', text: 'Stock Variance', width: 100, flex: 1, summaryType: 'sum' },
                        { dataIndex: 'strUOM', text: 'UOM', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewBinUOM' },
                        { dataIndex: 'dtmReadingDate', xtype: 'datecolumn', dataType: 'date', text: 'Reading Date', width: 100, flex: 1, hidden: false },
                        { dataIndex: 'dblCapacity',  xtype: 'numbercolumn', text: 'Capacity', width: 100, flex: 1, summaryType: 'sum' },
                        { dataIndex: 'dblAvailable', xtype: 'numbercolumn', summaryType: 'sum', text: 'Space Available', width: 100, flex: 1 },
                        { dataIndex: 'dblEffectiveDepth', xtype: 'numbercolumn', summaryType: 'sum', text: 'Effective Depth', width: 100, flex: 1, hidden: true },
                        { dataIndex: 'dblPackFactor', xtype: 'numbercolumn', summaryType: 'sum', text: 'Pack Factor', width: 100, flex: 1, hidden: true },
                        { dataIndex: 'dblUnitPerFoot', xtype: 'numbercolumn', summaryType: 'sum', text: 'Unit Per Foot', width: 100, flex: 1, hidden: true },
                        { dataIndex: 'strDiscountCode', text: 'Discount Schedule Id', width: 100, flex: 1, drillDownText: 'Discount Codes', drillDownClick: 'onViewDiscountCodes' },
                        { dataIndex: 'strDiscountDescription', text: 'Discount Schedule', width: 100, flex: 1, drillDownText: 'Discount Codes', drillDownClick: 'onViewDiscountCodes' },
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
                        type: 'serial',
                        /*startDuration: 1,
                        startEffect: 'elastic',*/
                        mouseWheelZoomEnabled: true,
                        mouseWheelScrollEnabled: true,
                        valueAxes: [
                            {
                                id: 'axis',
                                position: 'left',
                                title: 'Stock',
                                stackType: "100%"
                            }
                        ],
                        graphs: [
                            {
                                id: 'stockGraph',
                                balloonText: "[[title]] of [[category]]:[[value]]",
                                type: 'column',
                                title: 'Stock',
                                valueField: 'dblStock',
                                valueAxis: 'axis',
                                topRadius: 1,
                                fillAlphas: 0.8,
                                fillColors: "#FCD202",
                                //fillColorsField: "strColor",
                                //alphaField: "strLocation",
                                //labelText: '[[value]]',
                                lineAlpha: 0.5,
                                lineColor: "#FFFFFF",
                                lineThickness: 1
                            },
                            {
                                id: 'spaceGraph',
                                balloonText: "[[title]] storage for [[category]]:[[value]]",
                                type: 'column',
                                title: 'Available',
                                valueField: 'dblAvailable',
                                //labelText: '[[value]]',
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
                            useGraphSettings: true,
                            position: 'right'
                        },
                        autoMarginOffset: 24,
                        angle: 30,
                        depth3D: 30,
                        categoryAxis: {
                            title: 'Storage Unit',
                            labelRotation: 45,
                            //labelColorField: 'strColor',
                            boldLabels: false,
                            /*type: 'serial',*/
                            gridPosition: 'start'
                        },
                        categoryField: 'strStorageLocation',
                        listeners: [
                            {
                                //event: 'clickGraphItem',
                                method: function(event) {
                                    var containerChart = iRely.Functions.getComponentByQuery('#searchTabPanel');

                                    var tab = containerChart.getActiveTab();
                                    var gridTab = tab.down('grid');

                                    var gridStore = Ext.create('Ext.data.Store', {
                                        fields: [
                                            { name: 'intStorageLocationId', type: 'int' },
                                            { name: 'strLocation', type: 'string' },
                                            { name: 'strStorageLocation', type: 'string' }
                                        ],
                                        autoLoad: true,
                                        proxy: {
                                            type: 'rest',
                                            api: {
                                                read: '../Inventory/api/StorageLocation/GetStorageBinDetails'
                                            },
                                            reader: {
                                                type: 'json',
                                                rootProperty: 'data',
                                                messageProperty: 'message'
                                            },
                                            writer: {
                                                type: 'json',
                                                allowSingle: false
                                            }
                                        },
                                    });

                                    var discountSchedules = Ext.create('Ext.data.Store', {
                                        fields: [
                                            { name: 'intStorageLocationId', type: 'int' },
                                            { name: 'strLocation', type: 'string' },
                                            { name: 'strStorageLocation', type: 'string' }
                                        ],
                                        autoLoad: true,
                                        proxy: {
                                            type: 'rest',
                                            api: {
                                                read: '../Inventory/api/StorageLocation/GetStorageBins'
                                            },
                                            reader: {
                                                type: 'json',
                                                rootProperty: 'data',
                                                messageProperty: 'message'
                                            },
                                            writer: {
                                                type: 'json',
                                                allowSingle: false
                                            }
                                        },
                                    });

                                    var plugin = Ext.create('Inventory.custom.ux.grid.SubTable', {
                                        headerWidth: 24,
                                        columns: [{
                                            text: 'Discount Code',
                                            dataIndex: 'strStorageLocation',
                                            width: 100
                                        }, {
                                            width: 100,
                                            text: 'Reading',
                                            dataIndex: 'strLocation'
                                        }],
                                        getAssociatedRecords: function(record) {
                                            var result = Ext.Array.filter(
                                                discountSchedules.data.items,
                                                function(r) { return 1 == 1 }
                                            );
                                            return result;
                                        }
                                    });

                                    var grid = Ext.create('GlobalComponentEngine.view.AdvanceSearchGrid', {
                                        collapsible: true,
                                        maximizable: false,
                                        split: true,
                                        store: gridStore,
                                        columns: [
                                            { dataIndex: 'intItemId', text: 'Item Id', width: 100, flex: 1, hidden: true, key: true },
                                            { dataIndex: 'intStorageLocationId', text: 'Storage Location Id', width: 100, flex: 1, hidden: true },
                                            { dataIndex: 'intCompanyLocationId', text: 'Company Location Id', width: 100, flex: 1, hidden: true },
                                            /*{ dataIndex: 'intCompanyLocationSubLocationId', text: 'Company Sub Location Id', width: 100, flex: 1, hidden: true },*/
                                            /*{ dataIndex: 'intCommodityId', text: 'Commodity Id', width: 100, flex: 1, hidden: true },*/
                                            { dataIndex: 'strItemNo', text: 'Item No', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                                            { dataIndex: 'strItemDescription', text: 'Item Description', width: 100, flex: 1 },
                                            { dataIndex: 'strLocation', text: 'Location', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewBinLocation' },
                                            /*{ dataIndex: 'strSubLocation', text: 'Sub Location', width: 100, flex: 1 },*/
                                            { dataIndex: 'strStorageLocation', text: 'Storage Location', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewBinStorageLocation' },
                                            { dataIndex: 'dblStock', text: 'Stock', xtype: 'numbercolumn', summaryType: 'sum', width: 100, flex: 1 },
                                            { dataIndex: 'strUOM', text: 'UOM', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewBinUOM' },
                                            { dataIndex: 'dblCapacity',  xtype: 'numbercolumn', text: 'Capacity', width: 100, flex: 1, summaryType: 'sum' },
                                            { dataIndex: 'dblAvailable', xtype: 'numbercolumn', summaryType: 'sum', text: 'Space Available', width: 100, flex: 1 },
                                            { dataIndex: 'dblEffectiveDepth', xtype: 'numbercolumn', summaryType: 'sum', text: 'Effective Depth', width: 100, flex: 1, hidden: true },
                                            { dataIndex: 'dblPackFactor', xtype: 'numbercolumn', summaryType: 'sum', text: 'Pack Factor', width: 100, flex: 1, hidden: true },
                                            { dataIndex: 'dblUnitPerFoot', xtype: 'numbercolumn', summaryType: 'sum', text: 'Unit Per Foot', width: 100, flex: 1, hidden: true }
                                        ],
                                        plugins: [
                                            {
                                                ptype: 'subtable',
                                                headerWidth: 24,
                                                columns: [{
                                                    text: 'Discount Code',
                                                    dataIndex: 'strStorageLocation',
                                                    width: 100
                                                }, {
                                                    width: 100,
                                                    text: 'Reading',
                                                    dataIndex: 'strLocation'
                                                }],
                                                getAssociatedRecords: function(record) {
                                                    var result = Ext.Array.filter(
                                                        discountSchedules.data.items,
                                                        function(r) { return 1 == 1 }
                                                    );
                                                    return result;
                                                }
                                            }
                                        ]
                                    });

                                    event.chart.events.clickGraphItem = [];
                                    event.chart.addListener("clickGraphItem", Ext.bind(function(event) {
                                        alert(this.grid);
                                    }, { grid: grid }));
                                }
                            }
                        ]
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