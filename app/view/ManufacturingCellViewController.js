/*
 * File: app/view/ManufacturingCellViewController.js
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

Ext.define('Inventory.view.ManufacturingCellViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icmanufacturingcell',

    config: {
        searchConfig: {
            title:  'Search Manufacturing Cells',
            type: 'Inventory.ManufacturingCell',
            api: {
                read: '../Inventory/api/ManufacturingCell/SearchManufacturingCells'
            },
            columns: [
                {dataIndex: 'intManufacturingCellId',text: "Manufacturing Cell Id", flex: 1, defaultSort:true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strCellName', text: 'Manufacturing Cell', flex: 2,  dataType: 'string'},
                {dataIndex: 'strDescription', text: 'Description', flex: 1,  dataType: 'string'}
            ]
        },
        binding: {
            txtName: '{current.strCellName}',
            txtDescription: '{current.strDescription}',
            cboLocationName: {
                value: '{current.intLocationId}',
                store: '{location}'
            },
            chkActive: '{current.ysnActive}',
            txtStandardCapacity: '{current.dblStdCapacity}',
            cboStandardCapacityUom: {
                value: '{current.intStdUnitMeasureId}',
                store: '{capacityUOM}'
            },
            cboStandardCapacityRate: {
                value: '{current.intStdCapacityRateId}',
                store: '{capacityRateUOM}'
            },
            txtStandardLineEfficiency: '{current.dblStdLineEfficiency}',
            chkIncludeInScheduling: '{current.ysnIncludeSchedule}',

            grdPackingType: {
                colPackTypeName: 'strPackName',
                colPackTypeDescription: 'strDescription',
                colLineCapacity: 'dblLineCapacity',
                colLineCapacityUOM: {
                    dataIndex: 'strCapacityUnitMeasure',
                    editor: {
                        store: '{packTypeCapacityUOM}'
                    }
                },
                colLineCapacityRate: {
                    dataIndex: 'strCapacityRateUnitMeasure',
                    editor: {
                        store: '{packTypeCapacityRateUOM}'
                    }
                },
                colLineEfficiency: 'dblLineEfficiencyRate'
            }
        }
    },

    setupContext : function(options){
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.ManufacturingCell', { pageSize: 1 });

        var grdPackingType = win.down('#grdPackingType');

        win.context = Ext.create('iRely.mvvm.Engine', {
            binding: me.config.binding,
            createRecord : me.createRecord,
            window : win,
            store  : store,
            details: [
                {
                    key: 'tblICManufacturingCellPackTypes',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdPackingType,
                        deleteButton : grdPackingType.down('#btnDeletePackingType')
                    })
                }
            ]
        });

        var notTimeFilter = [{ dataIndex: 'strUnitType', value: 'Time', condition: 'noteq' }];
        var timeFilter = [{ dataIndex: 'strUnitType', value: 'Time', condition: 'eq' }];

        var cboStandardCapacityUom = win.down('#cboStandardCapacityUom');
        var cboStandardCapacityRate = win.down('#cboStandardCapacityRate');

        cboStandardCapacityUom.defaultFilters = notTimeFilter;
        cboStandardCapacityRate.defaultFilters = timeFilter;

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
                        column: 'intUnitMeasureId',
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
        var record = Ext.create('Inventory.model.ManufacturingCell');
        record.set('ysnActive', true);
        action(record);
    },

    onPackTypeSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepPackType');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colPackTypeName')
        {
            current.set('intPackTypeId', records[0].get('intPackTypeId'));
            current.set('strDescription', records[0].get('strDescription'));
        }
        else if (combo.column.itemId === 'colLineCapacityUOM')
        {
            current.set('intLineCapacityUnitMeasureId', records[0].get('intUnitMeasureId'));
        }
        else if (combo.column.itemId === 'colLineCapacityRate')
        {
            current.set('intLineCapacityRateUnitMeasureId', records[0].get('intUnitMeasureId'));
        }
    },

    onUOMBeforeRender: function (combo, eOpts) {
        if (!combo) return;

        if (combo.itemId === 'cboCapacityUOM'){
            var notTimeFilter = [{ dataIndex: 'strUnitType', value: 'Time', condition: 'noteq' }];
            combo.defaultFilters = notTimeFilter;
        }
        else if (combo.itemId === 'cboCapacityRateUOM'){
            var timeFilter = [{ dataIndex: 'strUnitType', value: 'Time', condition: 'eq' }];
            combo.defaultFilters = timeFilter;
        }
    },

    init: function(application) {
        this.control({
            "#cboPackType": {
                select: this.onPackTypeSelect
            },
            "#cboCapacityUOM": {
                select: this.onPackTypeSelect,
                beforerender: this.onUOMBeforeRender
            },
            "#cboCapacityRateUOM": {
                select: this.onPackTypeSelect,
                beforerender: this.onUOMBeforeRender
            }
        });
    }
});
