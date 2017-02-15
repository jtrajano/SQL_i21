/**
 * @author Wendell Wayne H. Estrada
 * @copyright 2017 iRely Philippines
 * http://inet.irelyserver.com/display/INV/Grid+Unit+of+Measure+Field
 */
Ext.define('Inventory.ux.GridUOMField', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.griduomfield',

    mixins: {
        field: 'Ext.form.field.Field',
        observable : 'Ext.util.Observable'
    },

    constructor : function(config){
        this.callParent([config]);
        this.mixins.observable.constructor.call(this, config);
    },

    renderConfig: {
        editable: true
    },

    config: {
        uom: null,
        txtQuantity: undefined,
        cboUom: undefined,
        store: undefined,
        DEFAULT_DECIMALS: 6
    },

    initComponent: function() {
        var me = this;
        me.flex = 1;
        me.layout = 'fit';
        me.callParent(arguments);
        me.initField();
        me.initControls();
    },

    /**
     * Initializes the textbox and combobox.
     */
    initControls: function() {
        var me = this;
        var panel = me.items.items[0];
        me.txtQuantity = panel.items.items[0];
        me.cboUom = panel.items.items[1];

        if (me.readOnly) {
            me.txtQuantity.setReadOnly(me.readOnly);
            me.cboUom.setReadOnly(me.readOnly);
        }

        me.setupBindings();
        me.setupFilters();
        me.setupEvents();
        me.setupStore();
        me.loadStore();
    },

    setupBindings: function() {
        var me = this;
        me.cboUom.displayField = me.getDisplayField();
        me.cboUom.valueField = me.getValueField();
    },

    setupFilters: function() {
        var me = this,
            grid = me.getGrid(),
            cfg = me.storeConfig;
            
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
                me.cboUom.defaultFilters = filters;    
            }
            var cboConfig = cfg.comboBoxConfig;
            if(cboConfig) {
                var columns = cboConfig.columns;
                if(columns)
                    me.cboUom.columns = columns;
                if(cboConfig.displayField)
                    me.cboUom.displayField = cboConfig.displayField;
                if(cboConfig.valueField)
                    me.cboUom.valueField = cboConfig.valueField;
            }
        }
    },

    setupEvents: function() {
        var me = this,
            txtQuantity = me.txtQuantity,
            plugin = me.getEditingPlugin();
        
        txtQuantity.on('keypress', function(field, event) {
            if(event.keyCode === 13) {
                plugin.completeEdit();
                event.stopEvent();
                event.preventDefault();
                event.stopPropagation();
            }
        });
    },

    createStore: function(type, cfg) {
        return Ext.create(type, cfg ? cfg : { pageSize: 50, autoLoad: false });
    },

    setupStore: function() {
        var me = this;
        var cfg = me.storeConfig;
        var store = this.createStore('Inventory.store.BufferedUnitMeasure');
        if(cfg && cfg.type)
            store = this.createStore(cfg.type);
        me.store = store;
        me.cboUom.bindStore(me.store);
    },

    loadStore: function() {
        var me = this;
        me.store.load();
    },

    getValue: function(){
        var me = this,
            plugin = me.getEditingPlugin(),
            activeRecord = null,
            newValue = me.value;
        
        if(me.isEditorComponent) {
            newValue = me.txtQuantity.getValue();
            if(plugin) {
                activeRecord = plugin.context.record;
                var strUOM = activeRecord.get(me.getDisplayField());
                var intUOM = activeRecord.get(me.getValueField());
                var decimals = me.getUomDecimals(intUOM);
                var po = me.getPrecisionNumberObject(newValue, decimals);
                if(po) {
                    newValue = po.precisionValue;
                }
            }
        }

        me.value = newValue;
        return newValue;
    },

    resetValues: function() {
        var me = this;

        me.txtQuantity.setDecimalPrecision(!iRely.Functions.isEmpty(me.DEFAULT_DECIMALS) ? me.DEFAULT_DECIMALS : 6);
        me.txtQuantity.setDecimalToDisplay(!iRely.Functions.isEmpty(me.DEFAULT_DECIMALS) ? me.DEFAULT_DECIMALS : 6);
        me.txtQuantity.setValue(null);
        me.cboUom.setValue(null);
        me.cboUom.setRawValue(null);
        me.cboUom.selection = null;
    },

    setValue: function(value) {
        var me = this,
            store = me.store,
            activeRecord = null,
            plugin = me.getEditingPlugin();
        me.resetValues();

        if(plugin) {
            activeRecord = plugin.context.record;
        }

        // Reload uom store if has a pending request and re-initialize value and precision.
        if(me.store.hasPendingLoad()) {
            me.store.load({
                callback: function(records, op, success) {
                    me.setValue(value);
                }
            });
        }

        var newValue = value;

        // Count decimal places based on UOM and set text decimal precision
        if(activeRecord) {
            var strUOM = activeRecord.get(me.getDisplayField());
            var intUOM = activeRecord.get(me.getValueField());
            me.cboUom.setValue(intUOM);
            me.cboUom.setRawValue(strUOM);

            var decimals = me.getUomDecimals(intUOM);
            newValue = me.setupDecimalPrecision(value, decimals, false);
        }
        
        me.value = newValue;
        me.txtQuantity.setValue(newValue);

        return me;
    },

    setupDecimalPrecision: function(value, decimals, removeTrailingZeroes) {
        var me = this;
        var po = me.getPrecisionNumberObject(value, decimals);
        if(po) {
            me.txtQuantity.setDecimalPrecision(po.precision);
            me.txtQuantity.setDecimalToDisplay(removeTrailingZeroes ? po.decimalPlaces : po.precision); 
            return po.precisionValue;
        }
        return value;
    },

    getUomDecimals: function(id) {
        var me = this;
        var index = me.store.findExact(me.getLookupValueField(), id);
        var record = me.store.getAt(index);
        if(record) {
            var decimals = record.get(me.getLookupDecimalPrecisionField());
            return me.isNullOrEmpty(decimals) ? me.DEFAULT_DECIMALS : decimals;
        }
        return me.DEFAULT_DECIMALS;
    },

    // getErrors: function(value) {
    //     var me = this,
    //         errors = [];
    //     errors.push("Invalid quantity uom.");
    //     return errors;
    // },

    getGrid: function() {
        var me = this;
        return me.column.container.component.grid;
    },

    getEditor: function() {
        var me = this;
        return me.container;
    },

    getEditingPlugin: function() {
        var me = this;
        return me.column.container.component.view.editingPlugin;
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

    isNullOrEmpty: function(value) {
        return iRely.Functions.isEmpty(value);
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