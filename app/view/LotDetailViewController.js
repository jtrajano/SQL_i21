Ext.define('Inventory.view.LotDetailViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.iclotdetail',

    setupContext : function(){
        "use strict";
        var win = this.getView();
        win.context = Ext.create('iRely.mvvm.Engine', {
            window: win,
            store: Ext.create('Inventory.store.Lot'),
            singleGridMgr: Ext.create('iRely.mvvm.grid.Manager', {
                grid: win.down('grid'),
                title: 'View Lot Details',
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
                        dataIndex: 'strItemDescription',
                        text: 'Description'
                    },
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colLocation',
                        dataIndex: 'strLocationName',
                        text: 'Location Name'
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
                        dataIndex: 'strStorageLocation',
                        text: 'Storage Location'
                    },
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colLotNumber',
                        dataIndex: 'strLotNumber',
                        text: 'Lot Number'
                    },
                    {
                        xtype: 'numbercolumn',
                        summaryType: 'sum',
                        itemId: 'colQuantity',
                        dataIndex: 'dblQty',
                        text: 'Quantity'
                    },
                    {
                        xtype: 'numbercolumn',
                        summaryType: 'sum',
                        itemId: 'colWeight',
                        dataIndex: 'dblWeight',
                        text: 'Weight'
                    },
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colUOM',
                        dataIndex: 'strItemUOM',
                        text: 'UOM'
                    },
                    {
                        xtype: 'numbercolumn',
                        summaryType: 'sum',
                        itemId: 'colWeightPerQty',
                        dataIndex: 'dblWeightPerQty',
                        text: 'Weight Per Qty'
                    },
                    {
                        xtype: 'numbercolumn',
                        summaryType: 'sum',
                        itemId: 'colLastCost',
                        dataIndex: 'dblLastCost',
                        text: 'Last Cost'
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
