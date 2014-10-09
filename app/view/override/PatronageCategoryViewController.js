Ext.define('Inventory.view.override.PatronageCategoryViewController', {
    override: 'Inventory.view.PatronageCategoryViewController',

    config: {
       binding:
       {
           colCategoryCode : 'strCategoryCode',
           colDescription :  'strDescription',
           colPurchaseSale : 'strPurchaseSale',
           colUnitAmount :   'strUnitAmount'
        }
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.PatronageCategory', { pageSize: 1 });

        win.context = Ext.create('iRely.mvvm.Engine', {
            binding: me.config.binding,
            window : win,
            store  : store,
            singleGridMgr: Ext.create('iRely.mvvm.grid.Manager', {
                grid:  win.down('#grdPatronageCategory'),
                deleteButton: win.down('#btnDeletePatronage')
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
                        config.filter = [{
                            column: 'intPatronageCategoryId',
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