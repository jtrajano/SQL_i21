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
        searchConfig: {
            title:  'Search Storage Locations',
            type: 'Inventory.StorageLocation',
            api: {
                read: '../Inventory/api/StorageLocation/SearchStorageLocations'
            },
            columns: [
                {dataIndex: 'intStorageLocationId',text: "Storage Location Id", flex: 1, defaultSort:true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strName', text: 'Name', flex: 1,  dataType: 'string'},
                {dataIndex: 'strDescription', text: 'Description', flex: 1,  dataType: 'string'}
            ]
        },
        binding: {
            bind: {
                title: 'Storage Location - {current.strName}'
            },
            txtName: '{current.strName}',
            txtDescription: '{current.strDescription}',
            cboUnitType: {
                value: '{current.intStorageUnitTypeId}',
                store: '{storageUnitType}'
            },
            cboLocation: {
                value: '{current.intLocationId}',
                store: '{location}'
            },
            cboSubLocation: '{current.intSubLocationId}',
            cboParentUnit: '{current.intParentStorageLocationId}',
            cboRestrictionType: {
                value: '{current.intRestrictionId}',
                store: '{restriction}'
            },
            txtAisle: '{current.strUnitGroup}',
            txtMinBatchSize: '{current.dblMinBatchSize}',
            txtBatchSize: '{current.dblBatchSize}',
            cboBatchSizeUom: {
                value: '{current.intBatchSizeUOMId}',
                store: '{batchSizeUOM}'
            },

            cboCommodity: {
                value: '{current.intCommodityId}',
                store: '{commodity}'
            },
            txtPackFactor: '{current.dblPackFactor}',
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
                colActive: ''
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

        win.context = Ext.create('iRely.mvvm.Engine', {
            window : win,
            store  : store,
            binding: me.config.binding,
            createRecord : me.createRecord,
            details: [
                {
                    key: 'tblICStorageLocationCategories',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: win.down('#grdItemCategoryAllowed'),
                        deleteButton : win.down('#btnDeleteItemCategoryAllowed')
                    })
                },
                {
                    key: 'tblICStorageLocationMeasurements',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: win.down('#grdMeasurement'),
                        deleteButton : win.down('#btnDeleteMeasurement')
                    })
                },
                {
                    key: 'tblICStorageLocationSkus',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: win.down('#grdSKU'),
                        deleteButton : win.down('#btnDeleteSKU'),
                        position: 'none'
                    })
                },
                {
                    key: 'tblICStorageLocationContainers',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
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
            }
        });
    }
});
