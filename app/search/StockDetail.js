Ext.define('Inventory.search.StockDetail', {
    alias: 'search.icstockdetail',
    singleton: true,

    searchConfigs: [
        {
            mainTitle: 'Stock Details',
            title: 'Search Locations YTD',
            url: './inventory/api/item/searchstockdetail',
            groupedOnLoad: true,
            groupedOnLoadWithTotals: true, 
            columns: [
                { dataIndex: 'strItemNo', text: 'Item No', flex: 1, dataType: 'string', key: true, drillDownText: 'View Item', drillDownClick: 'onViewItem', defaultSort: true, sortPriority: 2},
                { dataIndex: 'strDescription', text: 'Description', flex: 1, dataType: 'string'},
                { dataIndex: 'strType', text: 'Item Type', flex: 1, dataType: 'string' },
                { dataIndex: 'strCommodityCode', text: 'Commodity', flex: 1, dataType: 'string' },
                { dataIndex: 'strCategoryCode', text: 'Category', flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewCategory' },
                { dataIndex: 'strLocationName', text: 'Location', groupBy: true, flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewLocation', groupedOnLoadWithTotals: true, defaultSort: true, sortPriority: 1 },
                //{ dataIndex: 'strSubLocationName', text: 'Storage Location', flex: 1.1, minWidth: 110, dataType: 'string', defaultSort: true, sortPriority: 3 },
                //{ dataIndex: 'strStorageLocationName', text: 'Storage Unit', flex: 1, dataType: 'string', defaultSort: true, sortPriority: 4 },
                { dataIndex: 'strStockUOM', text: 'Stock UOM', flex: 1, dataType: 'string', drillDownText: 'View UOM', drillDownClick: 'onViewUOM' },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblUnitOnHand', text: 'On Hand', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblOnOrder', text: 'Purchase Order', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblOrderCommitted', text: 'Sales Order', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblUnitReserved', text: 'Reserved', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblInTransitInbound', text: 'In Transit Inbound', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblInTransitOutbound', text: 'In Transit Outbound', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblUnitStorage', text: 'On Storage', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblConsignedPurchase', text: 'Consigned Purchase', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.usMoney(value); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblAvailable', text: 'Available', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblLastCost', text: 'Last Cost', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.number(value, '$#,##0.000000##'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblAverageCost', text: 'Average Cost', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.number(value, '$#,##0.000000##'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblStandardCost', text: 'Standard Cost', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.number(value, '$#,##0.000000##'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblSalePrice', text: 'Retail Price', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.usMoney(value); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblExtended', text: 'Extended', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.usMoney(value); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblReorderPoint', text: 'Reorder Point', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblNearingReorderBy', text: 'Nearing Reorder By', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblMinOrder', text: 'Minimum Order', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.number(value, '#,##0.00'); } },
            ],
            showNew: false,
            showOpenSelected: false,
            enableDblClick: false,
            singleSelection: true,
            customControl: [
                {
                    xtype: 'button',
                    text: 'Valuation',
                    itemId: 'btnValuation',
                    iconCls: 'small-calculator',
                    listeners: {
                        click: function (e) {
                            var win = e.up('window');
                            var grid = e.up('panel');

                            
                            if(grid.url === './inventory/api/item/searchstockdetail') {
                                var selection = _.first(grid.getSelectionModel().selected.items);

                                if(selection) {
                                    var filters = [{
                                        column: 'strItemNo',
                                        value: selection.get('strItemNo'),
                                        condition: 'eq',
                                        conjunction: 'And'
                                    },
                                    {
                                        column: 'strLocationName',
                                        value: selection.get('strLocationName'),
                                        condition: 'eq',
                                        conjunction: 'And'
                                    }];
                                    
                                    var date = new Date(), 
                                        firstDayOfMonth = Ext.Date.getFirstDateOfMonth(date),
                                        lastDayOfMonth = Ext.Date.getLastDateOfMonth(date);

                                    filters.push({ column: 'dtmDate', condition: 'gte', conjunction: 'And', value: Ext.Date.format(firstDayOfMonth, "m/d/Y"), displayCondition: 'Between', group: 'ValuationFiscal' },
                                    { column: 'dtmDate', condition: 'lte', conjunction: 'And', value: Ext.Date.format(lastDayOfMonth, "m/d/Y"), displayCondition: 'Between', group: 'ValuationFiscal' })
                                        
                                    iRely.Functions.openScreen('Inventory.view.InventoryValuation', {
                                        showSearch: true,
                                        isFloating: true,
                                        filters: filters
                                    });

                                    //iRely.Functions.openScreen('Inventory.view.InventoryValuation', { isMenuClick: true });
                                }
                
                            }
                        }
                    }
                }
            ]
        },
        {
            mainTitle: 'Stock Details',
            title: 'UOMs YTD',
            url: './inventory/api/item/searchitemuomdetail',
            groupedOnLoad: true,
            columns: [
                { dataIndex: 'strItemNo', text: 'Item No', flex: 1, dataType: 'string', key: true, drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                { dataIndex: 'strDescription', text: 'Description', flex: 1, dataType: 'string'},
                { dataIndex: 'strType', text: 'Item Type', flex: 1, dataType: 'string' },
                { dataIndex: 'strCommodityCode', text: 'Commodity', flex: 1, dataType: 'string' },
                { dataIndex: 'strCategoryCode', text: 'Category', flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewCategory' },
                { dataIndex: 'strLocationName', text: 'Location', flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewLocation' },
                { dataIndex: 'strSubLocationName', text: 'Storage Location', flex: 1, dataType: 'string' },
                { dataIndex: 'strStorageLocationName', text: 'Storage Unit', flex: 1, dataType: 'string' },
                { dataIndex: 'strStockUOM', text: 'UOM', groupBy: true, flex: 1, dataType: 'string', drillDownText: 'View UOM', drillDownClick: 'onViewUOM' },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblUnitOnHand', text: 'On Hand', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblOnOrder', text: 'Purchase Order', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblOrderCommitted', text: 'Sales Order', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblUnitReserved', text: 'Reserved', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblInTransitInbound', text: 'In Transit Inbound', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblInTransitOutbound', text: 'In Transit Outbound', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblUnitStorage', text: 'On Storage', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblConsignedPurchase', text: 'Consigned Purchase', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.usMoney(value); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblAvailable', text: 'Available', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblLastCost', text: 'Last Cost', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.number(value, '$#,##0.000000##'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblAverageCost', text: 'Average Cost', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.number(value, '$#,##0.000000##'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblStandardCost', text: 'Standard Cost', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.number(value, '$#,##0.000000##'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblSalePrice', text: 'Retail Price', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.usMoney(value); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblExtended', text: 'Extended', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.usMoney(value); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblReorderPoint', text: 'Reorder Point', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblNearingReorderBy', text: 'Nearing Reorder By', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblMinOrder', text: 'Minimum Order', flex: 1, dataType: 'float', renderer: function (value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'checkcolumn', dataIndex: 'ysnStockUnit', text: 'Stock Unit', flex: 1, dataType: 'boolean' }
            ],
            showNew: false,
            showOpenSelected: false,
            enableDblClick: false,
            singleSelection: true
        },
        {
            showNew: false,
            showOpenSelected: false,
            enableDblClick: false,
            title: 'Search Storage Locations YTD',
            api: {
                read: './inventory/api/storagelocation/searchsublocationbindetails'
            },
            columns: [
                { dataIndex: 'intItemId', text: 'Item Id', width: 100, flex: 1, hidden: true, key: true },
                { dataIndex: 'intStorageLocationId', text: 'Storage Location Id', width: 100, flex: 1, hidden: true },
                { dataIndex: 'intCompanyLocationId', text: 'Company Location Id', width: 100, flex: 1, hidden: true },
                { dataIndex: 'strCommodityCode', text: 'Commodity', dataType: 'string', width: 100, flex: 1, hidden: false },
                { dataIndex: 'strItemNo', text: 'Item No', dataType: 'string', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                { dataIndex: 'strItemDescription', text: 'Item Description', dataType: 'string', width: 100, flex: 1 },
                { dataIndex: 'strLocation', text: 'Location', dataType: 'string', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewBinLocation' },
                { dataIndex: 'strSubLocationName', text: 'Storage Location', dataType: 'string', width: 100, flex: 1 },
               // { dataIndex: 'strStorageLocation', text: 'Storage Unit', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewBinStorageLocation' },
                { dataIndex: 'dblStock', text: 'Stock', dataType: 'numeric', xtype: 'numbercolumn', summaryType: 'sum', width: 100, flex: 1 },
                //{ dataIndex: 'dblAirSpaceReading', xtype: 'numbercolumn', text: 'Air Space Reading', width: 100, flex: 1, summaryType: 'sum' },
                //{ dataIndex: 'dblPhysicalReading', xtype: 'numbercolumn', text: 'Physical Reading', width: 100, flex: 1, summaryType: 'sum' },
                //{ dataIndex: 'dblStockVariance', xtype: 'numbercolumn', text: 'Stock Variance', width: 100, flex: 1, summaryType: 'sum' },
                //{ dataIndex: 'strUOM', text: 'UOM', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewBinUOM' },
                //{ dataIndex: 'dtmReadingDate', xtype: 'datecolumn', dataType: 'date', text: 'Reading Date', width: 100, flex: 1, hidden: false },
                { dataIndex: 'dblCapacity', xtype: 'numbercolumn', text: 'Capacity', dataType: 'numeric', width: 100, flex: 1, summaryType: 'sum' },
                { dataIndex: 'dblAvailable', xtype: 'numbercolumn', summaryType: 'sum', text: 'Space Available', dataType: 'numeric', width: 100, flex: 1 },
                { dataIndex: 'dblEffectiveDepth', xtype: 'numbercolumn', summaryType: 'sum', text: 'Effective Depth', dataType: 'numeric', width: 100, flex: 1, hidden: true },
                { dataIndex: 'dblPackFactor', xtype: 'numbercolumn', summaryType: 'sum', text: 'Pack Factor', dataType: 'numeric', width: 100, flex: 1, hidden: true },
                { dataIndex: 'dblUnitPerFoot', xtype: 'numbercolumn', summaryType: 'sum', text: 'Unit Per Foot', dataType: 'numeric', width: 100, flex: 1, hidden: true }
                //{ dataIndex: 'strDiscountCode', text: 'Discount Schedule Id', width: 100, flex: 1, drillDownText: 'Discount Codes', drillDownClick: 'onViewDiscountCodes' },
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
                url: './inventory/api/storagelocation/searchsublocationbins',
                type: 'serial',
                /*startDuration: 1,
                startEffect: 'elastic',*/
                mouseWheelZoomEnabled: true,
                mouseWheelScrollEnabled: true,
                responsive: {
                    enabled: true
                },
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
                        fillAlphas: 1,
                        fillColors: "#fcd202",
                        //fillColorsField: "strColor",
                        //alphaField: "strLocation",
                        //labelText: '[[value]]',
                        lineAlpha: 0.5,
                        lineColor: "#FFFFFF",
                        lineThickness: 1,
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
                        fillAlphas: 1,
                        fillColors: "#cdcdcd",
                        lineAlpha: 0.5,
                        lineColor: "#cdcdcd",
                        lineThickness: 1,
                    }
                ],
                chartScrollbar: {
                    enabled: true,
                    graphType: "none",
                    backgroundColor: "#F2F2F2",
                    dragIcon: "dragIconRectBig",
                    dragIconHeight: 32,
                    offset: 24,
                    graph: "stockGraph",
                    graphFillColor: "#c2c2c2",
                    graphLineColor: "",
                    oppositeAxis: true,
                    scrollbarHeight: 12,
                    selectedBackgroundColor: "#696969",
                    selectedGraphFillColor: "#fff",
                    selectedGraphLineColor: ""
                },
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
                    labelRotation: 20,
                    //labelColorField: 'strColor',
                    boldLabels: false,
                    /*type: 'serial',*/
                    gridPosition: 'start'
                },
                categoryField: 'strSubLocation',
                listeners: [
                    {
                        //event: 'clickGraphItem',
                        method: function (event) {
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
                                        read: './inventory/api/storagelocation/searchsublocationbindetails'
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
                                        read: './inventory/api/storagelocation/searchstoragebins'
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
                                getAssociatedRecords: function (record) {
                                    var result = Ext.Array.filter(
                                        discountSchedules.data.items,
                                        function (r) { return 1 == 1 }
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
                                    { dataIndex: 'strItemNo', text: 'Item No', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                                    { dataIndex: 'strItemDescription', text: 'Item Description', width: 100, flex: 1 },
                                    { dataIndex: 'strLocation', text: 'Location', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewBinLocation' },
                                    { dataIndex: 'strStorageLocation', text: 'Storage Location', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewBinStorageLocation' },
                                    { dataIndex: 'dblStock', text: 'Stock', xtype: 'numbercolumn', summaryType: 'sum', width: 100, flex: 1 },
                                    { dataIndex: 'strUOM', text: 'UOM', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewBinUOM' },
                                    { dataIndex: 'dblCapacity', xtype: 'numbercolumn', text: 'Capacity', width: 100, flex: 1, summaryType: 'sum' },
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
                                        getAssociatedRecords: function (record) {
                                            var result = Ext.Array.filter(
                                                discountSchedules.data.items,
                                                function (r) { return 1 == 1 }
                                            );
                                            return result;
                                        }
                                    }
                                ]
                            });

                            event.chart.events.clickGraphItem = [];
                            event.chart.addListener("clickGraphItem", Ext.bind(function (event) {
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
                read: './inventory/api/storagelocation/searchstoragebindetails'
            },
            columns: [
                { dataIndex: 'intItemId', text: 'Item Id', width: 100, flex: 1, hidden: true, key: true },
                { dataIndex: 'intStorageLocationId', text: 'Storage Location Id', width: 100, flex: 1, hidden: true },
                { dataIndex: 'intCompanyLocationId', text: 'Company Location Id', width: 100, flex: 1, hidden: true },
                /*{ dataIndex: 'intCommodityId', text: 'Commodity Id', width: 100, flex: 1, hidden: true },*/
                { dataIndex: 'strCommodityCode', text: 'Commodity', dataType: 'string', width: 100, flex: 1, hidden: false },
                { dataIndex: 'strItemNo', text: 'Item No', dataType: 'string', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                { dataIndex: 'strItemDescription', text: 'Item Description', dataType: 'string', width: 100, flex: 1 },
                { dataIndex: 'strLocation', text: 'Location', dataType: 'string', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewBinLocation' },
                { dataIndex: 'intSubLocationId', text: 'Storage Location Id', width: 100, flex: 1, hidden: true },
                { dataIndex: 'strSubLocationName', text: 'Storage Location', dataType: 'string', width: 100, flex: 1 },
                { dataIndex: 'strStorageLocation', text: 'Storage Unit', dataType: 'string', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewBinStorageLocation' },
                { dataIndex: 'dblStock', text: 'Stock', xtype: 'numbercolumn', dataType: 'numeric', summaryType: 'sum', width: 100, flex: 1 },
                { dataIndex: 'dblAirSpaceReading', xtype: 'numbercolumn', text: 'Air Space Reading', dataType: 'numeric', width: 100, flex: 1, summaryType: 'sum' },
                { dataIndex: 'dblPhysicalReading', xtype: 'numbercolumn', text: 'Physical Reading', dataType: 'numeric', width: 100, flex: 1, summaryType: 'sum' },
                { dataIndex: 'dblStockVariance', xtype: 'numbercolumn', text: 'Stock Variance', dataType: 'numeric', width: 100, flex: 1, summaryType: 'sum' },
                { dataIndex: 'strUOM', text: 'UOM', dataType: 'string', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewBinUOM' },
                { dataIndex: 'dtmReadingDate', xtype: 'datecolumn', dataType: 'date', text: 'Reading Date', width: 100, flex: 1, hidden: false },
                { dataIndex: 'dblCapacity', xtype: 'numbercolumn', dataType: 'numeric', text: 'Capacity', width: 100, flex: 1, summaryType: 'sum' },
                { dataIndex: 'dblAvailable', xtype: 'numbercolumn', dataType: 'numeric', summaryType: 'sum', text: 'Space Available', width: 100, flex: 1 },
                { dataIndex: 'dblEffectiveDepth', xtype: 'numbercolumn', dataType: 'numeric', summaryType: 'sum', text: 'Effective Depth', width: 100, flex: 1, hidden: true },
                { dataIndex: 'dblPackFactor', xtype: 'numbercolumn', dataType: 'numeric', summaryType: 'sum', text: 'Pack Factor', width: 100, flex: 1, hidden: true },
                { dataIndex: 'dblUnitPerFoot', xtype: 'numbercolumn', dataType: 'numeric', summaryType: 'sum', text: 'Unit Per Foot', width: 100, flex: 1, hidden: true },
                { dataIndex: 'strDiscountCode', text: 'Discount Schedule Id', dataType: 'string', width: 100, flex: 1, drillDownText: 'Discount Codes', drillDownClick: 'onViewDiscountCodes' },
                { dataIndex: 'strDiscountDescription', text: 'Discount Schedule', dataType: 'string', width: 100, flex: 1 },
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
                url: './inventory/api/storagelocation/searchstoragebins',
                type: 'serial',
                /*startDuration: 1,
                startEffect: 'elastic',*/
                mouseWheelZoomEnabled: true,
                mouseWheelScrollEnabled: true,
                responsive: {
                    enabled: true
                },
                valueAxes: [
                    {
                        id: 'axis',
                        position: 'left',
                        title: 'Stock',
                        stackType: "100%"
                    }
                ],
                chartScrollbar: {
                    enabled: true,
                    backgroundColor: "#F2F2F2",
                    dragIcon: "dragIconRectBig",
                    dragIconHeight: 32,
                    offset: 24,
                    graph: "stockGraph",
                    graphFillColor: "#c2c2c2",
                    graphLineColor: "",
                    graphType: "none",
                    oppositeAxis: true,
                    scrollbarHeight: 12,
                    selectedBackgroundColor: "#696969",
                    selectedGraphFillColor: "#fff",
                    selectedGraphLineColor: ""
                },
                graphs: [
                    {
                        id: 'stockGraph',
                        balloonText: "[[title]] of [[category]]:[[value]]",
                        type: 'column',
                        title: 'Stock',
                        valueField: 'dblStock',
                        valueAxis: 'axis',
                        topRadius: 1,
                        fillAlphas: 1,
                        fillColors: "#fcd202",
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
                        fillAlphas: 1,
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
                    labelRotation: 20,
                    minHorizontalGap: 60,
                    //labelColorField: 'strColor',
                    boldLabels: false,
                    /*type: 'serial',*/
                    gridPosition: 'start'
                },
                categoryField: 'strStorageLocation',
                listeners: [
                    {
                        //event: 'clickGraphItem',
                        method: function (event) {
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
                                        read: './inventory/api/storagelocation/searchstoragebindetails'
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
                                        read: './inventory/api/storagelocation/searchstoragebins'
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
                                getAssociatedRecords: function (record) {
                                    var result = Ext.Array.filter(
                                        discountSchedules.data.items,
                                        function (r) { return 1 == 1 }
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
                                    { dataIndex: 'strItemNo', dataType: 'string', text: 'Item No', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                                    { dataIndex: 'strItemDescription', text: 'Item Description', width: 100, flex: 1 },
                                    { dataIndex: 'strLocation', text: 'Location', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewBinLocation' },
                                    { dataIndex: 'strStorageLocation', text: 'Storage Unit', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewBinStorageLocation' },
                                    { dataIndex: 'dblStock', text: 'Stock', xtype: 'numbercolumn', summaryType: 'sum', width: 100, flex: 1 },
                                    { dataIndex: 'strUOM', text: 'UOM', width: 100, flex: 1, drillDownText: 'View Item', drillDownClick: 'onViewBinUOM' },
                                    { dataIndex: 'dblCapacity', xtype: 'numbercolumn', text: 'Capacity', width: 100, flex: 1, summaryType: 'sum' },
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
                                        getAssociatedRecords: function (record) {
                                            var result = Ext.Array.filter(
                                                discountSchedules.data.items,
                                                function (r) { return 1 == 1 }
                                            );
                                            return result;
                                        }
                                    }
                                ]
                            });

                            event.chart.events.clickGraphItem = [];
                            event.chart.addListener("clickGraphItem", Ext.bind(function (event) {
                                alert(this.grid);
                            }, { grid: grid }));
                        }
                    }
                ]
            }
        }
    ],

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
    }  
});