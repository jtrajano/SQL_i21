Ext.define('Inventory.view.override.ItemPricingViewController', {
    override: 'Inventory.view.ItemPricingViewController',

    config: {
        binding: {
            cboLocation: {
                value: '{current.intLocationId}',
                store: '{Location}'
            },
            txtSalePrice: '{current.dblSalePrice}',
            txtRetailPrice: '{current.dblRetailPrice}',
            txtWholesalePrice: '{current.dblWholesalePrice}',
            txtLargeVolumePrice: '{current.dblLargeVolumePrice}',
            txtMsrp: '{current.dblMSRPPrice}',
            cboPricingMethod: {
                value: '{current.strPricingMethod}',
                store: '{PricingMethods}'
            },
            txtLastCost: '{current.dblLastCost}',
            txtStandardCost: '{current.dblStandardCost}',
            txtAverageCost: '{current.dblMovingAverageCost}',
            txtEndofMonthCost: '{current.dblEndMonthCost}',
            chkActive: '{current.ysnActive}'
        }
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.ItemPricing', { pageSize: 1 });


        win.context = Ext.create('iRely.mvvm.Engine', {
            window : win,
            store  : store,
            binding: me.config.binding,
            createRecord: {
                fn: me.createRecord,
                scope: me
            }
        });

        return win.context;
    },

    show : function(config) {
        "use strict";

        var me = this,
            win = this.getView();

        if (config) {
            win.show();

            var context = me.setupContext( { window : win } );
            me.intItemId = config.id;
            if (config.action === 'new') {
                context.data.addRecord();
            } else {
                var filter = [{
                    column: 'intItemId',
                    value: config.id
                }];
                context.data.load({
                    filters: filter
                });
            }
        }
    },

    createRecord: function(config, action) {
        var me = this;
        var record = Ext.create('Inventory.model.ItemPricing');
        record.set('intItemId', me.intItemId);
        action(record);
    }
    
});