Ext.define('Inventory.view.override.FeedStockUomViewController', {
    override: 'Inventory.view.FeedStockUomViewController',
    config: {
        binding: {
            colUOM : 'intUnitMeasureId',
            colUOMCode : 'strRinFeedStockUOMCode'
        }
    },

    setupContext : function(options){
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.FeedStockUom', { pageSize: 1 });

        var grdFeedStockUom = win.down('#grdFeedStockUom');

        win.context = Ext.create('iRely.mvvm.Engine', {
            binding: me.config.binding,
            window : win,
            store  : store,
            singleGridMgr: Ext.create('iRely.mvvm.grid.Manager', {
                grid:  grdFeedStockUom,
                deleteButton: win.down('#btnDeleteFeedStockUom')
            })
        });


        var colUom = grdFeedStockUom.columns[0];
        colUom.renderer = me.UomRenderer;

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
                        column: 'intRinFeedStockUOMId',
                        value: config.id
                    }];
                }
                context.data.load({
                    filters: config.filters
                });
            }
        }
    },

    UomRenderer: function (value, metadata, record) {
        var strUnitMeasure = record.get('strUnitMeasure');
        return strUnitMeasure;
    }

});
