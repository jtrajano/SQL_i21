Ext.define('Inventory.view.InventoryCountDetailsViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icinventorycountdetails',

    config: {
        binding: {
            bind: {
                title: 'Inventory Count Detail - {current.strLineCountNo}'
            },
            cboItem: {
                store: '{items}',
                value: '{current.strItemNo}',
                origValueField: 'intItemId',
                defaultFilters: [
                    {
                        column: 'intLocationId',
                        value: '{inventoryCount.intLocationId}'
                    }
                ],
                hidden: '{isCountByGroup}'
            },
            
            cboCountGroup: {
                store: '{countGroup}',
                value: '{current.strCountGroup}',
                origValueField: 'intCountGroupId',
                hidden: '{!isCountByGroup}'
            },
            txtDescription: {
                value: '{current.strItemDescription}',
                hidden: '{isCountByGroup}'
            },
            txtQtyReceived: {
                value: '{current.dblQtyReceived}'   ,
                hidden: '{!isCountByGroup}'
            },
            txtQtySold: {
                value: '{current.dblQtySold}'   ,
                hidden: '{!isCountByGroup}'
            },
            cboStorageLocation: {
                store: '{storageLocations}',
                value: '{current.strSubLocationName}',
                origValueField: 'intSubLocationId',
                origUpdateField: 'intSubLocationId',
                hidden: '{isCountByGroup}',
                defaultFilters: [
                    {
                        column: 'intItemId',
                        value: '{current.intItemId}',
                        conjunction: 'and'
                    },
                    {
                        column: 'intCompanyLocationId',
                        value: '{inventoryCount.intLocationId}',
                        conjunction: 'and'
                    },
                    {
                        column: 'strClassification',
                        value: 'Inventory',
                        conjunction: 'and'
                    }
                ]
            },
            cboStorageUnit: {
                store: '{storageUnits}',
                value: '{current.strStorageLocationName}',
                origValueField: 'intStorageLocationId',
                hidden: '{isCountByGroup}',
                defaultFilters: [
                    {
                        column: 'intItemId',
                        value: '{current.intItemId}',
                        conjunction: 'and'
                    },
                    {
                        column: 'intLocationId',
                        value: '{inventoryCount.intLocationId}',
                        conjunction: 'and'
                    },
                    {
                        column: 'intSubLocationId',
                        value: '{current.intSubLocationId}',
                        conjunction: 'and'
                    }
                ]
            },
            cboLotNo: {
                store: '{lots}',
                value: '{current.strLotNo}',
                origValueField: 'intLotId',
                hidden: '{isCountByGroup}',
                forceSelection: '{forceSelection}',
                defaultFilters: [
                    {
                        column: 'intItemId',
                        value: '{current.intItemId}',
                        conjunction: 'and'
                    },
                    {
                        column: 'intLocationId',
                        value: '{inventoryCount.intLocationId}',
                        conjunction: 'and'
                    },
                    {
                        column: 'intSubLocationId',
                        value: '{current.intSubLocationId}',
                        conjunction: 'and'
                    },
                    {
                        column: 'intStorageLocationId',
                        value: '{current.intStorageLocationId}',
                        conjunction: 'and'
                    }
                ]
            },
            cboUOM: {
                store: '{itemUOMs}',
                value: '{current.strUOM}',
                origValueField: 'intItemUOMId',
                hidden: '{isCountByGroup}',
                defaultFilters: [
                    {
                        column: 'intItemId',
                        value: '{current.intItemId}',
                        conjunction: 'and'
                    },
                    {
                        column: 'intLocationId',
                        value: '{inventoryCount.intLocationId}',
                        conjunction: 'and'
                    }
                ]
            },
            txtCategory: {
                value: '{current.strCategory}',
                hidden: '{isCountByGroup}'
            },
            txtSystemCount: {
                value: '{current.dblSystemCount}'
            },
            txtCost: {
                value: '{current.dblLastCost}',
                hidden: '{isCountByGroup}'
            },
            txtVariance: {
                value: '{current.dblVariance}'
            },
            txtCountLineNo: {
                value: '{current.strCountLine}',
            },
            txtPhysicalCount: '{current.dblPhysicalCount}',
            txtPhysicalCountInStockUnit: {
                value: '{current.dblPhysicalCountStockUnit}',
                hidden: '{isCountByGroup}'
            },
            txtLotAlias: {
                value: '{current.strLotAlias}',
                hidden: '{isCountByGroup}',
				readOnly: '{lotAliasReadOnly}'
            },
            chkRecount: {
                value: '{current.ysnRecount}',
                hidden: '{isCountByGroup}'
            },
            lblEnteredBy: '{current.strUserName}'
        }
    },

    show: function(config) {
        var me = this,
            win = me.getView(),
            vm  = me.getViewModel(),
            store = Ext.create('Inventory.store.InventoryCountDetail');

        if(config) {
            win.show();
            
            /* Set context */
            var context = Ext.create('iRely.Engine', {
                window: win,
                store: store,
                binding: me.config.binding,
                createRecord: me.onCreateRecord
            });
            win.context = context;
            
            if (config.id) {
                config.filters = [{ column: 'intInventoryCountId', value: config.id }];

                context.data.load({
                    filters: config.filters,
                    callback: function(records, opts, success) { }
                });
            }

            vm.setData({
                inventoryCount: config.param.current
            });

            context.data.addRecord();
        }
    },

    onCreateRecord: function(config, action) {
        var vm = config.viewModel;
        var intInventoryCountId = vm.get('inventoryCount.intInventoryCountId');

        var rec = Ext.create('Inventory.model.InventoryCountDetail');
        rec.set('intInventoryCountId', intInventoryCountId);
        rec.set('ysnRecount', false);
        rec.set('dblLastCost', 0);
        rec.set('dblSystemCount', 0);
        
        rec.set('intEntityUserSecurityId', iRely.config.Security.EntityId);
        rec.set('strUserName', 'Entered by ' + iRely.config.Security.UserName);
        rec.set('dblConversionFactor', 1);
        ic.utils.ajax({
            url: '../Inventory/api/InventoryCountDetail/GetLastCountDetailId',
            params: {
                intInventoryCountId: intInventoryCountId
            }
        })
        .subscribe(function(response) {
            var json = Ext.decode(response.responseText);
            if(json.data.length > 0) {
                var count = json.intCountLine;
                rec.set('strCountLine', vm.get('inventoryCount.strCountNo') + '-' + count.toString());
            } else {
                rec.set('strCountLine', vm.get('inventoryCount.strCountNo') + '-1');
            }
        });

        action(rec);
    },

    onAddClick: function(e) {
        var me = this,
            win = me.getView(),
            vm = me.getViewModel(),
            valid = true,
            message = "";

        if(!vm.get('inventoryCount.strCountBy') === 'Pack') {
            if (!vm.get('current.intItemId')) {
                valid = false;
                message = "Please select an item.";
            } else if(!vm.get('current.intItemUOMId')) {
                valid = false;
                message = "Please select a UOM.";
            }
        } else {
            if (!vm.get('current.intCountGroupId')) {
                valid = false;
                message = "Please select a count group.";
            }    
        }

        if(valid) {
            win.context.data.saveRecord({
                successFn: function() {
                    win.close(vm.get('inventoryCount').intInventoryCountId);
                }
            });
        } else {
            iRely.Functions.showCustomDialog('error', 'ok', message, function() { });    
        }
    },

    getTotalLocationStockOnHand: function (intLocationId, intItemId, callback) {
        ic.utils.ajax({
            timeout: 120000,
            url: '../Inventory/api/ItemStock/GetLocationStockOnHand',
            params: {
                intLocationId: intLocationId,
                intItemId: intItemId
            }
        })
        .subscribe(
            function(response) {
                var jsonData = Ext.decode(response.responseText);
                if (jsonData.success) {
                    if(jsonData.data.length > 0)
                        callback(jsonData.data[0].dblOnHand);
                    else
                        callback(0);
                } else
                    callback(0);
            },
            function(error) {
                var jsonData = Ext.decode(error.responseText);
                callback(jsonData.ExceptionMessage, true);
            }
        );
    },

    getStockQuantity: function (intLocationId, intItemId, intSubLocationId, intStorageLocationId, callback) {
        ic.utils.ajax({
            timeout: 120000,   
            url: '../Inventory/api/Item/GetItemStockUOMSummary',
            params: {
                ItemId: intItemId,
                LocationId: intLocationId,
                SubLocationId: intSubLocationId,
                StorageLocationId: intStorageLocationId
            } 
        })
        .subscribe(
            function(response) {
                var jsonData = Ext.decode(response.responseText);
                if (jsonData.success) {
                    if(jsonData.data.length > 0)
                        callback(jsonData.data[0].dblOnHand);
                    else
                        callback(0);
                } else
                    callback(0);
            },
            function(error) {
                var jsonData = Ext.decode(error.responseText);
                callback(jsonData.ExceptionMessage, true);
            }
        );
    },

    onItemSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var me = this;
        var vm = me.getViewModel();
        var rec = _.first(records);

        vm.set('current.strItemDescription', rec.get('strDescription'));
        vm.set('current.strCategory', rec.get('strCategoryCode'));
        vm.set('current.intCategoryId', rec.get('intCategoryId'));
        vm.set('current.strStorageLocationName', null);
        vm.set('current.intStorageLocationId', null);
        vm.set('current.strSubLocationName', null);
        vm.set('current.intSubLocationId', null);
        vm.set('current.dblSystemCount', null);
        vm.set('current.intLotId', null);
        vm.set('current.strLotNo', null);
        vm.set('current.strLotAlias', null);
        vm.set('current.intItemUOMId', rec.get('intStockUOMId'));
        vm.set('current.strUnitMeasure', rec.get('strStockUOM'));

        // me.getStockQuantity(vm.get('inventoryCount.intLocationId'), vm.get('current.intItemId'), 
        //     vm.get('current.intSubLocationId'), vm.get('current.intStorageLocationId'), function(quantity) {
        //         vm.set('current.dblSystemCount', quantity);
        //     }
        // );
        me.getTotalLocationStockOnHand(vm.get('inventoryCount.intLocationId'), vm.get('current.intItemId'), 
            vm.get('current.intSubLocationId'), vm.get('current.intStorageLocationId'), function(quantity) {
                vm.set('current.dblSystemCount', quantity);
            }
        );
    },

    onLotSelect: function(combo, records, opts) {
        if (records.length <= 0)
            return;

        var me = this;
        var vm = me.getViewModel();
        var rec = _.first(records);    

        vm.set('current.strLotAlias', rec.get('strLotAlias'));
        vm.set('current.dblSystemCount', rec.get('dblQty'));
    },

    onSubLocationSelect: function(combo, records, opts) {
        if (records.length <= 0)
            return;
        
        var me = this;
        var vm = me.getViewModel();
        var rec = _.first(records);

        vm.set('current.strStorageLocationName', rec.get('strStorageLocationName'));
        vm.set('current.intStorageLocationId', rec.get('intStorageLocationId'));
        vm.set('current.dblSystemCount', rec.get('dblOnHand'));
        vm.set('current.intItemUOMId', rec.get('intItemUOMId'));
        vm.set('current.strUnitMeasure', rec.get('strUnitMeasure'));
    },

    onStorageUnitSelect: function(combo, records, opts) {
        if (records.length <= 0)
            return;
        
        var me = this;
        var vm = me.getViewModel();
        var rec = _.first(records);

        vm.set('current.strSubLocationName', rec.get('strSubLocationName'));
        vm.set('current.intSubLocationId', rec.get('intSubLocationId'));
        vm.set('current.dblSystemCount', rec.get('dblOnHand'));
        vm.set('current.intItemUOMId', rec.get('intItemUOMId'));
        vm.set('current.strUnitMeasure', rec.get('strUnitMeasure'));    
    },

    onUOMSelect: function(combo, records, opts) {
        if (records.length <= 0)
            return;
        
        var me = this;
        var vm = me.getViewModel();
        var rec = _.first(records);

        vm.set('current.dblSystemCount', rec.get('dblOnHand'));    
    },

    onCountGroupSelect: function(combo, records, opts) {
        if (records.length <= 0)
            return;
        
        var me = this;
        var vm = me.getViewModel();
        var rec = _.first(records);
        var intCountGroupId = rec.get('intCountGroupId');
        ic.utils.ajax({
            url: '../Inventory/api/InventoryCountDetail/GetLastCountGroup',
            params: {
                intCountGroupId: intCountGroupId
            }
        })
        .subscribe(function(res) {
            var json = JSON.parse(res.responseText);
            var data = json.data;
            if(data) {
                vm.set('current.dblSystemCount', data.dblPhysicalCount);
            }  
        });
    },

    init: function(application) {
        this.control({
            "#btnAdd": {
                click: this.onAddClick
            },
            "#cboItem": {
                select: this.onItemSelect
            },
            "#cboLotNo": {
                select: this.onLotSelect
            },
            "#cboStorageLocation": {
                select: this.onSubLocationSelect
            },
            "#cboStorageUnit": {
                select: this.onStorageUnitSelect
            },
            "#cboUOM": {
                select: this.onUOMSelect
            },
            "#cboCountGroup": {
                select: this.onCountGroupSelect
            }
        })
    }
});