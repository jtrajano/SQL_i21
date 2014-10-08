Ext.define('Inventory.view.override.InventoryUOMViewController', {
    override: 'Inventory.view.InventoryUOMViewController',

    config: {
        binding: {
            colUOM: 'strUnitMeasure',
            colSymbol: 'strSymbol',
            colUnitType: 'strUnitType',
            colDefault: 'ysnDefault'
        }
    },

    setupContext : function(options){
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.UnitMeasure');

        win.context = Ext.create('iRely.Engine', {
            binding: me.config.binding,
            window : win,
            store  : store,
            singleGridMgr: Ext.create('iRely.grid.Manager', {
                grid:  win.down('#grdUOM'),
                deleteButton: win.down('#btnDeleteUOM')
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
                        column: 'intUnitMeasureId',
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