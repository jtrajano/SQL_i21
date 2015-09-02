Ext.define('Inventory.view.LotDetailViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.iclotdetail',

    config: {
        binding: {
            grdLotDetail: {
                colItemNo: 'strItemNo',
                colDescription: 'strDescription',
                colLocation: 'strLocationName',
                colSubLocation: 'dblUnitOnHand',
                colStorageLocation: 'dblUnitOnHand',
                colLotNumber: 'dblUnitOnHand',
                colQuantity: 'dblOrderCommitted',
                colWeight: 'dblBackOrder',
                cboUOM: 'dblLastCost',
                colWeightPerQty: 'dblAverageCost',
                colLastCost: 'dblBackOrder'
            }
        }
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.StorageUnitType', { pageSize: 1 });

        win.context = Ext.create('iRely.mvvm.Engine', {
            window : win,
            store  : store,
            binding: me.config.binding
        });

        return win.context;
    },

    show : function(config) {
        "use strict";

        var me = this,
            win = this.getView();

        if (config) {
            win.show();

            var context = me.setupContext( {window : win} );

            if (config.action === 'new') {
                context.data.addRecord();
            } else {
                if (config.id) {
                    config.filters = [{
                        column: 'intStorageUnitTypeId',
                        value: config.id
                    }];
                }
                context.data.load({
                    filters: config.filters
                });
            }
        }
    }
});
