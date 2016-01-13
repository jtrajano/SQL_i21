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
});
