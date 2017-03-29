Ext.define('Inventory.search.InventoryValuation', {
    alias: 'search.icinventoryvaluation',
    singleton: true,
    searchConfigs: [
        {
            title: 'Inventory Valuation',
            url: '../Inventory/api/Item/GetInventoryValuation',
            columns: [
                { dataIndex: 'strItemNo', text: 'Item No', allowSort: false, flex: 1, dataType: 'string', key: true, drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                { dataIndex: 'strItemDescription', text: 'Description', allowSort: false, flex: 1, dataType: 'string' },
                { dataIndex: 'strCategory', text: 'Category', allowSort: false, flex: 1, dataType: 'string', drillDownText: 'View Category', drillDownClick: 'onViewCategory' },
                { dataIndex: 'strStockUOM', text: 'Stock UOM', allowSort: false, flex: 1, dataType: 'string' },
                { dataIndex: 'strLocationName', text: 'Location', allowSort: false, flex: 1, dataType: 'string', drillDownText: 'View Location', drillDownClick: 'onViewLocation' },
                { dataIndex: 'strSubLocationName', text: 'Storage Location', hidden: true, allowSort: false, flex: 1, dataType: 'string' },
                { dataIndex: 'strStorageLocationName', text: 'Storage Unit', hidden: true, allowSort: false, flex: 1, dataType: 'string', drillDownText: 'View Storage Unit', drillDownClick: 'onViewStorageLocation' },
                { dataIndex: 'strBOLNumber', text: 'BOL Number', hidden: false, allowSort: false, flex: 1, dataType: 'string' },
                { dataIndex: 'strEntity', text: 'Entity', hidden: false, allowSort: false, flex: 1, dataType: 'string' },
                { dataIndex: 'strLotNumber', text: 'Lot Number', hidden: false, allowSort: false, dataType: 'string' },
                { dataIndex: 'strAdjustedTransaction', text: 'Adjusted Transaction', hidden: false, allowSort: false, dataType: 'string' },
                { dataIndex: 'strCostingMethod', text: 'Costing Method', allowSort: false, flex: 1, dataType: 'string' },
                { xtype: 'datecolumn', dataIndex: 'dtmDate', text: 'Date', allowSort: false, flex: 1, dataType: 'date' },
                { dataIndex: 'strTransactionType', text: 'Transaction Type', allowSort: false, flex: 1, dataType: 'string' },
                { dataIndex: 'strTransactionId', text: 'Transaction Id', allowSort: false, flex: 1, dataType: 'string', drillDownText: 'View Transaction', drillDownClick: 'onViewTransaction' },
                { xtype: 'numbercolumn', format: '#,##0.000000', summaryType: 'sum', dataIndex: 'dblBeginningQtyBalance', text: 'Begin Qty', allowSort: false, flex: 1.25, dataType: 'float', renderer: function(value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.000000', summaryType: 'sum', dataIndex: 'dblQuantityInStockUOM', text: 'Qty', allowSort: false, flex: .75, dataType: 'float', renderer: function(value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.000000', summaryType: 'sum', dataIndex: 'dblRunningQtyBalance', text: 'Running Qty', allowSort: false, flex: 1.25, dataType: 'float', renderer: function(value) { return Ext.util.Format.number(value, '#,##0.00'); } },
                { xtype: 'numbercolumn', format: '#,##0.000000', summaryType: 'sum', dataIndex: 'dblCostInStockUOM', text: 'Cost', allowSort: false, flex: 1, dataType: 'float', renderer: function(value) { return Ext.util.Format.usMoney(value); } },
                { xtype: 'numbercolumn', format: '#,##0.000000', summaryType: 'sum', dataIndex: 'dblBeginningBalance', text: 'Begin Value', allowSort: false, flex: 1.2, dataType: 'float', renderer: function(value) { return Ext.util.Format.usMoney(value); } },
                { xtype: 'numbercolumn', format: '#,##0.000000', summaryType: 'sum', dataIndex: 'dblValue', text: 'Value', allowSort: false, flex: 1, dataType: 'float', renderer: function(value) { return Ext.util.Format.usMoney(value); } },
                { xtype: 'numbercolumn', format: '#,##0.00', summaryType: 'sum', dataIndex: 'dblRunningBalance', text: 'Running Value', allowSort: false, flex: 1.2, dataType: 'float', renderer: function(value) { return Ext.util.Format.usMoney(value); } },
                { dataIndex: 'strBatchId', text: 'Batch Id', flex: 1, dataType: 'string' }
            ],
            showNew: false,
            showOpenSelected: false,
            enableDblClick: false,
            // TODO:
            // Add button allows the user to pick the UOM to display per item. See IC-2421 for more info.
            // The mentioned about showing it in stock unit. However, we will need to adjust the inventory valuation
            // screen to allow the user to pick the UOM they want to show in the valuation. It will default to the
            // stock unit but letting the user pick the uom will give them some flexibility.

            // buttons: [
            //     {
            //         text: 'Change Displayed UOM',
            //         itemId: 'btnItem',
            //         clickHandler: 'onItemClick',
            //         width: 80
            //     }
            // ]

            buttons: [
                {
                    text: 'Rebuild',
                    itemId: 'btnRepost',
                    clickHandler: function(e) {
                        iRely.Functions.openScreen('Inventory.view.RebuildInventory', { action: 'new', viewConfig: { modal: true }});
                    },
                    width: 80
                }
            ]
        }
    ],

    //Drilldown functions 
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
            case 'Inventory Return':
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


        