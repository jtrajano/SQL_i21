Ext.define('Inventory.view.InventoryValuationViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icinventoryvaluation',

    config: {
        searchConfig: {
            title: 'Inventory Valuation',
            url: '../Inventory/api/Item/GetInventoryValuation',
            columns: [
                { dataIndex: 'strItemNo', text: 'Item No', allowSort: false, flex: 1, dataType: 'string', key: true, drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                { dataIndex: 'strItemDescription', text: 'Description', allowSort: false, flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                { dataIndex: 'strCategory', text: 'Category', allowSort: false, flex: 1, dataType: 'string', drillDownText: 'View Category', drillDownClick: 'onViewCategory' },
                { dataIndex: 'strUOM', text: 'UOM', allowSort: false, flex: 1, dataType: 'string' },
                { dataIndex: 'strLocationName', text: 'Location', allowSort: false, flex: 1, dataType: 'string', drillDownText: 'View Location', drillDownClick: 'onViewLocation' },
                { dataIndex: 'strSubLocationName', text: 'Sub Location', allowSort: false, flex: 1, dataType: 'string' },
                { dataIndex: 'strStorageLocationName', text: 'Storage Location', allowSort: false, flex: 1, dataType: 'string', drillDownText: 'View Storage Location', drillDownClick: 'onViewStorageLocation' },
                { dataIndex: 'strCostingMethod', text: 'Costing Method', allowSort: false, flex: 1, dataType: 'string' },
                { xtype: 'datecolumn', dataIndex: 'dtmDate', text: 'Date', allowSort: false, flex: 1, dataType: 'date' },
                { dataIndex: 'strTransactionType', text: 'Transaction Type', allowSort: false, flex: 1, dataType: 'string' },
                { dataIndex: 'strTransactionId', text: 'Transaction Id', allowSort: false, flex: 1, dataType: 'string', drillDownText: 'View Transaction', drillDownClick: 'onViewTransaction' },
                { xtype: 'numbercolumn', summaryType: 'sum', dataIndex: 'dblBeginningQtyBalance', text: 'Beginning Qty Balance', allowSort: false, flex: 1.25, dataType: 'float' },
                { xtype: 'numbercolumn', summaryType: 'sum', dataIndex: 'dblQuantity', text: 'Qty', allowSort: false, flex: .75, dataType: 'float' },
                { xtype: 'numbercolumn', summaryType: 'sum', dataIndex: 'dblRunningQtyBalance', text: 'Running Qty Balance', allowSort: false, flex: 1.25, dataType: 'float' },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblCost', text: 'Cost', allowSort: false, flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblBeginningBalance', text: 'Beginning Balance', allowSort: false, flex: 1.2, dataType: 'float' },
                { xtype: 'numbercolumn', format: '#,##0.0000', summaryType: 'sum', dataIndex: 'dblValue', text: 'Value', allowSort: false, flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', format: '#,##0.00', summaryType: 'sum', dataIndex: 'dblRunningBalance', text: 'Running Balance', allowSort: false, flex: 1.2, dataType: 'float' },
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
    },

    onViewCategory: function (value, record) {
        var locationName = record.get('strCategory');
        i21.ModuleMgr.Inventory.showScreen(locationName, 'Category');
    },

    onViewLocation: function (value, record) {
        var locationName = record.get('strLocationName');
        i21.ModuleMgr.Inventory.showScreen(locationName, 'LocationName');
    },

    onViewStorageLocation: function (value, record) {
        var locationName = record.get('strStorageLocationName');
        i21.ModuleMgr.Inventory.showScreen(locationName, 'StorageLocation');
    },

    onViewItem: function (value, record) {
        var itemNo = record.get('strItemNo');
        i21.ModuleMgr.Inventory.showScreen(itemNo, 'ItemNo');
    },

    onViewTransaction: function (value, record) {
        var transactionType = null;
        switch (record.get('strTransactionType')) {
            case 'Inventory Receipt':
                transactionType = 'ReceiptNo';
                break;

            case 'Inventory Shipment':
                transactionType = 'ShipmentNo';
                break;

            case 'Inventory Transfer with Shipment':
            case 'Inventory Transfer':
                transactionType = 'TransferNo';
                break;

            case 'Inventory Adjustment - Quantity Change':
            case 'Inventory Adjustment - UOM Change':
            case 'Inventory Adjustment - Item Change':
            case 'Inventory Adjustment - Lot Status Change':
            case 'Inventory Adjustment - Split Lot':
            case 'Inventory Adjustment - Expiry Date Change':
            case 'Inventory Adjustment - Lot Merge':
            case 'Inventory Adjustment - Lot Move':
                transactionType = 'AdjustmentNo';
                break;

            case 'Purchase Order':
                transactionType = 'PONumber';
                break;

            case 'Sales Order':
                transactionType = 'SONumber';
                break;
            case 'Invoice':
                transactionType = 'Invoice';
                break;
            default:
                iRely.Functions.showInfoDialog('This transaction is not viewable on a screen.');
                break;
        }
        ;
        i21.ModuleMgr.Inventory.showScreen(value, transactionType);
    }
});
