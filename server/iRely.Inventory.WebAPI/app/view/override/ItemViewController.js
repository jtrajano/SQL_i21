Ext.define('Inventory.view.override.ItemViewController', {
    override: 'Inventory.view.ItemViewController',

    config: {
        searchConfig: {
            title:  'Search Item',
            type: 'Inventory.Item',
            api: {
                read: '../Inventory/api/Item/SearchItems'
            },
            columns: [
                {dataIndex: 'intItemId',text: "Item Id", flex: 1, defaultSort:true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strItemNo', text: 'Item No', flex: 1,  dataType: 'string'},
                {dataIndex: 'strDescription', text: 'Description', flex: 1,  dataType: 'string'},
                {dataIndex: 'strModelNo',text: 'Model No', flex: 1,  dataType: 'string'}
            ]
        },
        binding: {
//            cboScreenName: {
//                value: '{current.strScreen}',
//                store: '{screens}',
//                readOnly: '{current.ysnBuild}'
//            },
            txtItemNo: '{current.strItemNo}',
            txtDescription: '{current.strDescription}'
        }
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Item', { pageSize: 1 });

        win.context = Ext.create('iRely.Engine', {
            window : win,
            store  : store,
            createRecord : me.createRecord,
            paging: win.down('pagingtoolbar'),
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

            Ext.require('Inventory.store.Item', function() {
                var context = me.setupContext( {window : win} );

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
            });
        }
    }

});