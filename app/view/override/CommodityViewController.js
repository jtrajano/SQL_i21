Ext.define('Inventory.view.override.CommodityViewController', {
    override: 'Inventory.view.CommodityViewController',

    config: {
        searchConfig: {
            title:  'Search Commodity',
            type: 'Inventory.Commodity',
            api: {
                read: '../Inventory/api/Commodity/SearchCommodities'
            },
            columns: [
                {dataIndex: 'intCommodityId',text: "Commodity Id", flex: 1, defaultSort:true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strCommodityCode', text: 'Commodity Code', flex: 1,  dataType: 'string'},
                {dataIndex: 'strDescription', text: 'Description', flex: 1,  dataType: 'string'}
            ]
        },
        binding: {

        }
    },

    setupContext : function(options){
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Commodity', { pageSize: 1 });

        win.context = Ext.create('iRely.Engine', {
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
                        column: 'intCommodityId',
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