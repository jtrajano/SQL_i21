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
            txtItemNo: '{current.strItemNo}',
            txtDescription: '{current.strDescription}',
            txtModelNo: '{current.strModelNo}',
            cboType: {
                value: '{current.strType}',
                store: '{ItemTypes}'
            },
            cboManufacturer: '{current.intManufacturerId}',
            cboBrand: '{current.intBrandId}',
            cboStatus: {
                value: '{current.strStatus}',
                store: '{ItemStatuses}'
            },
            cboLotTracking: {
                value: '{current.strLotTracking}',
                store: '{LotTrackings}'
            },
            cboTracking: '{current.intTrackingId}',
            //UOM Grid Columns
            colDetailUnitMeasure: 'intUnitMeasureId',
            colDetailUnitQty: 'dblUnitQty',
            colDetailSellQty: 'dblSellQty',
            colDetailWeight: 'dblWeight',
            colDetailDescription: 'strDescription',
            colDetailLength: 'dblLength',
            colDetailWidth: 'dblWidth',
            colDetailHeight: 'dblHeight',
            colDetailVolume: 'dblVolume',
            colDetailMaxQty: 'dblMaxQty',
            //Location Store Grid Columns
            colLocStoreLocation: 'intLocationId',
            colLocStoreStore: 'intStoreId',
            colLocStorePOSDescription: 'strPOSDescription',
            colLocStoreCategory: 'intCategoryId',
            colLocStoreVendor: 'intVendorId',
            colLocStoreCostingMethod: 'strCostingMethod',
            colLocStoreUOM: 'intDefaultUOMId'
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
            binding: me.config.binding,
            details: [{
                key: 'tblICItemUOMs',
                component: Ext.create('iRely.grid.Manager', {
                    grid: win.down('#grdUnitOfMeasure')
                })
            },
            {
                key: 'tblSMCustomFieldValues',
                component: Ext.create('iRely.grid.Manager', {
                    grid: win.down('#grdValue'),
                    deleteButton : win.down('#btnDeleteValue')
                })
            }]
        });

//        var cboType = win.down('#cboType');
//        cboType.forceSelection = true;
//
//        var cboStatus = win.down('#cboStatus');
//        cboStatus.forceSelection = true;
//
//        var cboLotTracking = win.down('#cboLotTracking');
//        cboLotTracking.forceSelection = true;

        return win.context;
    },

    show : function(config) {
        "use strict";

        var me = this,
            win = this.getView();

        if (config) {
            win.show();

//            Ext.require('Inventory.store.Item', function() {
                var context = me.setupContext( {window : win} );

                if (config.action === 'new') {
                    context.data.addRecord();
                } else {
                    if (config.id) {
                        config.filters = [{
                            column: 'intItemId',
                            value: config.id
                        }];
                    }
//                if (config.param) {
//                    console.log(config.param);
//                }
                    context.data.load({
                        filters: config.filters
                    });
                }
//            });
        }
    }

});