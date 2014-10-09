Ext.define('Inventory.view.override.FactoryUnitTypeViewController', {
    override: 'Inventory.view.FactoryUnitTypeViewController',

    config: {
        searchConfig: {
            title:  'Search Factory Unit Type',
            type: 'Inventory.FactoryUnitType',
            api: {
                read: '../Inventory/api/UnitType/SearchUnitTypes'
            },
            columns: [
                {dataIndex: 'intUnitTypeId',text: "UnitType Id", flex: 1, defaultSort:true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strUnitType', text: 'Unit Type', flex: 1,  dataType: 'string'},
                {dataIndex: 'strDescription', text: 'Description', flex: 1,  dataType: 'string'}
                ]
        },
        binding: {
            txtName: '{current.strUnitType}',
            txtDescription: '{current.strDescription}',
            cboInternalCode: {
                value: '{current.strInternalCode}',
                store: '{internalCodes}'
            },
            cboCapacityUom: {
                value: '{current.intCapacityUnitMeasureId}',
                store: '{UnitMeasure}'
            },

            txtMaxWeight : '{current.dblMaxWeight}',
            chkAllowsPicking : '{current.ysnAllowPick}',
            cboDimensionUom : {
                value: '{current.intDimensionUnitMeasureId}',
                store: '{UnitMeasure}'
            },
            txtHeight : '{current.dblHeight}',
            txtDepth : '{current.dblDepth}',
            txtWidth : '{current.dblWidth}',
            txtPalletStack : '{current.intPalletStack}',
            txtPalletColumns : '{current.intPalletColumn}',
            txtPalletRows : '{current.intPalletRow}'
        }
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.FactoryUnitType', { pageSize: 1 });

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
                        column: 'intUnitTypeId',
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