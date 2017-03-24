Ext.define('Inventory.view.InventoryCountGroupViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icinventorycountgroup',

    config: {
        searchConfig: {
            title: 'Search Inventory Count Group',
            type: 'Inventory.InventoryCountGroup',
            api: {
                read: '../Inventory/api/CountGroup/Search'
            },
            columns: [
                {dataIndex: 'intCountGroupId', text: "Count Group Id", flex: 1, defaultSort: true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strCountGroup', text: 'Count Group', flex: 1, dataType: 'string'}
            ]
        },
        binding: {
            bind: {
                title: 'Inventory Count Group - {current.strCountGroup}'
            },
            txtCountGroup: '{current.strCountGroup}',
            txtCountsPerYear: '{current.intCountsPerYear}',
            chkIncludeOnHand: '{current.ysnIncludeOnHand}',
            chkScannedCountEntry: '{current.ysnScannedCountEntry}',
            chkCountByLots: '{current.ysnCountByLots}',
            chkCountByPallets: '{current.ysnCountByPallets}',
            chkRecountMismatch: '{current.ysnRecountMismatch}',
            chkExternal: '{current.ysnExternal}'
        }
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.CountGroup', { pageSize: 1 });

        win.context = Ext.create('iRely.Engine', {
            window : win,
            store  : store,
            createRecord : me.createRecord,
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
                        column: 'intCountGroupId',
                        value: config.id
                    }];
                }
                context.data.load({
                    filters: config.filters
                });
            }
        }
    },

    init: function(application) {
        this.control({
            
        });
    }
});
