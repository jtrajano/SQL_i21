Ext.define('Inventory.view.override.InventoryTagViewController', {
    override: 'Inventory.view.InventoryTagViewController',

    config: {
        searchConfig: {
            title:  'Search Inventory Tag',
            type: 'Inventory.Tag',
            api: {
                read: '../Inventory/api/Tag/SearchTags'
            },
            columns: [
                {dataIndex: 'intTagId',text: "Tag Id", flex: 1, defaultSort:true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strTagNumber', text: 'Tag No', flex: 1,  dataType: 'string'},
                {dataIndex: 'strDescription', text: 'Description', flex: 1,  dataType: 'string'},
                {dataIndex: 'ysnHazMat',text: 'HAZMAT', flex: 1,  dataType: 'boolean'}
            ]
        },
        binding: {
            txtTagNumber: '{current.strTagNumber}',
            txtDescription: '{current.strDescription}',
            chkHAZMATMessage: '{current.ysnHazMat}',
            txtMessage: '{current.strMessage}'
        }
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.InventoryTag', { pageSize: 1 });

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
                    config.filter = [{
                        column: 'intTagId',
                        value: config.id
                    }];
                }
                context.data.load({
                    filters: config.filter
                });
            }
        }
    }

});