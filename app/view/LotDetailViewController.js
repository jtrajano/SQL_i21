Ext.define('Inventory.view.LotDetailViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.iclotdetail',

    config: {
        searchConfig: {
            title: 'Lot Detail',
            url: '../Inventory/api/Lot/GetLots',
            columns: [
                { dataIndex: 'strItemNo', text: 'Item No', flex: 1, dataType: 'string', key: true, drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                { dataIndex: 'strItemDescription', text: 'Description', flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                { dataIndex: 'strProductType', text: 'Product Type', flex: 1, dataType: 'string' },
                { dataIndex: 'strLocationName', text: 'Location Name', flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewLocation' },
                { dataIndex: 'strSubLocationName', text: 'Sub Location', flex: 1, dataType: 'string' },
                { dataIndex: 'strStorageLocation', text: 'Storage Location', flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewStorageLocation' },
                { dataIndex: 'strLotNumber', text: 'Lot Number', flex: 1, dataType: 'string' },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblQty', text: 'Quantity', flex: 1, dataType: 'float', renderer: function(value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblWeight', text: 'Weight', flex: 1, dataType: 'float', renderer: function(value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { dataIndex: 'strWeightUOM', text: 'Weight UOM', flex: 1, dataType: 'string' },
                //{ dataIndex: 'strItemUOM', text: 'UOM', flex: 1, dataType: 'string' },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblWeightPerQty', text: 'Weight Per Qty', flex: 1, dataType: 'float', renderer: function(value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblLastCost', text: 'Last Cost', flex: 1, dataType: 'float', renderer: function(value) { return Ext.util.Format.usMoney(value); } },
                { dataIndex: 'strCostUOM', text: 'Cost UOM', flex: 1, dataType: 'string' },
                { dataIndex: 'intLotId', text: 'Lot Id', flex: 1, dataType: 'numeric', key: true, hidden: true }
            ],
            showNew: false,
            showOpenSelected: false,
            enableDblClick: false,
            buttons: [
                {
                    itemId: 'btnTrace',
                    text: 'Trace',
                    clickHandler: 'onTraceClick'
                },
                {
                    itemId: 'btnHistory',
                    text: 'History',
                    clickHandler: 'onHistoryClick'
                }
            ]
        }
    },

    onTraceClick: function(e, grid) {
        if(grid.view.selection) {
            var intLotId = grid.view.selection.get('intLotId');

            var config = {
                intObjectTypeId: 4,
                intObjectId: intLotId
            };

            iRely.Functions.openScreen('Manufacturing.view.TraceabilityDiagram',config);
        } else {
            iRely.Functions.showCustomDialog(iRely.Functions.dialogType.ERROR, iRely.Functions.dialogButtonType.OK, "Please select a lot.");
        }
    },

    onHistoryClick: function(e, grid) {
        if(grid.view.selection) {
            iRely.Functions.openScreen('Inventory.view.LotDetailHistory', grid.view.selection.get('intLotId'));
        } else {
            iRely.Functions.showCustomDialog(iRely.Functions.dialogType.ERROR, iRely.Functions.dialogButtonType.OK, "Please select a lot.");  
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
    },

    onViewLocation: function (value, record) {
        var locationName = record.get('strLocationName');
        i21.ModuleMgr.Inventory.showScreen(locationName, 'LocationName');
    },

    onViewStorageLocation: function (value, record) {
        var locationName = record.get('strStorageLocation');
        i21.ModuleMgr.Inventory.showScreen(locationName, 'StorageLocation');
    },

    onViewItem: function (value, record) {
        var itemNo = record.get('strItemNo');
        i21.ModuleMgr.Inventory.showScreen(itemNo, 'ItemNo');
    }
});
