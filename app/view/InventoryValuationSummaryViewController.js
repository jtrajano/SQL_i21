Ext.define('Inventory.view.InventoryValuationSummaryViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icinventoryvaluationsummary',

    config: {
        searchConfig: {
            title: 'Inventory Valuation Summary',
            url: '../Inventory/api/Item/GetInventoryValuationSummary',
            columns: [
                { dataIndex: 'strItemNo', text: 'Item No', allowSort: false, flex: 1, dataType: 'string', key: true, drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                { dataIndex: 'strItemDescription', text: 'Description', allowSort: false, flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                { dataIndex: 'strLocationName', text: 'Location', allowSort: false, flex: 1, dataType: 'string', drillDownText: 'View Location', drillDownClick: 'onViewLocation' },
                { dataIndex: 'strSubLocationName', text: 'Sub Location', allowSort: false, flex: 1, dataType: 'string' },
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
    },

    show: function(config){
        var me = this,
            win = this.getView();

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
                store  : Ext.create('Inventory.store.BufferedInventoryValuation', { pageSize: 1 }),
                binding: me.config.binding,
                showNew: false
            });

        win.context = context;
        return context;
    },

    onViewLocation: function (value, record) {
        var locationName = record.get('strLocationName');
        i21.ModuleMgr.Inventory.showScreen(locationName, 'LocationName');
    },

    onViewItem: function (value, record) {
        var itemNo = record.get('strItemNo');
        i21.ModuleMgr.Inventory.showScreen(itemNo, 'ItemNo');
    }
});
