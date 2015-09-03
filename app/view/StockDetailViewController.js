Ext.define('Inventory.view.StockDetailViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icstockdetail',

    setupContext : function(){
        "use strict";
        var win = this.getView();
        win.context = Ext.create('iRely.mvvm.Engine', {
            window: win,
            store: Ext.create('Inventory.store.ItemStockView'),
            singleGridMgr: Ext.create('iRely.mvvm.grid.Manager', {
                grid: win.down('grid'),
                title: 'View Stock Details',
                columns: [
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colItemNo',
                        dataIndex: 'strItemNo',
                        text: 'Item No'
                    },
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colDescription',
                        dataIndex: 'strDescription',
                        text: 'Description'
                    },
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colLocation',
                        dataIndex: 'strLocationName',
                        text: 'Location Name'
                    },
                    {
                        xtype: 'numbercolumn',
                        summaryType: 'sum',
                        itemId: 'colOnHand',
                        dataIndex: 'dblUnitOnHand',
                        text: 'On Hand'
                    },
                    {
                        xtype: 'numbercolumn',
                        summaryType: 'sum',
                        itemId: 'colCommitted',
                        dataIndex: 'dblOrderCommitted',
                        text: 'Committed'
                    },
                    {
                        xtype: 'numbercolumn',
                        summaryType: 'sum',
                        itemId: 'colOnOrder',
                        dataIndex: 'dblOnOrder',
                        text: 'On Order'
                    },
                    {
                        xtype: 'numbercolumn',
                        summaryType: 'sum',
                        itemId: 'colBackOrder',
                        dataIndex: 'dblBackOrder',
                        text: 'Back Order'
                    },
                    {
                        xtype: 'numbercolumn',
                        itemId: 'colLastCost',
                        dataIndex: 'dblLastCost',
                        text: 'Last Cost'
                    },
                    {
                        xtype: 'numbercolumn',
                        itemId: 'colAverageCost',
                        dataIndex: 'dblAverageCost',
                        text: 'Average Cost'
                    },
                    {
                        xtype: 'numbercolumn',
                        itemId: 'colStandardCost',
                        dataIndex: 'dblStandardCost',
                        text: 'Standard Cost'
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
