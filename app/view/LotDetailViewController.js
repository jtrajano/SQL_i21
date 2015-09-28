Ext.define('Inventory.view.LotDetailViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.iclotdetail',

    config: {
        searchConfig: {
            title: 'Lot Detail',
            url: '../Inventory/api/Lot/Search',
            columns: [
                { dataIndex: 'strItemNo', text: 'Item No', flex: 1, dataType: 'string', key: true },
                { dataIndex: 'strItemDescription', text: 'Description', flex: 1, dataType: 'string' },
                { dataIndex: 'strLocationName', text: 'Location Name', flex: 1, dataType: 'string' },
                { dataIndex: 'strSubLocationName', text: 'Sub Location', flex: 1, dataType: 'string' },
                { dataIndex: 'strStorageLocation', text: 'Storage Location', flex: 1, dataType: 'string' },
                { dataIndex: 'strLotNumber', text: 'Lot Number', flex: 1, dataType: 'string' },
                { xtype: 'numbercolumn', summaryType: 'sum', dataIndex: 'dblQty', text: 'Quantity', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', summaryType: 'sum', dataIndex: 'dblWeight', text: 'Weight', flex: 1, dataType: 'float' },
                { dataIndex: 'strItemUOM', text: 'UOM', flex: 1, dataType: 'string' },
                { xtype: 'numbercolumn', summaryType: 'sum', dataIndex: 'dblWeightPerQty', text: 'Weight Per Qty', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', summaryType: 'sum', dataIndex: 'dblLastCost', text: 'Last Cost', flex: 1, dataType: 'float' }
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
                store  : Ext.create('Inventory.store.BufferedLot', { pageSize: 1 }),
                binding: me.config.binding,
                showNew: false
            });

        win.context = context;
        return context;
    }
});
