Ext.define('Inventory.view.override.ItemViewController', {
    override: 'Inventory.view.ItemViewController',

    config: {
        searchConfig: {
            title:  'Search Custom Field',
            type: 'GlobalComponentEngine.CustomField',
            api: {
                read: '../GlobalComponentEngine/api/CustomField/GetCustomFields'
            },
            columns: [
                {dataIndex: 'intCustomFieldId',text: "Custom Field ID", flex: 1, defaultSort:true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strScreen', text: 'Screen', flex: 1,  dataType: 'string'},
                {dataIndex: 'strModule', text: 'Module', flex: 1,  dataType: 'string'},
                {dataIndex: 'strTabName',text: 'Tab Name', flex: 1,  dataType: 'string'},
                {dataIndex: 'strDescription', text: 'Description', flex: 2,  dataType: 'string'}
            ]
        },
        binding: {
            cboScreenName: {
                value: '{current.strScreen}',
                store: '{screens}',
                readOnly: '{current.ysnBuild}'
            },
            cboLayout: '{current.strLayout}',
            txtModule: '{current.strModule}',
            txtTabName: '{current.strTabName}',
            txtDescription: '{current.strDescription}'
        }
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Item', { pageSize: 1 });

        win.context = Ext.create('iRely.Framework', {
            window : win,
            store  : store,
            createRecord : me.createRecord,
            binding: me.config.binding
//            details: [{
//                key: 'tblSMCustomFieldDetails',
//                component: Ext.create('iRely.grid.Manager', {
//                    grid: win.down('#grdCustomFields'),
//                    deleteButton : win.down('#btnDeleteDetail'),
//                    createRecord : me.createDetailRecord,
//                    deleteRecord : me.deleteDetailRecord
//                }),
//                details: [{
//                    key: 'tblSMCustomFieldValues',
//                    component: Ext.create('iRely.grid.Manager', {
//                        grid: win.down('#grdValue'),
//                        deleteButton : win.down('#btnDeleteValue')
//                    })
//                }]
//            }]
        });

        return win.context;
    },

    show : function(config) {
        "use strict";

        var me = this,
            win = this.getView();

        if (config) {
            win.show();

            var context = me.setupContext(win);

            if (config.action === 'new') {
                context.data.addRecord();
            } else {
                if (config.id) {
                    config.filter = [{
                        column: 'intCustomFieldId',
                        value: config.id
                    }];
                }
//                if (config.param) {
//                    console.log(config.param);
//                }
                context.data.load({
                    filters: config.filter
                });
            }
        }
    }

});