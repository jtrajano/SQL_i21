/**
 * @author Wendell Wayne H. Estrada
 * @copyright 2017 iRely Philippines
 * http://inet.irelyserver.com/display/INV/Grid+Unit+of+Measure+Field
 */
Ext.define('Inventory.ux.GridUnitMeasureField', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.gridunitmeasurefield',
    mixins: {
        field: 'Ext.form.field.Field',
        observable : 'Ext.util.Observable'
    },

    constructor : function(config){
        this.callParent([config]);
        this.mixins.observable.constructor.call(this, config);
    },

    config: {
        defaultDecimals: 6,
        prevUOM: null
    },

    initComponent: function() {
        this.callParent(arguments);
        var me = this;
        me.flex = 1;
        me.layout = 'fit';
        var panel = me.items.items[0];
        var cbo = panel.items.items[1];
        var txt = panel.items.items[0];
        var grid = me.column.container.component.grid;
        var selection = grid.selection;

        this.setupCombobox(me, cbo);
        this.setupTextboxEvents(txt);
    },

    getValue: function(){
        var me = this;
        var panel = me.items.items[0];
        var cbo = panel.items.items[1];
        var txt = panel.items.items[0];
        var grid = me.column.container.component.grid;
        var selection = grid.selection;

        var value = txt.getValue();
        var decimals = me.getExpectedDecimals();

        var n = me.setupQuantity(txt, value, decimals);
        return n ? n.precisionValue : value;
    },

    getExpectedDecimals: function() {
        var me = this;
        var panel = me.items.items[0];
        var cbo = panel.items.items[1];
        var txt = panel.items.items[0];
        var grid = me.column.container.component.grid;
        var selection = grid.selection;

        var selectedDecimal = me.getSelectedDecimals(cbo);
        var boundDecimal = me.getBoundDecimals(me, selection);
        decimals = !iRely.Functions.isEmpty(selectedDecimal) ? selectedDecimal : boundDecimal;

        /* Fallback to default decimal places */
        decimals = !iRely.Functions.isEmpty(decimals) ? decimals : me.defaultDecimals;

        return decimals;
    },

    setValue: function(value) {
        var me = this;
        var panel = me.items.items[0];
        var cbo = panel.items.items[1];
        var txt = panel.items.items[0];
        me.resetValues();
        var grid = me.column.container.component.grid;
        var selection = grid.selection;

        var currentValue = {
            quantity: value,
            id: selection.get(me.getValueField()),
            uom: selection.get(me.getDisplayField())
        };
        
        cbo.setValue(currentValue.id);
        cbo.setRawValue(currentValue.uom);
        var decimals = me.getExpectedDecimals();
        var n = me.setupQuantity(txt, currentValue.quantity, decimals);
        txt.setValue(n ? n.precisionValue : currentValue.quantity);
    },

    setupQuantity: function(txt, value, decimals) {
        var numObj = this.getPrecisionNumberObject(value, decimals);
        txt.setDecimalPrecision(numObj.precision);
        txt.setDecimalToDisplay(numObj.decimalPlaces); 
        return numObj;  
    },

    onSelect: function(combo, records, options) {
        var me = this.up('panel');
        var column = me.column;
        var txt = me.items.items[0].items.items[0];
        var grid = column.container.component.grid;
        var selection = grid.selection;
        if(records.length > 0) {
            var value = records[0].get(me.getLookupValueField());
            var display = records[0].get(me.getLookupDisplayField());
            var decimals = records[0].get(me.getLookupDecimalPrecisionField());
            decimals = !iRely.Functions.isEmpty(decimals) ? decimals : me.defaultDecimals;

            if(!iRely.Functions.isEmpty(value))
                selection.set(me.getUpdateField(), value);
            if(!iRely.Functions.isEmpty(display))
                selection.set(me.getDisplayField(), display);
            selection.set(column.decimalPrecisionField, decimals);
            selection.intDecimalPlacesInternal = decimals;
            me.updateExtraFields(selection, records[0]);
            var n = me.setupQuantity(txt, txt.getValue(), decimals);
            var oldValue = txt.getValue();
            txt.setValue(n ? n.precisionValue : oldValue);
            me.fireEvent('onUOMSelect', records);
        }
    },

    resetValues: function() {
        var me = this;
        var panel = me.items.items[0];
        var cbo = panel.items.items[1];
        var txt = panel.items.items[0];

        txt.setDecimalPrecision(!iRely.Functions.isEmpty(this.defaultDecimals) ? this.defaultDecimals : 6);
        txt.setDecimalToDisplay(!iRely.Functions.isEmpty(this.defaultDecimals) ? this.defaultDecimals : 6);
        cbo.setValue(null);
        cbo.setRawValue(null);
        cbo.selection = null;
    },

    updateExtraFields: function(currentRecord, lookupRecord) {
        var me = this;
        if(me.extraUpdateFields) {
            _.each(me.extraUpdateFields, function(f) {
                if(f.sourceField && f.lookupField) {
                    var rec = lookupRecord.get(f.lookupField);
                    currentRecord.set(f.sourceField, rec);
                }
            });
        }
    },

    getBoundDecimals: function(me, data) {
        var decimalField = 'intDecimalPlaces';
        if(me.column.config.decimalPrecisionField)
            decimalField = me.column.config.decimalPrecisionField;
        var decimals = null;

        /* Get internal decimal places. Often has value from columns overriden onGetDecimalPlaces method */
        if(!iRely.Functions.isEmpty(data.intDecimalPlacesInternal))
            decimals = data.intDecimalPlacesInternal;

        /* Get the actual decimal places bound to the record. */
        if(!iRely.Functions.isEmpty(data.get(decimalField)))
            decimals = data.get(decimalField);

        return decimals;
    },

    getSelectedDecimals: function(cbo) {
        var me = this;
        var decimals = null;

        if(cbo.selection) {
            var selectedDecimal = cbo.selection.get(me.getLookupDecimalPrecisionField());
            if(!iRely.Functions.isEmpty(selectedDecimal))
                decimals = selectedDecimal;
            var value = cbo.selection.get(me.getLookupValueField());
        }
        return decimals;
    },

    setupCombobox: function(me, cbo) {
        var grid = me.column.container.component.grid;
        var selection = grid.selection;

        cbo.displayField = me.getDisplayField();
        cbo.valueField = me.getValueField();
        
        //TODO: Setup custom gridcombobox columns
        this.setupComboboxFilters(me, cbo);
        this.setupComboboxEvents(cbo);
        this.setupStore(me, cbo);
    },

    getPrecisionNumberObject: function(value, decimals) {
        var zeroes = "";
        for(var i = 0; i < decimals; i++) {
            zeroes += "0";
        }

        var pattern = "0,0.[" + zeroes + "]";
        var precision = decimals;
        var decimalToDisplay = decimals;

        var formatted = numeral(value).format(pattern);
        var precisionValue = numeral(value)._value;
        var decimalDigits = (((numeral(formatted)._value).toString()).split('.')[1] || []);
        var decimalPlaces = decimalDigits.length;

        return {
            value: value,
            precisionValue: precisionValue,
            zeroes: zeroes,
            pattern: pattern,
            precision: precision,
            formatted: formatted,
            decimalPlaces: decimalPlaces,
            decimalDigits: decimalDigits
        };
    },

    setupComboboxEvents: function(cbo) {
        cbo.on('select', this.onSelect);
        cbo.on('expand', this.onDropdown);
    },

    setupTextboxEvents: function(txt) {
        txt.on('blur', this.onBlur);
    },

    onBlur: function(field, event) {
        var me = this.up('panel');
        var n = me.setupQuantity(field, field.lastValue, field.decimalPrecision);
        var origValue = field.getValue();
        field.setValue(n ? n.precisionValue : origValue);
    },

    onDropdown: function(combo) {
        var me = this.up('panel');
        var store = combo.getStore();
        me.setupComboboxFilters(me, combo);
        if(store)
            store.load({
                callback: function(records, op, success) {
                    
                }
            });
    },

    setupComboboxFilters: function(me, cbo) {
        var grid = me.column.container.component.grid;
        var selection = grid.selection;

        var cfg = me.storeConfig;
        if(cfg) {
            if(cfg.defaultFilters) {
                var vm = grid.gridMgr.configuration.viewModel;
                var filters = _.map(cfg.defaultFilters, function(filter) {
                    var actualFilter = {};
                    actualFilter.column = filter.column;
                    if(filter.source === 'grid') {
                        actualFilter.value = selection.get(filter.valueField);
                    } else if (filter.source === 'current') {
                        if(vm && vm.data.current)
                            actualFilter.value = vm.data.current.get(filter.valueField);
                    } else {
                        if(filter.value)
                            actualFilter.value = filter.value;
                    }
                    actualFilter.conjunction = (filter.conjunction ? filter.conjunction : 'and');
                    actualFilter.condition = (filter.condition ? filter.condition : 'eq');
                    return actualFilter;
                });
                cbo.defaultFilters = filters;    
            }
            var cboConfig = cfg.comboBoxConfig;
            if(cboConfig) {
                var columns = cboConfig.columns;
                if(columns)
                    cbo.columns = columns;
                if(cboConfig.displayField)
                    cbo.displayField = cboConfig.displayField;
                if(cboConfig.valueField)
                    cbo.valueField = cboConfig.valueField;
            }
        }
    },

    createStore: function(type, cfg) {
        return Ext.create(type, cfg ? cfg : { pageSize: 50, autoLoad: false });
    },

    setupStore: function(me, cbo) {
        var cfg = me.storeConfig;
        var store = this.createStore('Inventory.store.BufferedUnitMeasure');
        if(cfg && cfg.type)
            store = this.createStore(cfg.type);
        cbo.bindStore(store);
    },

    getValueField: function() {
        var me = this;
        return me.valueField ? me.valueField : 'intUnitMeasureId';
    },

    getDisplayField: function() {
        var me = this;
        return me.displayField ? me.displayField : me.valueField;
    },

    getUpdateField: function() {
        var me = this;
        return me.updateField ? me.updateField : me.valueField;
    },

    getLookupValueField: function() {
        var me = this;
        return me.lookupValueField ? me.lookupValueField : me.valueField;
    },

    getLookupDisplayField: function() {
        var me = this;
        return me.lookupDisplayField ? me.lookupDisplayField : me.displayField;
    },

    getLookupDecimalPrecisionField: function() {
        var me = this;
        return me.decimalsField ? me.decimalsField : 'intDecimalPlaces';
    },

    items: [
        {
            xtype: 'container',
            margin: '0 0 0 0',
            flex: 1,
            layout: {
                type: 'hbox',
                align: 'stretch'
            },
            items: [
                {
                    xtype: 'numberfield',
                    flex: 1,
                    margin: '0 2 0 0',
                    decimalPrecision: 6,
                    decimalToDisplay: 6,
                    fieldLabel: 'Quantity',
                    hideLabel: true,
                    labelWidth: 80,
                },
                {
                    xtype: 'gridcombobox',
                    flex: 1,
                    margin: '0 0 0 0',
                    fieldLabel: '',
                    columns: [
                        { 
                            dataIndex: 'intUnitMeasureId',
                            text: 'Id',
                            flex: 1,
                            hidden: true
                        },
                        { 
                            dataIndex: 'strUnitMeasure',
                            text: 'Unit Measure',
                            flex: 1
                        },
                        { 
                            dataIndex: 'strSymbol',
                            text: 'Symbol',
                            flex: 1
                        },
                        { 
                            dataIndex: 'strUnitType',
                            text: 'Type',
                            flex: 1
                        },
                        { 
                            dataIndex: 'intDecimalPlaces',
                            text: 'Decimal Places',
                            flex: 1,
                            hidden: true
                        }
                    ],
                    dataIndex: 'intUnitMeasureId',
                    displayField: 'strUnitMeasure',
                    valueField: 'intUnitMeasureId',
                    labelWidth: 60,
                    hideLabel: true,
                }
            ]
        }
    ]
});