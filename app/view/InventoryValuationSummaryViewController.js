Ext.define('Inventory.view.InventoryValuationSummaryViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icinventoryvaluationsummary',

    config: {
        searchConfig: {
            title: 'Inventory Valuation Summary',
            url: '../Inventory/api/Item/GetInventoryValuationSummary',
            columns: [
                { dataIndex: 'strItemNo', text: 'Item No', allowSort: false, flex: 1, dataType: 'string', key: true },
                { dataIndex: 'strItemDescription', text: 'Description', allowSort: false, flex: 1, dataType: 'string' },
                { dataIndex: 'strLocationName', text: 'Location', allowSort: false, flex: 1, dataType: 'string' },
                { dataIndex: 'strSubLocationName', text: 'Sub Location', allowSort: false, flex: 1, dataType: 'string' },
                { dataIndex: 'strStorageLocationName', text: 'Storage Location', allowSort: false, flex: 1, dataType: 'string' },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblValue', text: 'Value', allowSort: false, flex: 1, dataType: 'float' }
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
