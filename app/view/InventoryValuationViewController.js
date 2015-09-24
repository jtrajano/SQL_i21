Ext.define('Inventory.view.InventoryValuationViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icinventoryvaluation',

    config: {
        searchConfig: {
            title: 'Inventory Valuation',
            url: '../Inventory/api/Item/GetInventoryValuation',
            columns: [
                { dataIndex: 'strItemNo', text: 'Item No', flex: 1, dataType: 'string', key: true },
                { dataIndex: 'strItemDescription', text: 'Description', flex: 1, dataType: 'string' },
                { dataIndex: 'strCategory', text: 'Category', flex: 1, dataType: 'string' },
                { dataIndex: 'strLocationName', text: 'Location', flex: 1, dataType: 'string' },
                { dataIndex: 'strSubLocationName', text: 'Sub Location', flex: 1, dataType: 'string' },
                { dataIndex: 'strStorageLocationName', text: 'Storage Location', flex: 1, dataType: 'string' },
                { xtype: 'datecolumn', dataIndex: 'dtmDate', text: 'Date', flex: 1, dataType: 'date' },
                { dataIndex: 'strTransactionForm', text: 'Transaction Form', flex: 1, dataType: 'string' },
                { dataIndex: 'strTransactionId', text: 'Transaction Id', flex: 1, dataType: 'string' },
                { xtype: 'numbercolumn', summaryType: 'sum', dataIndex: 'dblQuantity', text: 'Quantity', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', summaryType: 'sum', dataIndex: 'dblCost', text: 'Cost', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', summaryType: 'sum', dataIndex: 'dblBeginningBalance', text: 'Beginning Balance', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', summaryType: 'sum', dataIndex: 'dblValue', text: 'Value', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', summaryType: 'sum', dataIndex: 'dblRunningBalance', text: 'Running Balance', flex: 1, dataType: 'float' },
                { dataIndex: 'strBatchId', text: 'Batch Id', flex: 1, dataType: 'string' }
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
    }
});
