Ext.define('Inventory.view.override.FeedStockCodeViewController', {
    override: 'Inventory.view.FeedStockCodeViewController',

    config: {
        binding: {
            colFeedStockCode : 'strRinFeedStockCode',
            colDescription : 'strDescription'
        }
    },

    setupContext : function(options){
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.FeedStockCode', { pageSize: 1 });

        win.context = Ext.create('iRely.Engine', {
            binding: me.config.binding,
            window : win,
            store  : store,
            singleGridMgr: Ext.create('iRely.grid.Manager', {
                grid:  win.down('#grdFeedStockCode'),
                deleteButton: win.down('#btnDeleteFeedStockCode')
            })
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
                        column: 'intRinFeedStockId',
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