Ext.define('Inventory.view.PickLotViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icpicklot',

    config: {
        binding: {
            grdLotDetails: {
                store: '{grdPickLots.selection.detail}',
                columns: [
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colLotNo',
                        text: 'Lot No',
                        flex: 1
                    },
                    {
                        xtype: 'numbercolumn',
                        itemId: 'colLotPickedQty',
                        text: 'Picked Qty',
                        flex: 1
                    },
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colLotUOM',
                        text: 'UOM',
                        flex: 1
                    },
                    {
                        xtype: 'numbercolumn',
                        itemId: 'colLotWeight',
                        text: 'Weight',
                        flex: 1
                    },
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colLotWeightUOM',
                        text: 'Weight UOM',
                        flex: 1
                    },
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colLotStorageLocation',
                        text: 'Storage Location',
                        flex: 1
                    }
                ]
            }
        }
    },

    setupContext: function () {
        "use strict";
        var win = this.getView();
        win.context = Ext.create('iRely.mvvm.Engine', {
            window: win,
//            binding: this.config.binding,
            store: Ext.create('Logistics.store.PickLotHeader'),
            singleGridMgr: Ext.create('iRely.mvvm.grid.Manager', {
                grid: win.down('#grdPickLots'),
                title: 'Pick Lots',
                position: 'none',
                columns: [
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colPickLotNo',
                        text: 'Pick Lot No'
                    },
                    {
                        xtype: 'datecolumn',
                        itemId: 'colPickDate',
                        text: 'Pick Date'
                    },
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colSalesContractNo',
                        text: 'Sales Contract No'
                    },
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colItemNo',
                        text: 'Item No'
                    },
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colItemDescription',
                        text: 'Description'
                    },
                    {
                        xtype: 'numbercolumn',
                        itemId: 'colOrderQty',
                        text: 'Order Qty'
                    },
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colUOM',
                        text: 'UOM'
                    },
                    {
                        xtype: 'numbercolumn',
                        itemId: 'colPickedQty',
                        text: 'Picked Qty'
                    },
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colPickedUOM',
                        text: 'Picked UOM'
                    },
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colSubLocation',
                        text: 'Sub Location'
                    }
                ]
            })
        });
        return win.context;
    },

    show: function () {
        "use strict";
        var me = this;
        me.getView().show();
        var context = me.setupContext();
        context.data.load();
    }
});
