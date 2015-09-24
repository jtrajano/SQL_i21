Ext.define('Inventory.view.StockDetailViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icstockdetail',

    config: {
        searchConfig: {
            title: 'Stock Details',
            url: '../Inventory/api/Item/GetItemStocks',
            columns: [
                { dataIndex: 'strItemNo', text: 'Item No', flex: 1, dataType: 'string', key: true },
                { dataIndex: 'strDescription', text: 'Description', flex: 1, dataType: 'string' },
                { dataIndex: 'strLocationName', text: 'Location Name', flex: 1, dataType: 'string' },
                { xtype: 'numbercolumn', summaryType: 'sum', dataIndex: 'dblUnitOnHand', text: 'On Hand', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', summaryType: 'sum', dataIndex: 'dblOrderCommitted', text: 'Committed', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', summaryType: 'sum', dataIndex: 'dblOnOrder', text: 'On Order', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', summaryType: 'sum', dataIndex: 'dblBackOrder', text: 'Back Order', flex: 1, dataType: 'float' },
                { dataIndex: 'dblLastCost', text: 'Last Cost', flex: 1, dataType: 'float' },
                { dataIndex: 'dblAverageCost', text: 'Average Cost', flex: 1, dataType: 'float' },
                { dataIndex: 'dblStandardCost', text: 'Standard Cost', flex: 1, dataType: 'float' }
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
    }
});
