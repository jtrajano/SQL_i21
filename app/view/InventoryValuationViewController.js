Ext.define('Inventory.view.InventoryValuationViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icinventoryvaluation',

    setupContext : function(){
        "use strict";
        var win = this.getView();
        win.context = Ext.create('iRely.mvvm.Engine', {
            window: win,
            store: Ext.create('Inventory.store.InventoryValuation'),
            singleGridMgr: Ext.create('iRely.mvvm.grid.Manager', {
                grid: win.down('grid'),
                title: 'View Inventory Valuation',
                columns: [
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colItemNo',
                        dataIndex: 'strItemNo',
                        text: 'Item No',
                        groupable: true
                    },
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colDescription',
                        dataIndex: 'strItemDescription',
                        text: 'Description'
                    },
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colCategory',
                        dataIndex: 'strCategory',
                        text: 'Category'
                    },
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colLocation',
                        dataIndex: 'strLocationName',
                        text: 'Location'
                    },
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colSubLocation',
                        dataIndex: 'strSubLocationName',
                        text: 'Sub Location'
                    },
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colStorageLocation',
                        dataIndex: 'strStorageLocationName',
                        text: 'Storage Location'
                    },
                    {
                        xtype: 'datecolumn',
                        itemId: 'colDate',
                        dataIndex: 'dtmDate',
                        text: 'Date'
                    },
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colTransactionForm',
                        dataIndex: 'strTransactionForm',
                        text: 'Transaction Form'
                    },
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colTransactionId',
                        dataIndex: 'strTransactionId',
                        text: 'Transaction Id'
                    },
                    {
                        xtype: 'numbercolumn',
                        summaryType: 'sum',
                        itemId: 'colQuantity',
                        dataIndex: 'dblQuantity',
                        text: 'Quantity'
                    },
                    {
                        xtype: 'numbercolumn',
                        summaryType: 'sum',
                        itemId: 'colCost',
                        dataIndex: 'dblCost',
                        text: 'Cost'
                    },
                    {
                        xtype: 'numbercolumn',
                        summaryType: 'sum',
                        itemId: 'colValue',
                        dataIndex: 'dblValue',
                        text: 'Value'
                    },
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colBatch',
                        dataIndex: 'strBatchId',
                        text: 'Batch Id'
                    }
                ],
                features: [
                    {
                        ftype: 'grouping'
                    }
                ]
            })
        });

        return win.context;
    },

    show : function() {
        "use strict";
        var me = this;
        me.getView().show();
        var context = me.setupContext();
        context.data.load();
    }
});
