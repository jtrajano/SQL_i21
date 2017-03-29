Ext.define('Inventory.search.InventoryValuationSummary', {
    alias: 'search.icinventoryvaluationsummary',
    singleton: true,
    searchConfigs: [
        {
            title: 'Inventory Valuation Summary',
            url: '../Inventory/api/Item/SearchInventoryValuationSummary',
            columns: [
                { dataIndex: 'strItemNo', text: 'Item No', allowSort: true, flex: 1, dataType: 'string', key: true, drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                { dataIndex: 'strItemDescription', text: 'Description', allowSort: true, flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                { dataIndex: 'strLocationName', text: 'Location', allowSort: true, flex: 1, dataType: 'string', drillDownText: 'View Location', drillDownClick: 'onViewLocation' },
                { dataIndex: 'strSubLocationName', text: 'Storage Location', allowSort: false, flex: 1, dataType: 'string' },
                { dataIndex: 'strCategoryCode', text: 'Category', allowSort: true, flex: 1, dataType: 'string' },
                { dataIndex: 'strCommodityCode', text: 'Commodity', allowSort: true, flex: 1, dataType: 'string' },
                { dataIndex: 'strStockUOM', text: 'Stock UOM', allowSort: true, flex: 1, dataType: 'string' },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblQuantityInStockUOM', text: 'Stock Quantity', allowSort: true, flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblValue', text: 'Value', allowSort: true, flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblLastCost', text: 'Last Cost', allowSort: true, flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblStandardCost', text: 'Standard Cost', allowSort: true, flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblAverageCost', text: 'Average Cost', allowSort: true, flex: 1, dataType: 'float' },
                { dataIndex: 'strInTransitLocationName', text: 'InTransit Location', hidden: true, allowSort: false, dataType: 'string', required: true }
            ],
            showNew: false,
            showOpenSelected: false,
            enableDblClick: false
        }
    ],
    
    //Drilldown functions
    onViewLocation: function (value, record) {       
        var locationName = record.get('strInTransitLocationName');
        locationName = Ext.isEmpty(locationName) ? record.get('strLocationName') : locationName; 

        if (Ext.isEmpty(locationName) === false) {
            i21.ModuleMgr.Inventory.showScreen(locationName, 'LocationName');
        }        
    },

    onViewItem: function (value, record) {
        var itemNo = record.get('strItemNo');
        i21.ModuleMgr.Inventory.showScreen(itemNo, 'ItemNo');
    }
});


        