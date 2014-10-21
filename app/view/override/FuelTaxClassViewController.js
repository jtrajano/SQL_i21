Ext.define('Inventory.view.override.FuelTaxClassViewController', {
    override: 'Inventory.view.FuelTaxClassViewController',

    config: {
        searchConfig: {
            title:  'Search Fuel Tax Class',
            type: 'Inventory.FuelTaxClass',
            api: {
                read: '../Inventory/api/FuelTaxClass/SearchFuelTaxClasses'
            },
            columns: [
                {dataIndex: 'intFuelTaxClassId',text: "Fuel Tax Class Id", flex: 1, defaultSort:true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strTaxClassCode', text: 'Fuel Tax Class', flex: 1,  dataType: 'string'},
                {dataIndex: 'strDescription', text: 'Description', flex: 1,  dataType: 'string'},
                {dataIndex: 'strIRSTaxCode', text: 'IRS Tax Code', flex: 1,  dataType: 'string'}
            ]
        },
        binding: {
            txtTaxClassCode: '{current.strTaxClassCode}',
            txtIrsTaxCode: '{current.strIRSTaxCode}',
            txtDescription: '{current.strDescription}',

            colState: 'strState',
            colProductCode: 'strProductCode'

        }
    },

    setupContext : function(options){
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.FuelTaxClass', { pageSize: 1 });

        win.context = Ext.create('iRely.mvvm.Engine', {
            window : win,
            store  : store,
            binding: me.config.binding,
            details: [
                {
                    key: 'tblICFuelTaxClassProductCodes',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: win.down('#grdProductCode'),
                        deleteButton: win.down('#btnDeleteProductCode')
                    })
                }
            ]
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
                        column: 'intFuelTaxClassId',
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