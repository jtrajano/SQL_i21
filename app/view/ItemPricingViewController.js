Ext.define('Inventory.view.ItemPricingViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icitempricing',

    config: {
        binding: {
            cboLocation: {
                value: '{current.intItemLocationId}',
                store: '{Location}',
                defaultFilters: [{
                    column: 'intItemId',
                    value: '{current.intItemId}'
                }]
            },
            txtSalePrice: '{current.dblSalePrice}',
            txtMsrp: '{current.dblMSRPPrice}',
            cboPricingMethod: {
                value: '{current.strPricingMethod}',
                store: '{PricingMethods}'
            },
            txtAmountPercent: {
                value: '{current.dblAmountPercent}',
                fieldLabel: '{getAmountPercentLabel}',
                readOnly: '{getAmountPercentReadOnly}'
            },
            txtLastCost: '{current.dblLastCost}',
            txtStandardCost: '{current.dblStandardCost}',
            txtAverageCost: '{current.dblAverageCost}',
            txtEndofMonthCost: '{current.dblEndMonthCost}'
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
            me.intItemId = config.itemId;
            me.defaultLocation = config.defaultLocation;

            if (config.action === 'new') {
                context.data.addRecord();
            } else {
                var filter = [{
                        column: 'intItemId',
                        value: config.itemId,
                        conjunction: 'and'
                    },{
                        column: 'intItemPricingId',
                        value: config.priceId,
                        conjunction: 'and'
                    }
                ];
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
        if (me.defaultLocation > 0)
            record.set('intItemLocationId', me.defaultLocation);
        action(record);
    }
});
