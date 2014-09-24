Ext.define('Inventory.view.override.FuelTypeViewController', {
    override: 'Inventory.view.FuelTypeViewController',

    config: {
        searchConfig: {
            title:  'Search Fuel Type',
            type: 'Inventory.FuelType',
            api: {
                read: '../Inventory/api/FuelType/SearchFuelTypes'
            },
            columns: [
                {dataIndex: 'intFuelTypeId',text: "Fuel Type", flex: 1, defaultSort:true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strRinFuelTypeCodeId', text: 'Fuel Type', flex: 1,  dataType: 'string'},
                {dataIndex: 'strRinFeedStockId', text: 'Feed Stock', flex: 1,  dataType: 'string'},
                {dataIndex: 'strRinFuelId', text: 'Fuel Code', flex: 1,  dataType: 'string'},
                {dataIndex: 'strRinProcessId', text: 'Process Code', flex: 1,  dataType: 'string'},
                {dataIndex: 'strRinFeedStockUOMId', text: 'Feed Stock UOM', flex: 1,  dataType: 'string'}
            ]
        },
        binding: {
            txtBatchNo: '{current.intBatchNumber}',
            txtEndingRinGallonsForBatch: '{current.intEndingRinGallons}',
            txtEquivalenceValue: '{current.intEquivalenceValue}',
            txtFeedStockFactor: '{current.dblFeedStockFactor}',
            chkRenewableBiomass: '{current.ysnRenewableBiomass}',
            txtPercentOfDenaturant: '{current.dblPercentDenaturant}',
            chkDeductDenaturantFromRin: '{current.ysnDeductDenaturant}',
            cboFuelType: {
                value: '{current.intRinFuelTypeId}',
                store: '{FuelCategory}'
            },
            cboFeedStock: {
                value: '{current.intRinFeedStockId}',
                store: '{FeedStockCode}'
            },
            cboFuelCode: {
                value: '{current.intRinFuelId}',
                store: '{FuelCode}'
            },
            cboProcessCode: {
                value: '{current.intRinProcessId}',
                store: '{ProcessCode}'
            },
            cboFeedStockUom: {
                value: '{current.intRinFeedStockUOMId}',
                store: '{FeedStockUom}'
            }
        }
    },

    setupContext : function(options){
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.FuelType', { pageSize: 1 });

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
                        column: 'intFuelTypeId',
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