Ext.define('Inventory.view.override.ContractDocumentViewController', {
    override: 'Inventory.view.ContractDocumentViewController',

    config: {
        searchConfig: {
            title:  'Search Contract Document',
            type: 'Inventory.Document',
            api: {
                read: '../Inventory/api/Document/SearchDocuments'
            },
            columns: [
                {dataIndex: 'intDocumentId',text: "Document Id", flex: 1, defaultSort:true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strDocumentName', text: 'Document Name', flex: 1,  dataType: 'string'},
                {dataIndex: 'strDescription', text: 'Description', flex: 1,  dataType: 'string'},
                {dataIndex: 'ysnStandard',text: 'Standard', flex: 1,  dataType: 'boolean', xtype: 'checkcolumn'}
            ]
        },
        binding: {
            txtDocumentName: '{current.strDocumentName}',
            txtDescription: '{current.strDescription}',
            cboCommodity: {
                value: '{current.intCommodityId}',
                store: '{Commodity}'
            },
            chkStandard: '{current.ysnStandard}'
        }
    },

    setupContext : function(options){
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Document', { pageSize: 1 });

        win.context = Ext.create('iRely.mvvm.Engine', {
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
                        column: 'intDocumentId',
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