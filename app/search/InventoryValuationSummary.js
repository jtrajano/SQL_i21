Ext.define('Inventory.search.InventoryValuationSummary', {
    alias: 'search.icinventoryvaluationsummary',
    singleton: true,
    searchConfigs: [
        {
          title: 'Inventory Valuation Summary',
            url: '../Inventory/api/Item/SearchInventoryValuationSummary',
            columns: [
                { dataIndex: 'strItemNo', text: 'Item No', allowSort: false, flex: 1, dataType: 'string', key: true, drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                { dataIndex: 'strItemDescription', text: 'Description', allowSort: false, flex: 1, dataType: 'string' },
                { dataIndex: 'strLocationName', text: 'Location', allowSort: false, flex: 1, dataType: 'string', drillDownText: 'View Location', drillDownClick: 'onViewLocation' },
                { dataIndex: 'strSubLocationName', text: 'Storage Location', allowSort: false, flex: 1, dataType: 'string' },
                { dataIndex: 'strCategoryCode', text: 'Category', allowSort: false, flex: 1, dataType: 'string' },
                { dataIndex: 'strCommodityCode', text: 'Commodity', allowSort: false, flex: 1, dataType: 'string' },                
                { dataIndex: 'strStockUOM', text: 'Stock UOM', allowSort: false, flex: 1, dataType: 'string' },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblQuantityInStockUOM', text: 'Stock Quantity', allowSort: false, flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblValue', text: 'Value', allowSort: false, flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblLastCost', text: 'Last Cost', allowSort: false, flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblStandardCost', text: 'Standard Cost', allowSort: false, flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblAverageCost', text: 'Average Cost', allowSort: false, flex: 1, dataType: 'float' }
            ],
            showNew: false,
            showOpenSelected: false,
            enableDblClick: false  
        }
    ],
    
    //Drilldown functions
    onViewLocation: function (value, record) {
        var locationName = record.get('strLocationName');
        i21.ModuleMgr.Inventory.showScreen(locationName, 'LocationName');
    },

    onViewItem: function (value, record) {
        var itemNo = record.get('strItemNo');
        i21.ModuleMgr.Inventory.showScreen(itemNo, 'ItemNo');
    }
});


        