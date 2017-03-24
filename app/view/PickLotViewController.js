Ext.define('Inventory.view.PickLotViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icpicklot',

    config: {
        binding: {
            grdPickLots: {
                colPickLotNo: 'intReferenceNumber',
                colPickDate: 'dtmPickDate',
                colSubLocation: 'strWarehouse'
            },

            grdLotDetails: {
                store: '{grdPickLots.selection.vyuLGDeliveryOpenPickLotDetails}',
                colSalesContractNo: 'strSContractNumber',
                colItemNo: 'strItemNo',
                colDescription: 'strItemDescription',
                colOrderQty: 'dblSalePickedQty',
                colLotUOM: 'strSaleUnitMeasure',
                colPickedQty: 'dblLotPickedQty',
                colPickedUOM: 'strLotUnitMeasure'
            }
        }
    },

    setupContext: function () {
        "use strict";
        var win = this.getView();
        win.context = Ext.create('iRely.Engine', {
            window: win,
            binding: this.config.binding,
            store: Ext.create('Logistics.store.PickedLots'),
            singleGridMgr: Ext.create('iRely.grid.Manager', {
                grid: win.down('#grdPickLots'),
                title: 'Pick Lots',
                position: 'none'
            })
        });
        return win.context;
    },

    show: function (config) {
        "use strict";
        var me = this;
        me.getView().show();
        var context = me.setupContext();
        config.filters = [
            {
                column: 'intCustomerEntityId',
                value: config.param.intCustomerId,
                conjunction: 'and'
            },
            {
                column: 'intCompanyLocationId',
                value: config.param.intShipFromId,
                conjunction: 'and'
            },
            {
                column: 'ysnShipped',
                value: false,
                conjunction: 'and'
            }
        ];
        context.data.load({
            filters: config.filters
        });
    },

    onAddClick: function(button) {
        var win = button.up('window');
        var grid = win.down('#grdPickLots');

        var selection = grid.getSelectionModel().getSelection();
        if (selection) {
            if (selection.length > 0) {
                win.AddPickLots = selection;
                win.close();
                return;
            }
        }

        iRely.Functions.showErrorDialog('Please select a pick lot to add.');
    },

    init: function(application) {
        this.control({
            "#btnAdd": {
                click: this.onAddClick
            }
        });
    }
});
