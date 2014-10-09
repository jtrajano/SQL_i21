Ext.define('Inventory.view.override.FuelCodeViewController', {
    override: 'Inventory.view.FuelCodeViewController',

    config: {
        binding: {
            colFuelCode : 'strRinFuelCode',
            colDescription : 'strDescription'
        }
    },

    setupContext : function(options){
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.FuelCode', { pageSize: 1 });

        win.context = Ext.create('iRely.mvvm.Engine', {
            binding: me.config.binding,
            window : win,
            store  : store,
            singleGridMgr: Ext.create('iRely.mvvm.grid.Manager', {
                grid:  win.down('#grdFuelCode'),
                deleteButton: win.down('#btnDeleteFuelCode')
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
                        column: 'intRinFuelId',
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