/**
 * @author Wendell Wayne H. Estrada
 * @copyright 2017 iRely Philippines
 * http://inet.irelyserver.com/display/INV/Grid+Unit+of+Measure+Field
 */
Ext.define('Inventory.ux.UOMField', {
    extend: 'Ext.form.FieldContainer',
    alias: 'widget.uomfield',
    xtype: 'uomfield',

    mixins: {
        field: 'Ext.form.field.Field',
        observable: 'Ext.util.Observable'
    },

    renderConfig: {
        editable: true
    },

    DEFAULT_DECIMALS: 6,
    config: {
        readOnly: false,
        readOnlyMode: 'both',
        readOnlyQty: false,
        readOnlyUom: false,
        activeRecord: undefined,
        selectOnFocus: true,
        mutateSource: true,
        mutateByProperties: false
    },

    getReadOnly: function() {
        return this.readOnly;
    },

    setReadOnly: function(value) {
        this.readOnly = value;

        if(this.readOnlyMode === 'uom') {
            this.toggleReadOnlyUom(value);    
        } else if(this.readOnlyMode === 'qty') {
            this.toggleReadOnlyQty(value);
        } else if(this.readOnlyMode === 'independent') { 
            this.toggleReadOnlyQty(this.readOnlyQty);
            this.toggleReadOnlyUom(this.readOnlyUom);    
        } else {
            this.toggleReadOnlyQty(value);
            this.toggleReadOnlyUom(value);
        }

        if(this.txtQuantity) {
            if(this.getReadOnlyUom()) {
                this.txtQuantity.setDecimalPrecision(this.DEFAULT_DECIMALS);
                this.txtQuantity.setDecimalToDisplay(this.DEFAULT_DECIMALS);
                this.setupDecimalPrecision(this.txtQuantity.getValue(), this.DEFAULT_DECIMALS);
            } else {
                if(this.getValue()) {
                    var decimals = this.getUomDecimals(this.getValue()["intUnitMeasureId"]);
                    var qty = this.setupDecimalPrecision(this.getValue()["dblQuantity"] 
                        ? this.getValue()["dblQuantity"] : (this.activeRecord ? this.activeRecord.get(this.getUpdateField()) : null), decimals) ;
                    this.txtQuantity.setDecimalPrecision(decimals);
                    this.txtQuantity.setDecimalToDisplay(decimals);
                    this.txtQuantity.setRawValue(qty);
                    this.txtQuantity.setValue(qty);
                }
            }
        }
    },
    
    toggleReadOnlyQty: function(value) {
        if(this.txtQuantity)
            this.txtQuantity.setReadOnly(value);
        this.readOnlyQty = value;
    },

    toggleReadOnlyUom: function(value) {
        if(this.cboUom)
            this.cboUom.setReadOnly(value);
        this.readOnlyUom = value;
    },

    panel: undefined,
    txtQuantity: undefined,
    cboUom: undefined,

    store: undefined,

    constructor: function (config) {
        this.callParent([config]);
        this.mixins.observable.constructor.call(this, config);
    },

    initComponent: function() {
        var me = this;
        me.items = me.createChild();

        me.panel = me.items;
        me.txtQuantity = me.items.items.items[0];
        me.cboUom = me.items.items.items[1];

        me.setupBindings();
        me.setupComboboxFilters();
        me.setupEvents();
        me.setupStore();
        me.loadStore();

        this.callParent(arguments);    
    },

    setupEvents: function() {
        var me = this;

        me.onTextFocus();
        me.onTextBlur();
        me.onUOMSelect();
        me.onUOMExpand();
    },

    createStore: function(type, cfg) {
        return Ext.create(type, cfg ? cfg : { pageSize: 50, autoLoad: false, remoteFilter: true });
    },

    setupStore: function() {
        var me = this;
        var cfg = me.storeConfig;
        var store = this.createStore('Inventory.store.BufferedUnitMeasure');
        if(cfg && cfg.type)
            store = this.createStore(cfg.type);
        me.store = store;
        me.setupQueryParams();
        me.cboUom.bindStore(me.store);
    },

    loadStore: function() {
        var me = this;
        me.store.load();
        
        var ls = ic.getCachedUoms();
    },

    setupBindings: function() {
        var me = this;
        me.cboUom.displayField = me.getDisplayField();
        me.cboUom.valueField = me.getValueField();
    },

    setupComboboxFilters: function() {
        var me = this,
            cfg = me.storeConfig;

        if(cfg) {
            if(cfg.defaultFilters) {
                me.cboUom.defaultFilters = me.createDynamicFilters(cfg.defaultFilters, me.activeRecord);    
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

    createDynamicFilters: function(filters, activeRecord) {
        var me = this;
        var result = _.map(filters, function(filter) {
            var actualFilter = {};
            actualFilter.column = filter.column;
            actualFilter.value = filter.value;

            if(filter.valueField && me.activeRecord) {
                actualFilter.value = me.activeRecord.get(filter.valueField);
            }

            actualFilter.conjunction = (filter.conjunction ? filter.conjunction : 'and');
            actualFilter.condition = (filter.condition ? filter.condition : 'eq');

            return actualFilter;
        });

        return result;
    },

    setupQueryParams: function() {
        var me = this,
            cfg = me.storeConfig,
            cboCfg = (cfg ? cfg.comboBoxConfig : null);

        var dynamicFilters = cfg && cfg.defaultFilters ? me.createDynamicFilters(cfg.defaultFilters, me.activeRecord) : [],
            filterParam = cfg && cfg.defaultFilters ? iRely.Functions.encodeFilters(dynamicFilters) : "[]",
            columnsParam = me.encodeColumnsParam(cfg && cboCfg && cboCfg.columns ? cboCfg.columns : me.cboUom.columns);

        if(cboCfg) {
            me.store.proxy.extraParams = {
                filter: filterParam,
                columns: columnsParam,
                page: 1,
                start: 0,
                limit: 50
            };
        }
    },

    encodeColumnsParam: function(columns) {
        var cols = "";
        _.each(columns, function(c) {
            cols += c.dataIndex + ":";
        });
        return cols;
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

    getQuantityValueField: function() {
        var me = this;
        return me.quantityValueField ? me.quantityValueField : 'dblQuantity';   
    },

    getUomValueField: function() {
        var me = this;
        return me.uomValueField ? me.uomValueField : 'strUnitMeasure';   
    },

    getObjectKey: function() {
        var me = this;
        return me.objectKey ? me.objectKey : 'objValue';
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

    setComboboxSelection: function(id, uom) {
        var me = this;
        var index = me.store.findExact(me.getLookupValueField(), id);
        var record = me.store.getAt(index);
        if(record) {
            me.cboUom.setRawValue(record.get(me.getLookupDisplayField()));
            me.cboUom.setValue(record.get(me.getLookupDisplayField()));
            me.cboUom.setSelection(record);
            return record;
        } else {
            if(id !== 0 && id !== -1 && id != null) {
                me.cboUom.setRawValue(id);
                me.cboUom.setValue(uom);
            }
        }
        return false;
    },
     
    setValue: function(value, removeTrailingZeroes) {
        var me = this;
        var qty = 0,
            uom = null,
            uomid = null;

        if(me.activeRecord && !me.activeRecord.dirty) {
            qty = me.activeRecord.get(me.getQuantityValueField());
            uomid = me.activeRecord.get(me.getUpdateField());    
            uom = uomid ? me.activeRecord.get(me.getDisplayField()) : null;
        }

        var fieldQty = "dblQuantity",
            fieldDisplay = "strUnitMeasure",
            fieldId = "intUnitMeasureId";

        if(value) {
            qty = value[fieldQty];
            uomid = value[fieldId];
            uom = uomid ? value[fieldDisplay] : null;
        } else {
            if(me.activeRecord) {
                qty = me.activeRecord.get(me.getQuantityValueField());
                uomid = me.activeRecord.get(me.getUpdateField());
                uom = uomid ? me.activeRecord.get(me.getDisplayField()) : null;
            }
        }

        
        var selectedUOM = me.setComboboxSelection(uomid, uom);
        if(selectedUOM) {
            uomid = selectedUOM.get(me.getLookupValueField());
            uom = uomid ? selectedUOM.get(me.getLookupDisplayField()) : null;
        }

        var decimals = me.getUomDecimals(uomid);
        var origQty = qty;
        qty = me.setupDecimalPrecision(qty, decimals, removeTrailingZeroes);

        if(me.getReadOnlyUom()) {
            qty = origQty;
            me.txtQuantity.setDecimalPrecision(me.DEFAULT_DECIMALS);
            me.txtQuantity.setDecimalToDisplay(me.DEFAULT_DECIMALS);
            me.setupDecimalPrecision(qty, me.DEFAULT_DECIMALS, removeTrailingZeroes);   
        }

        me.txtQuantity.setRawValue(qty);
        me.txtQuantity.setValue(qty);

        var newValue = me.getParsedValue(qty, uomid, uom);
        value = newValue;

        var oldValue = me.getValue();
        me.value = value;
        if(me.mutateSource && me.activeRecord) {
            if(me.mutateByProperties) {
                if(value) {
                    me.activeRecord.set(me.getQuantityValueField(), me.value[fieldQty]);
                    me.activeRecord.set(me.getUpdateField(), me.value[fieldId]);
                    me.activeRecord.set(me.getDisplayField(), me.value[fieldId] ? me.value[fieldDisplay] : null);
                } else {
                    me.activeRecord.set(me.getQuantityValueField(), null);
                    me.activeRecord.set(me.getUpdateField(), null);
                    me.activeRecord.set(me.getDisplayField(), null);
                }
            } else {
                me.activeRecord.set(me.getObjectKey(), me.value);
            }
        }

        me.onChange(me.value, oldValue, selectedUOM);
    },

    getValue: function() {
        return this.value;
    },

    getSubmitValue: function() {
        return this.value;
    },

    resetValues: function() {
        var me = this;

        me.txtQuantity.setDecimalPrecision(!iRely.Functions.isEmpty(me.DEFAULT_DECIMALS) ? me.DEFAULT_DECIMALS : 6);
        me.txtQuantity.setDecimalToDisplay(!iRely.Functions.isEmpty(me.DEFAULT_DECIMALS) ? me.DEFAULT_DECIMALS : 6);
        me.txtQuantity.setValue(null);
        me.cboUom.setRawValue(null);
        me.cboUom.setValue(null);
        me.cboUom.selection = null;
    },

    onTextFocus: function() {
        var me = this;
        me.mon(me.txtQuantity, {
            scope: me,
            focus: function() {
                if(me.getSelectOnFocus())
                    me.txtQuantity.inputEl.dom.select();
            }
        });       
    },

    getParsedValue: function(quantity, uomid, uom) {
        var me = this;
        var str = '{"dblQuantity":' + (quantity ? quantity : null) + ',"intUnitMeasureId":' + (uomid ? uomid : null) + ', "strUnitMeasure":' + (uom ? '"' + uom + '"' : null) + '}';
        return JSON.parse(str);
    },

    onTextBlur: function() {
        var me = this;
        me.mon(me.txtQuantity, {
            scope: me,
            blur: function(field, event) {
                if(me.getValue()) {
                    var uomid = me.getValue()['intUnitMeasureId'];
                    var uom = me.getValue()['strUnitMeasure'];
                }
                me.setValue(me.getParsedValue(field.lastValue, uomid, uom), true);
            }
        });
    },

    onUOMSelect: function() {
        var me = this;
        me.cboUom.on('select', function(combo, records, options) {
            if(records.length > 0) {
                var qty = null;
                if(me.getValue()) {
                    qty = me.getValue()['dblQuantity'];
                }
                me.setValue(me.getParsedValue(qty, records[0].get(me.getLookupValueField()), records[0].get(me.getLookupDisplayField())));
                me.fireEvent('onuomselect', me.getValue(), me.activeRecord, records, combo);
            }
        });
    },

    onUOMExpand: function() {
        var me = this;
        me.cboUom.on('beforequery', function(combo, records, options) {
            me.setupComboboxFilters();
        });
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

    setupDecimalPrecision: function(value, decimals, removeTrailingZeroes) {
        var me = this;
        var po = me.getPrecisionNumberObject(value, decimals);
        
        if(po) {
            me.txtQuantity.setDecimalPrecision(po.precision);
            me.txtQuantity.setDecimalToDisplay(removeTrailingZeroes && removeTrailingZeroes !== undefined ? po.decimalPlaces : po.precision); 
            return po.precisionValue;
        }
        return value;
    },

    onChange: function(newValue, oldValue) {
        var me = this;
        if(!_.isEqual(newValue, oldValue))
            me.fireEvent('valuechange', newValue, oldValue, me.activeRecord, me);
    },

    createChild: function() {
        var component = Ext.create('Ext.container.Container',
        {
            // xtype: 'container',
            margin: '0 0 0 0',
            flex: 1,
            layout: {
                type: 'hbox',
                align: 'stretch'
            },
            items: [
                {
                    xtype: 'numberfield',
                    flex: 2,
                    selectOnFocus: true,
                    readOnly: this.readOnly,
                    margin: '0 0 0 0',
                    decimalPrecision: 6,
                    decimalToDisplay: 6,
                    fieldLabel: 'Quantity',
                    hideLabel: true,
                    //inputWrapCls: 'x-form-uom-text-wrap-default',
                    // remove default styling for div wrapping the input element and trigger button(s)
                    //triggerWrapCls: '',
                    // remove the input element's background
                    //fieldStyle: 'text-align: right;padding: 2px; background:none; border-left: 1px solid #cacaca; border-top: 1px solid #cacaca; border-bottom: 1px solid #cacaca',
                    labelWidth: 80
                },
                {
                    xtype: 'gridcombobox',
                    readOnly: this.readOnly,
                    grow: true,
                    flex: 1,
                    margin: '0 0 0 4',
                    border: false,
                    // maxWidth: 550,
                    minWidth: 80,
                    fieldLabel: '',
                    //inputWrapCls: '',
                    // remove default styling for div wrapping the input element and trigger button(s)
                    
                    // remove the input element's background
                    //fieldStyle: 'padding: 2px; padding-right: 3px; font-style: italic; background:none; border-right: 1px solid #cacaca; border-top: 1px solid #cacaca; border-bottom: 1px solid #cacaca',
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
                            hidden: false
                        }
                    ],
                    dataIndex: 'intUnitMeasureId',
                    displayField: 'strUnitMeasure',
                    valueField: 'intUnitMeasureId',
                    labelWidth: 60,
                    hideLabel: true,
                }
            ]
        });
        return component;
    }
});