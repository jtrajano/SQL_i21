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
                origUpdateField: 'intItemId',
                defaultFilters: [
                    {
                        column: 'intLocationId',
                        value: '{inventoryCount.intLocationId}'
                    }
                ],
                hidden: '{isCountByGroup}'
            },
            txtDescription: '{current.strItemDescription}',
            txtStockUOM: '{current.strStockUOM}',
            txtNoOfPallets: {
                value: '{current.dblPallets}',
                hidden: '{hidePalletFields}'
            },
            txtQtyPerPallet: {
                value: '{current.dblQtyPerPallet}',
                hidden: '{hidePalletFields}'
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
                hidden: '{isCountByGroupOrNotLotted}',
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
                hidden: '{isCountByGroupOrNotLotted}',
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
                hidden: '{isCountByGroupOrNotLotted}',
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
            cboParentLotNo: {
                value: '{current.strParentLotNo}',   
                store: '{parentLots}',
                origValueField: 'intParentLotId',
                defaultFilters: [
                    {
                        column: 'intItemId',
                        value: '{current.intItemId}',
                        conjunction: 'and'
                    }
                ],
                hidden: '{isCountByGroupOrNotLotted}',
                forceSelection: '{forceSelection}'
            },
            cboUOM: {
                store: '{itemUOMs}',
                value: '{current.strUnitMeasure}',
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
                ],
                readOnly: '{disableCountUOM}'
            },
            txtWeightQty: {
                value: '{current.dblWeightQty}',
                hidden: '{isCountByGroupOrNotLotted}',
                readOnly: '{disableGrossUOM}'
            },
            txtNetWeightQty: {
                value: '{current.dblNetQty}',
                hidden: '{isCountByGroupOrNotLotted}',
                readOnly: '{disableGrossUOM}'
            },
            cboWeightUOM: {
                store: '{itemUOMs}',
                value: '{current.strWeightUOM}',
                hidden: '{isCountByGroupOrNotLotted}',
                fieldLabel: '{setWeightUOMFieldLabel}',
                origValueField: 'intItemUOMId',
                origUpdateField: 'intWeightUOMId',
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
                        column: 'strUnitType',
                        value: 'Weight',
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
            txtPhysicalCount: {
                value: '{current.dblPhysicalCount}',
                readOnly: '{disablePhysicalCount}'
            },
            txtPhysicalCountInStockUnit: {
                value: '{current.dblPhysicalCountStockUnit}',
                hidden: '{isCountByGroup}'
            },
            txtLotAlias: {
                value: '{current.strLotAlias}',
				readOnly: '{lotAliasReadOnly}',
                hidden: '{isCountByGroupOrNotLotted}'
            },
            chkRecount: {
                value: '{current.ysnRecount}',
                hidden: '{isCountByGroup}'
            },
            lblEnteredBy: '{current.strUserName}'
        }
    },

    show: function (config) {
        var me = this,
            win = me.getView(),
            vm = me.getViewModel();

        if (config) {
            win.show();
            win.context = win.context ? win.context.initialize() : me.setupContext();

            if(config.action === "edit") {
                if (config.param.id) {
                    config.filters = [{ column: 'intInventoryCountDetailId', value: config.param.id }];

                    win.context.data.load({
                        filters: config.filters,
                        callback: function (records, opts, success) { 
                            vm.setData({
                                inventoryCount: config.param.current
                            });
                        }
                    });
                }
            } else {
                vm.setData({
                    inventoryCount: config.param.current
                });
    
                win.context.data.addRecord();
            }
        }

        var task = new Ext.util.DelayedTask(function() {
            var cboItem = win.down('#cboItem');
            if(cboItem) cboItem.focus();
        });
        task.delay(500);
    },

    setupContext: function(options) {
        var me = this,
            win = me.getView(),
            vm = me.getViewModel(),
            store = Ext.create('Inventory.store.InventoryCountDetail');

        /* Set context */
        var context = Ext.create('iRely.Engine', {
            window: win,
            store: store,
            enableScreenOptimization: false,
            binding: me.config.binding,
            createRecord: me.onCreateRecord
        });

        return context;
    },

    onCreateRecord: function(config, action) {
        var vm = config.viewModel;
        var intInventoryCountId = vm.get('inventoryCount.intInventoryCountId');

        var rec = Ext.create('Inventory.model.InventoryCountDetail');
        rec.set('intInventoryCountId', intInventoryCountId);
        rec.set('ysnRecount', false);
        rec.set('dblLastCost', 0);
        rec.set('dblSystemCount', 0);
        rec.set('strCountBy', vm.get('inventoryCount.strCountBy'));
        
        rec.set('intEntityUserSecurityId', iRely.config.Security.EntityId);
        rec.set('strUserName', 'Entered by ' + iRely.config.Security.UserName);
        rec.set('dblConversionFactor', 1);
        Inventory.Utils.ajax({
            url: './inventory/api/inventorycountdetail/getlastcountdetailid',
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
            //valid = true,
            message = "";
        var current = vm.get('current');
        if(!current.get('intLotId') && current.get('ysnLotted')) {
            var combo = win.down('#cboLotNo');
            current.set('strLotNo', combo.getValue());
        }

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

        win.context.data.validator.validateRecord(win.context.data.configuration, function (valid) {
            if (valid) {
                win.context.data.saveRecord({
                    successFn: function () {
                        win.close(vm.get('inventoryCount').intInventoryCountId);
                    }
                });
            }
        });
    },

    getTotalLocationStockOnHand: function (intLocationId, intItemId, intSubLocationId, intStorageLocationId, intLotId, intItemUOMId, callback) {
        Inventory.Utils.ajax({
            timeout: 120000,
            url: './inventory/api/itemstock/getlocationstockonhand',
            params: {
                intLocationId: intLocationId,
                intItemId: intItemId,
                intSubLocationId: intSubLocationId,
                intStorageLocationId: intStorageLocationId,
                intLotId: intLotId,
                intItemUOMId: intItemUOMId
            }
        })
            .subscribe(
            function (response) {
                var jsonData = Ext.decode(response.responseText);
                if (jsonData.success) {
                    if (jsonData.data.length > 0)
                        callback(jsonData.data[0].dblOnHand);
                    else
                        callback(0);
                } else
                    callback(0);
            },
            function (error) {
                var jsonData = Ext.decode(error.responseText);
                callback(jsonData.ExceptionMessage, true);
            }
            );
    },

    mapGrossNet: function (current) {
        var gn = this.calculateGrossNet(current.get('dblPhysicalCount'), current.get('dblItemUOMConversionFactor'), current.get('dblWeightUOMConversionFactor'), 0.00);
        current.set('dblWeightQty', gn.gross);
        current.set('dblNetQty', gn.gross);
    },

    calculateGrossNet: function (lotQty, itemUOMConversionFactor, weightUOMConversionFactor, tareWeight) {
        var grossQty = 0.00;
        var me = this;
        if (itemUOMConversionFactor === weightUOMConversionFactor) {
            grossQty = lotQty;
        }
        else if (weightUOMConversionFactor !== 0) {
            grossQty = Inventory.Utils.Uom.convertQtyBetweenUOM(itemUOMConversionFactor, weightUOMConversionFactor, lotQty);
        }

        return {
            gross: grossQty,
            tare: tareWeight,
            net: grossQty - tareWeight
        };
    },

    getStockQuantity: function (intLocationId, intItemId, intSubLocationId, intStorageLocationId, callback) {
        Inventory.Utils.ajax({
            timeout: 120000,   
            url: './inventory/api/item/getitemstockuomsummary',
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
        vm.set('selectedLot', null);
        vm.set('current.intWeightUOMId', null);
        //vm.set('current.intItemId', rec.get('intItemId'));
        vm.set('current.ysnLotWeightsRequired', rec.get('ysnLotWeightsRequired'));
        vm.set('current.dblWeightQty', null);
        vm.set('current.dblNetQty', null);
        vm.set('current.strWeightUOM', null);
        vm.set('current.dblWeightUOMConversionFactor', null);
        vm.set('current.dblItemUOMConversionFactor', rec.get('dblStockUnitQty'));
        vm.set('current.strStockUOM', rec.get('strStockUOM'));
        vm.set('current.intStockUOMId', rec.get('intStockUOMId'));
        vm.set('current.intItemUOMId', rec.get('intStockUOMId'));
        vm.set('current.strUnitMeasure', rec.get('strStockUOM'));
        vm.set('current.intItemLocationId', rec.get('intItemLocationId'));
        vm.set('current.ysnLotted', rec.get('strLotTracking') !== 'No');
        vm.set('current.dblLastCost', rec.get('dblLastCost'));
        vm.set('isLotted', rec.get('strLotTracking') !== 'No');

        me.getTotalLocationStockOnHand(
            vm.get('inventoryCount.intLocationId'),
            vm.get('current.intItemId'),
            vm.get('current.intSubLocationId'),
            vm.get('current.intStorageLocationId'),
            vm.get('current.intLotId'),
            vm.get('current.intItemUOMId'),
            function (quantity) {
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
        vm.set('current.strLotNo', rec.get('strLotNumber'));
        vm.set('current.dblSystemCount', rec.get('dblQty'));
        vm.set('current.strUnitMeasure', rec.get('strItemUOM'));
        vm.set('current.intItemUOMId', rec.get('intItemUOMId'));
        vm.set('current.intWeightUOMId', null);
        vm.set('current.dblWeightQty', null);
        vm.set('current.dblNetQty', null);
        vm.set('current.strWeightUOM', null);
        vm.set('current.dblItemUOMConversionFactor', rec.get('dblItemUOMConv'));
        //vm.set('current.dblWeightUOMConversionFactor', null);
        
        vm.set('selectedLot', records);
        me.getTotalLocationStockOnHand(
            vm.get('inventoryCount.intLocationId'),
            vm.get('current.intItemId'),
            vm.get('current.intSubLocationId'),
            vm.get('current.intStorageLocationId'),
            vm.get('current.intLotId'),
            vm.get('current.intItemUOMId'),
            function (quantity) {
                vm.set('current.dblSystemCount', quantity);
            }
        );
        me.mapGrossNet(vm.get('current'));
    },

    onSubLocationSelect: function(combo, records, opts) {
        if (records.length <= 0)
            return;
        
        var me = this;
        var vm = me.getViewModel();
        var rec = _.first(records);

        vm.set('current.strStorageLocationName', null);
        vm.set('current.intStorageLocationId', null);
        vm.set('current.intLotId', null);
        vm.set('current.strLotNo', null);
        vm.set('current.strLotAlias', null);
        vm.set('current.intItemLocationId', rec.get('intItemLocationId'));
        vm.set('selectedLot', null);

        me.getTotalLocationStockOnHand(
            vm.get('inventoryCount.intLocationId'),
            vm.get('current.intItemId'),
            vm.get('current.intSubLocationId'),
            vm.get('current.intStorageLocationId'),
            vm.get('current.intLotId'),
            vm.get('current.intItemUOMId'),
            function (quantity) {
                vm.set('current.dblSystemCount', quantity);
            }
        );
    },

    onStorageUnitSelect: function(combo, records, opts) {
        if (records.length <= 0)
            return;
        
        var me = this;
        var vm = me.getViewModel();
        var rec = _.first(records);

        if (vm.get('current.intLotId')) {
            vm.set('current.strLotNo', null);
            vm.set('current.strLotAlias', null);
            vm.set('selectedLot', null);
        }

        me.getTotalLocationStockOnHand(
            vm.get('inventoryCount.intLocationId'),
            vm.get('current.intItemId'),
            vm.get('current.intSubLocationId'),
            vm.get('current.intStorageLocationId'),
            vm.get('current.intLotId'),
            vm.get('current.intItemUOMId'),
            function (quantity) {
                vm.set('current.dblSystemCount', quantity);
            }
        );   
    },

    onUOMSelect: function(combo, records, opts) {
        if (records.length <= 0)
            return;
        
        var me = this;
        var vm = me.getViewModel();
        var rec = _.first(records);

        vm.set('current.intItemUOMId', rec.get('intItemUOMId'));
        if (vm.get('current.intLotId')) {
            vm.set('current.dblSystemCount', rec.get('dblOnHand'));
            me.getTotalLocationStockOnHand(
                vm.get('inventoryCount.intLocationId'),
                vm.get('current.intItemId'),
                vm.get('current.intSubLocationId'),
                vm.get('current.intStorageLocationId'),
                vm.get('current.intLotId'),
                vm.get('current.intItemUOMId'),
                function (quantity) {
                    vm.set('current.dblSystemCount', quantity);
                }
            );
        } else {
            vm.set('current.dblSystemCount', 0.00);
        }
        vm.get('current').set('dblItemUOMConversionFactor', rec.get('dblUnitQty'));
        me.mapGrossNet(vm.get('current'));
    },

    onCountGroupSelect: function(combo, records, opts) {
        if (records.length <= 0)
            return;
        
        var me = this;
        var vm = me.getViewModel();
        var rec = _.first(records);
        var intCountGroupId = rec.get('intCountGroupId');
        Inventory.Utils.ajax({
            url: './inventory/api/inventorycountdetail/getlastcountgroup',
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

    onGrossUOMSelect: function(combo, records, opts) {
        if(records.length <= 0)
            return;
        
        var me = this;
        var vm = me.getViewModel();
        var rec = _.first(records);
        var current = vm.get('current');
        current.set('intWeightUOMId', rec.get('intItemUOMId'));
        current.set('dblWeightUOMConversionFactor', rec.get('dblUnitQty'));
        me.mapGrossNet(current);
    },

    onItemBeforeQuery: function (obj) {
        if (obj.combo) {
            if (obj.combo.itemId === 'cboItem') {
                var vm = obj.combo.up('window').getViewModel();
                var current = vm.get('current');
                var locationId = vm.get('inventoryCount.intLocationId');

                obj.combo.defaultFilters = [
                    {
                        column: 'intLocationId',
                        value: locationId,
                        conjunction: 'and'
                    },
                    {
                        column: 'strLotTracking',
                        value: 'No',
                        conjunction: 'and',
                        condition: 'eq'
                    }
                ];

                if (vm.get('inventoryCount.ysnCountByLots')) {
                    obj.combo.defaultFilters = [
                        {
                            column: 'intLocationId',
                            value: locationId,
                            conjunction: 'and'
                        },
                        {
                            column: 'strLotTracking',
                            value: 'No',
                            conjunction: 'and',
                            condition: 'noteq'
                        }
                    ];
                }
            }
        }
    },

    onUOMBeforeQuery: function (obj) {
        if (obj.combo) {
            if (obj.combo.itemId === 'cboUOM') {
                var vm = obj.combo.up('window').getViewModel();
                var current = vm.get('current');
                var locationId = vm.get('inventoryCount.intLocationId');

                obj.combo.defaultFilters = [
                    {
                        column: 'intItemId',
                        value: current.get('intItemId'),
                        conjunction: 'and'
                    },
                    {
                        column: 'intLocationId',
                        value: locationId,
                        conjunction: 'and'
                    }
                ];

                if (current.get('intLotId')) {
                    var selectedLot = vm.get('selectedLot');
                    if (selectedLot && selectedLot.length > 0) {
                        obj.combo.defaultFilters = [
                            {
                                column: 'intItemId',
                                value: current.get('intItemId'),
                                conjunction: 'and'
                            },
                            {
                                column: 'intLocationId',
                                value: locationId,
                                conjunction: 'and'
                            },
                            {
                                column: 'intItemUOMId',
                                value: selectedLot[0].get('intItemUOMId'),
                                conjunction: 'and',
                                condition: 'eq'
                            }
                        ];
                    }
                }
            }
        }
    },

    onPhysicalCountChange: function(field, newValue, oldValue) {
        var me = this;
        var current = me.getViewModel().get('current');
        me.mapGrossNet(current);
    },

    onPalletChange: function(field, newValue, oldValue) {
        var me = this;
        var current = me.getViewModel().get('current');
        
        var calcPallet = current.get('dblPallets') !== 0 && current.get('dblQtyPerPallet') !== 0;
        if(calcPallet) {
            current.set('dblPhysicalCount', current.get('dblPallets') * current.get('dblQtyPerPallet'));
        }
    },

    onLotNoChange: function(combo, newValue, oldValue, eOpts) {
        var me = this,
            vm = me.getViewModel(),
            current = vm.get('current');
        var value = combo.findRecordByValue(newValue);

        if(!value && !newValue) {
            current.set('strLotNo', newValue);
        }
    },

    onParentLotSelect: function(combo, records, opts) {
        if (records.length <= 0)
        return;

        var me = this;
        var vm = me.getViewModel();
        var rec = _.first(records);

        vm.set('current.strParentLotNo', rec.get('strParentLotNumber'));
    },

    init: function (application) {
        this.control({
            "#btnAdd": {
                click: this.onAddClick
            },
            "#txtPhysicalCount": {
                change: this.onPhysicalCountChange
            },
            "#txtNoOfPallets": {
                change: this.onPalletChange
            },
            "#txtQtyPerPallet": {
                change: this.onPalletChange
            },
            "#cboItem": {
                beforequery: this.onItemBeforeQuery,
                select: this.onItemSelect
            },
            "#cboWeightUOM": {
                select: this.onGrossUOMSelect
            },
            "#cboLotNo": {
                select: this.onLotSelect,
                //change: this.onLotNoChange
            },
            "#cboParentLotNo": {
                select: this.onParentLotSelect,
            },
            "#cboStorageLocation": {
                select: this.onSubLocationSelect
            },
            "#cboStorageUnit": {
                select: this.onStorageUnitSelect
            },
            "#cboUOM": {
                //beforequery: this.onUOMBeforeQuery,
                select: this.onUOMSelect
            },
            "#cboCountGroup": {
                select: this.onCountGroupSelect
            }
        })
    }
});