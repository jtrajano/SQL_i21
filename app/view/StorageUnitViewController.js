/*
 * File: app/view/StorageUnitViewController.js
 *
 * This file was generated by Sencha Architect version 3.1.0.
 * http://www.sencha.com/products/architect/
 *
 * This file requires use of the Ext JS 5.0.x library, under independent license.
 * License of Sencha Architect does not include license for Ext JS 5.0.x. For more
 * details see http://www.sencha.com/license or contact license@sencha.com.
 *
 * This file will be auto-generated each and everytime you save your project.
 *
 * Do NOT hand edit this file.
 */

Ext.define('Inventory.view.StorageUnitViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icstorageunit',

    config: {
        helpURL: '/display/DOC/Storage+Locations',
        binding: {
            bind: {
                title: 'Storage Location - {current.strName}'
            },
            cboItem: {
                value: '{current.strItemNo}',
                origValueField: 'intItemId',
                store: '{items}',
                defaultFilters: [
                    {
                        column: 'strType',
                        value: 'Inventory|^|Raw Material|^|Finished Good|^|Bundle|^|Kit',
                        conjunction: 'Or',
                        condition: 'eq'
                    },
                    {
                        column: 'intLocationId',
                        value: '{current.intLocationId}',
                        conjunction: 'And',
                        condition: 'eq'
                    }]
            },
            txtName: '{current.strName}',
            txtDescription: '{current.strDescription}',
            cboUnitType: {
                value: '{current.strStorageUnitType}',
                origValueField: 'intStorageUnitTypeId',
                store: '{storageUnitType}'
            },
            cboLocation: {
                value: '{current.strLocation}',
                origValueField: 'intCompanyLocationId',
                origUpdateField: 'intLocationId',
                store: '{location}'
            },
            cboSubLocation: {
                value: '{current.strSubLocation}',
                origValueField: 'intCompanyLocationSubLocationId',
                origUpdateField: 'intSubLocationId',
                store: '{subLocation}',
                defaultFilters: [{
                    column: 'intCompanyLocationId',
                    value: '{current.intLocationId}'
                }]
            },
            cboParentUnit: {
                value: '{current.strParentUnit}',
                origValueField: 'intStorageLocationId',
                origUpdateField: 'intParentStorageLocationId',
                store: '{parentUnit}',
                defaultFilters: [{
                    column: 'intStorageLocationId',
                    value: '{current.intStorageLocationId}',
                    condition: 'noteq'
                }]
            },
            cboRestrictionType: {
                value: '{current.strRestrictionType}',
                origValueField: 'intRestrictionId',
                store: '{restriction}'
            },
            txtAisle: '{current.strUnitGroup}',
            txtMinBatchSize: '{current.dblMinBatchSize}',
            txtBatchSize: '{current.dblBatchSize}',
            cboBatchSizeUom: {
                value: '{current.strBatchSizeUOM}',
                origValueField: 'intUnitMeasureId',
                origUpdateField: 'intBatchSizeUOMId',
                store: '{batchSizeUOM}'
            },

            cboCommodity: {
                value: '{current.intCommodityId}',
                store: '{commodity}'
            },
            txtPackFactor: '{current.dblPackFactor}',
            txtEffectiveDepth: '{current.dblEffectiveDepth}',
            txtUnitsPerFoot: '{current.dblUnitPerFoot}',
            txtResidualUnits: '{current.dblResidualUnit}',

            chkAllowConsume: '{current.ysnAllowConsume}',
            chkAllowMultipleItems: '{current.ysnAllowMultipleItem}',
            chkAllowMultipleLots: '{current.ysnAllowMultipleLot}',
            chkMergeOnMove: '{current.ysnMergeOnMove}',
            chkCycleCounted: '{current.ysnCycleCounted}',
            chkDefaultWarehouseStagingUnit: '{current.ysnDefaultWHStagingUnit}',

            txtSequence: '{current.intSequence}',
            chkActive: '{current.ysnActive}',
            txtXPosition: '{current.intRelativeX}',
            txtYPosition: '{current.intRelativeY}',
            txtZPosition: '{current.intRelativeZ}',

            grdMeasurement: {
                colMeasurement: {
                    dataIndex: 'strMeasurementName',
                    editor: {
                        store: '{measurement}'
                    }
                },
                colReadingPoint: {
                    dataIndex: 'strReadingPoint',
                    editor: {
                        store: '{readingPoint}'
                    }
                },
                colActive: {
                    dataIndex: 'ysnActive'
                }
            },

            grdItemCategoryAllowed: {
                colCategory: {
                    dataIndex: 'strCategoryCode',
                    editor: {
                        store: '{categoryAllowed}'
                    }
                }
            },

            grdSKU: {
                colItem: 'strItemNo',
                colSku: 'strSku',
                colQty: 'dblQuantity',
                colContainer: 'strContainer',
                colLotSerial: 'intLotCodeId',
                colExpiration: 'dtmExpiration',
                colStatus: 'strLotStatus',
                colOwner: 'intOwnerId'
            },

            grdContainer: {
                colContainer: 'strContainer',
                colExternalSystem: 'intExternalSystemId',
                colContainerType: 'strContainerType',
                colLastUpdateBy: 'strLastUpdatedBy',
                colLastUpdateOn: 'dtmLastUpdatedOn'
            }

        }
    },

    setupContext : function(options){
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.StorageLocation', { pageSize: 1 });

        win.context = Ext.create('iRely.Engine', {
            window : win,
            store  : store,
            include: 'vyuICGetStorageLocation, tblICStorageLocationCategories.tblICCategory, ' +
                'tblICStorageLocationMeasurements.tblICMeasurement, ' +
                'tblICStorageLocationMeasurements.tblICReadingPoint, ' +
                'tblICStorageLocationSkus.tblICItem, ' +
                'tblICStorageLocationSkus.tblICSku, ' +
                'tblICStorageLocationSkus.tblICContainer, ' +
                'tblICStorageLocationSkus.tblICLotStatus, ' +
                'tblICStorageLocationContainers.tblICContainer, ' +
                'tblICStorageLocationContainers.tblICContainerType',
            binding: me.config.binding,
            createRecord : me.createRecord,
            details: [
                {
                    key: 'tblICStorageLocationCategories',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdItemCategoryAllowed'),
                        deleteButton : win.down('#btnDeleteItemCategoryAllowed')
                    })
                },
                {
                    key: 'tblICStorageLocationMeasurements',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdMeasurement'),
                        deleteButton : win.down('#btnDeleteMeasurement')
                    })
                },
                {
                    key: 'tblICStorageLocationSkus',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdSKU'),
                        deleteButton : win.down('#btnDeleteSKU'),
                        position: 'none'
                    })
                },
                {
                    key: 'tblICStorageLocationContainers',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdContainer'),
                        deleteButton : win.down('#btnDeleteContainer'),
                        position: 'none'
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
                        column: 'intStorageLocationId',
                        value: config.id
                    }];
                }
                context.data.load({
                    filters: config.filters
                });
            }
        }
    },

    createRecord: function(config, action) {
        var me = this;
        var record = Ext.create('Inventory.model.StorageLocation');
        if (app.DefaultLocation > 0)
            record.set('intLocationId', app.DefaultLocation);
        action(record);
    },

    onCategorySelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepCategoryAllowed');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colCategory')
        {
            current.set('intCategoryId', records[0].get('intCategoryId'));
        }
    },

    onMeasurementSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepMeasurement');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colMeasurement')
        {
            current.set('intMeasurementId', records[0].get('intMeasurementId'));
        }
        else if (combo.column.itemId === 'colReadingPoint')
        {
            current.set('intReadingPointId', records[0].get('intReadingPointId'));
        }
    },

    onUnitTypeDrilldown: function(combo) {
        if (iRely.Functions.isEmpty(combo.getValue())) {
            iRely.Functions.openScreen('Inventory.view.FactoryUnitType', { action: 'new', viewConfig: { modal: true }});
        }
        else {
            iRely.Functions.openScreen('Inventory.view.FactoryUnitType', combo.getValue());
        }
    },

    onLocationDrilldown: function(combo) {
        if (iRely.Functions.isEmpty(combo.getValue())) {
            iRely.Functions.openScreen('i21.view.CompanyLocation', { action: 'new', viewConfig: { modal: true }});
        }
        else {
            i21.ModuleMgr.Inventory.showScreen(combo.getRawValue(), 'LocationName');
        }
    },

    onSubLocationDrilldown: function(combo) {
        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) {
            if (iRely.Functions.isEmpty(current.get('intLocationId'))) {
                iRely.Functions.showErrorDialog('Location must be specified.');
                return;
            }

            else {
                iRely.Functions.openScreen('i21.view.CompanyLocation', { 
                    action: 'edit',
                    filters: [
                        {
                             column: 'intCompanyLocationId',
                             value: current.get('intLocationId'),
                             conjunction: 'and'
                        }  
                    ],
                    activeTab: 'Storage Location'
                });
            }
        }
    },

    onItemDrilldown: function(combo) {
        if (iRely.Functions.isEmpty(combo.getValue())) {
            iRely.Functions.openScreen('Inventory.view.Item', { action: 'new', viewConfig: { modal: true }});
        }
        else {
            iRely.Functions.openScreen('Inventory.view.Item', combo.getValue());
        }
    },

    onCommodityDrilldown: function(combo) {
        if (iRely.Functions.isEmpty(combo.getValue())) {
            iRely.Functions.openScreen('Inventory.view.Commodity', { action: 'new', viewConfig: { modal: true }});
        }
        else {
            iRely.Functions.openScreen('Inventory.view.Commodity', combo.getValue());
        }
    },

    onDuplicateClick: function(button) {
        var win = button.up('window');
        var context = win.context;
        var current = win.viewModel.data.current;

        if (current) {
            iRely.Msg.showWait('Duplicating Storage Location...');
            ic.utils.ajax({
                timeout: 120000,
                url: '../Inventory/api/StorageLocation/DuplicateStorageLocation',
                params: {
                    StorageLocationId: current.get('intStorageLocationId')
                },
                method: 'Get'  
            })
            .finally(function() { iRely.Msg.close(); })
            .subscribe(
                function (successResponse) {
				    var jsonData = Ext.decode(successResponse.responseText);
                    context.configuration.store.addFilter([{ column: 'intStorageLocationId', value: jsonData.message.id }]);
                    context.configuration.paging.moveFirst();
				},
				function (failureResponse) {
                    var jsonData = Ext.decode(failureResponse.responseText);
                    iRely.Functions.showErrorDialog(jsonData.ExceptionMessage);
				}
            );
        }
    },

    init: function(application) {
        this.control({
            "#cboCategoryAllowed": {
                select: this.onCategorySelect
            },
            "#cboMeasurement": {
                select: this.onMeasurementSelect
            },
            "#cboReadingPoint": {
                select: this.onMeasurementSelect
            },
            "#cboUnitType": {
                drilldown: this.onUnitTypeDrilldown
            },
            "#cboLocation": {
                drilldown: this.onLocationDrilldown
            },
            "#cboSubLocation": {
                drilldown: this.onSubLocationDrilldown
            },
            "#cboItem": {
                drilldown: this.onItemDrilldown
            },
            "#cboCommodity": {
                drilldown: this.onCommodityDrilldown
            },
            "#btnDuplicate": {
                click: this.onDuplicateClick
            },  
        });
    }
});
