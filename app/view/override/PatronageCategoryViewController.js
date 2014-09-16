Ext.define('Inventory.view.override.PatronageCategoryViewController', {
    override: 'Inventory.view.PatronageCategoryViewController',

    config: {
       /* searchConfig: {
            title:  'Search Patronage Category',
            type: 'Inventory.PatronageCategory',
            api: {
                read: '../Inventory/api/PatronageCategory/SearchPatronageCategories'
            },
            columns: [
                {dataIndex: 'intPatronageCategoryId',text: "PatronageCategory Id", flex: 1, defaultSort:true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strCategoryCode', text: 'Category Code', flex: 1,  dataType: 'string'},
                {dataIndex: 'strDescription', text: 'Description', flex: 1,  dataType: 'string'},
                {dataIndex: 'strPurchaseSale',text: 'Purchase/Sale', flex: 1,  dataType: 'string'},
                {dataIndex: 'strUnitAmount',text: 'Unit/Amount', flex: 1,  dataType: 'string'}
            ]
        }*/
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.PatronageCategory', { pageSize: 1 });

        win.context = Ext.create('iRely.Engine', {
            window : win,
            store  : store,
            paging : win.down('pagingtoolbar'),
            singleGridMgr: Ext.create('iRely.grid.Manager', {
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
                        filters: config.filter
                    });
                }

        }
    }

});