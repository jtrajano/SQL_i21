Ext.define('Inventory.view.InventoryValuationSummaryViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icinventoryvaluationsummary',

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
            Ext.create('iRely.Engine', {
                window : win,
                store  : Ext.create('Inventory.store.BufferedInventoryValuation', { pageSize: 1 }),
                binding: me.config.binding,
                showNew: false
            });

        win.context = context;
        return context;
    }
});
