/*
 * File: app/view/InventoryUOMViewController.js
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

Ext.define('Inventory.view.InventoryUOMViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icinventoryuom',

    config: {
        helpURL: '/display/DOC/Inventory+UOM',
        searchConfig: {
            title:  'Search Inventory UOMs',
            type: 'Inventory.InventoryUOM',
            api: {
                read: '../Inventory/api/UnitMeasure/Search'
            },
            columns: [
                {dataIndex: 'intUnitMeasureId',text: "UOM Id", flex: 1, defaultSort:true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strUnitMeasure', text: 'UOM Name', flex: 2,  dataType: 'string'},
                {dataIndex: 'strSymbol', text: 'Symbol', flex: 1,  dataType: 'string'},
                {dataIndex: 'strUnitType', text: 'Unit Type', flex: 2,  dataType: 'string'}
            ]
        },
        binding: {
            bind: {
                title: 'Inventory UOM - {current.strUnitMeasure}'
            },
            txtUnitMeasure: '{current.strUnitMeasure}',
            txtSymbol: '{current.strSymbol}',
            cboUnitType: {
                value: '{current.strUnitType}',
                store: '{unitTypes}'
            },

            grdConversion: {
                colConversionStockUOM: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{unitMeasure}'
                    }
                },
                colConversionToStockUOM: 'dblConversionToStock'
            }
        }
    },

    setupContext : function(options){
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.UnitMeasure', { pageSize: 1 });

        var grdConversion = win.down('#grdConversion');

        win.context = Ext.create('iRely.mvvm.Engine', {
            binding: me.config.binding,
            window : win,
            store  : store,
            include: 'tblICUnitMeasureConversions.StockUnitMeasure, vyuICGetUOMConversions',
            details: [
                {
                    key: 'tblICUnitMeasureConversions',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdConversion,
                        deleteButton : grdConversion.down('#btnDeleteConversion')
                    })
                }
            ]
        });

        win.context.data.on({ currentrecordchanged: me.onCurrentRecordChanged, scope: me })

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

    onCurrentRecordChanged: function (record, store) {
        var me = this;
        var win = me.getView();
        var grd = win.down('#grdConversion');
        var col = grd.columns[0];
        var cboUOM = col.getEditor();

        switch(record.get('strUnitType')){
            case 'Area':
            case 'Length':
                cboUOM.defaultFilters =
                    [
                        { dataIndex: 'strUnitType', value: 'Area', condition: 'eq'},
                        { dataIndex: 'strUnitType', value: 'Length', condition: 'eq', conjunction: 'or'},
                        { dataIndex: 'intUnitMeasureId', value: record.get('intUnitMeasureId'), condition: 'noteq', conjunction: 'and' }
                    ];
                break;
            case 'Quantity':
            case 'Volume':
            case 'Weight':
                cboUOM.defaultFilters =
                    [
                        { dataIndex: 'strUnitType', value: 'Quantity', condition: 'eq'},
                        { dataIndex: 'strUnitType', value: 'Volume', condition: 'eq', conjunction: 'or'},
                        { dataIndex: 'strUnitType', value: 'Weight', condition: 'eq', conjunction: 'or'},
                        { dataIndex: 'strUnitType', value: 'Packed', condition: 'eq', conjunction: 'or'},
                        { dataIndex: 'intUnitMeasureId', value: record.get('intUnitMeasureId'), condition: 'noteq', conjunction: 'and' }
                    ];
                break;
            case 'Time':
                cboUOM.defaultFilters =
                    [
                        { dataIndex: 'intUnitMeasureId', value: record.get('intUnitMeasureId'), condition: 'noteq'},
                        { dataIndex: 'strUnitType', value: 'Time', condition: 'eq', conjunction: 'and'}
                    ];
                break;
        };
    },

    onUOMSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepConversion');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colConversionStockUOM')
        {
            current.set('intStockUnitMeasureId', records[0].get('intUnitMeasureId'));
        }
    },

    onDecimalCalculationChange: function(obj, newValue, oldValue, eOpts) {
        var win = obj.up('window');
        var grdConversion = win.down('#grdConversion');
        var colConversionToStockUOM = grdConversion.columns[1];

        colConversionToStockUOM.format = i21.ModuleMgr.Inventory.createNumberFormat(newValue);

        if (colConversionToStockUOM.getEditor()){
            colConversionToStockUOM.getEditor().decimalPrecision = newValue;
        }
    },

    init: function(application) {
        this.control({
            "#cboStockUom": {
                select: this.onUOMSelect
            },
            "#txtDecimalPlacesForCalculation": {
                change: this.onDecimalCalculationChange
            }
        });
    }
});
