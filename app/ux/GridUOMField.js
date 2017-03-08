/**
 * @author Wendell Wayne H. Estrada
 * @copyright 2017 iRely Philippines
 * http://inet.irelyserver.com/display/INV/Grid+Unit+of+Measure+Field
 */
Ext.define('Inventory.ux.GridUOMField', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.griduomfield',
    xtype: 'griduomfield',
    
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
        DEFAULT_DECIMALS: 6,
        customValue: null
    },

    txtQuantity: undefined,
    
    cboUom: undefined,
    
    store: undefined,

    modifiedRows: [],

    syncModifiedRow: function(id, data) {
        var me = this;
        var found = _.findWhere(me.modifiedRows, { id: id });
        if(found) {
            found.data = _.extend(found.data, data);
        } else {
            me.modifiedRows.push({
                id: id,
                data: data
            });
        }
    },

    getModifiedRow: function(id) {
        var me = this;
        var found = _.findWhere(me.modifiedRows, { id: id });
        return found;
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
        me.setupComboboxFilters();
        me.setupEvents();
        me.setupStore();
        me.loadStore();
    },

    setupBindings: function() {
        var me = this;
        me.cboUom.displayField = me.getDisplayField();
        me.cboUom.valueField = me.getValueField();
    },

    setupComboboxFilters: function() {
        var me = this,
            grid = me.getGrid(),
            cfg = me.storeConfig,
            activeRecord = null,
            plugin = me.getEditingPlugin();
            
        if(plugin) {
            if(plugin.context)
                activeRecord = plugin.context.record;
            else {
                activeRecord = grid.selection;
            }
        }

        if(cfg) {
            if(cfg.defaultFilters) {
                var vm = grid.gridMgr.configuration.viewModel;
                me.cboUom.defaultFilters = me.createDynamicFilters(cfg.defaultFilters, vm, activeRecord);    
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

    createDynamicFilters: function(filters, vm, activeRecord) {
        var result = _.map(filters, function(filter) {
            var actualFilter = {};
            actualFilter.column = filter.column;
            if(filter.source === 'grid') {
                if(activeRecord)
                    actualFilter.value = activeRecord.get(filter.valueField);
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

        return result;
    },

    setupQueryParams: function() {
        var me = this,
            grid = me.getGrid(),
            vm = grid.gridMgr.configuration.viewModel;
            activeRecord = null,
            plugin = me.getEditingPlugin(),
            cfg = me.storeConfig,
            cboCfg = (cfg ? cfg.comboBoxConfig : null);
        
        if(plugin) {
            if(plugin.context)
                activeRecord = plugin.context.record;
            else {
                activeRecord = grid.selection;
            }
        }

        var dynamicFilters = cfg && cfg.defaultFilters ? me.createDynamicFilters(cfg.defaultFilters, vm, activeRecord) : [],
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

    setupEvents: function() {
        var me = this,
            plugin = me.getEditingPlugin();

        me.txtQuantity.on('keypress', function(field, event) {
            if(event.keyCode === 13) {
                plugin.completeEdit();
                event.stopEvent();
                event.preventDefault();
                event.stopPropagation();
            }
        });

        me.txtQuantity.on('blur', function(field, event) {
            me.setValue(field.lastValue, true);
        });

        me.cboUom.on('select', function(combo, records, options) {
            if(records.length > 0) {
                var activeRecord = null;
                if(plugin) {
                    activeRecord = plugin.context.record;
                }
                if(activeRecord) {
                    me.updateRequiredFields(activeRecord, records[0]);
                    me.updateExtraFields(activeRecord, records[0]);
                }

                me.setValue(me.txtQuantity.getValue(), true);
                if(activeRecord) {
                    var param = {
                        id: activeRecord.internalId,
                        data: {
                            intUOMId: records[0].get(me.getLookupValueField()),
                            strUOMId: records[0].get(me.getLookupDisplayField()),
                            intDecimals: records[0].get(me.getLookupDecimalPrecisionField())
                        }
                    };
                    me.syncModifiedRow(param.id, param.data);
                }
                me.fireEvent('onUOMSelect', plugin, records, combo);
            }
        });
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
                if(activeRecord) {
                    var strUOM = activeRecord.get(me.getDisplayField());
                    var intUOM = activeRecord.get(me.getValueField());

                    // if(me.cboUom.selection) {
                    //     strUOM = me.cboUom.getRawValue();
                    //     intUOM = me.cboUom.getValue();
                    // }

                    var decimals = me.getUomDecimals(intUOM);
                    var po = me.getPrecisionNumberObject(newValue, decimals);
                    if(po) {
                        newValue = po.precisionValue;
                    }
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

    setValue: function(value, removeTrailingZeroes) {
        var me = this,
            store = me.store,
            activeRecord = null,
            plugin = me.getEditingPlugin();
                
        if(plugin) {
            activeRecord = plugin.context.record;
        }
        me.setupQueryParams();
        me.setupComboboxFilters();
        // Reload uom store if has a pending request and re-initialize value and precision.
        // if(me.store.hasPendingLoad()) {
        //     me.isLoading = true;
        //     me.store.load({
        //         callback: function(records, op, success) {
        //             me.isLoading = false;
        //             me.setValue(value);
        //         }
        //     });
        // }

         me.store.load({
             callback: function() {
                var newValue2 = value;
                // Count decimal places based on UOM and set text decimal precision
                if(plugin) {
                    activeRecord = plugin.context.record;
                    if(activeRecord) {
                        var strUOM2 = activeRecord.get(me.getDisplayField());
                        var intUOM2 = activeRecord.get(me.getValueField());

                        // if(me.cboUom.selection) {
                        //     strUOM = me.cboUom.getRawValue();
                        //     intUOM = me.cboUom.getValue();
                        // }

                        // var modifiedRecord = me.getModifiedRow(activeRecord.internalId);
                        // if(modifiedRecord) {
                        //     intUOM = modifiedRecord.data.intUOMId;
                        //     strUOM = modifiedRecord.data.strUOM;
                        // }

                        me.cboUom.setValue(intUOM2);
                        me.cboUom.setRawValue(strUOM2);
                        
                        me.setComboboxSelection(intUOM2);
                        //me.setupQueryParams();
                        var decimals = me.getUomDecimals(intUOM2);
                        newValue2 = me.setupDecimalPrecision(value, decimals, removeTrailingZeroes);
                    }
                }
                
                me.value = newValue;
                me.txtQuantity.setValue(newValue);     
             }
         });

        var newValue = value;
        // Count decimal places based on UOM and set text decimal precision
        if(plugin) {
            activeRecord = plugin.context.record;
            if(activeRecord) {
                var strUOM = activeRecord.get(me.getDisplayField());
                var intUOM = activeRecord.get(me.getValueField());

                // if(me.cboUom.selection) {
                //     strUOM = me.cboUom.getRawValue();
                //     intUOM = me.cboUom.getValue();
                // }

                // var modifiedRecord = me.getModifiedRow(activeRecord.internalId);
                // if(modifiedRecord) {
                //     intUOM = modifiedRecord.data.intUOMId;
                //     strUOM = modifiedRecord.data.strUOM;
                // }

                me.cboUom.setValue(intUOM);
                me.cboUom.setRawValue(strUOM);
                
                me.setComboboxSelection(intUOM);
                //me.setupQueryParams();
                var decimals = me.getUomDecimals(intUOM);
                newValue = me.setupDecimalPrecision(value, decimals, removeTrailingZeroes);
            }
        }
        
        me.value = newValue;
        me.txtQuantity.setValue(newValue);

        return me;
    },

    updateRequiredFields: function(currentRecord, lookupRecord) {
        var me = this;
        var value = lookupRecord.get(me.getLookupValueField());
        var display = lookupRecord.get(me.getLookupDisplayField());

        if(!me.isNullOrEmpty(value))
            currentRecord.set(me.getUpdateField(), value);

        if(!me.isNullOrEmpty(display))
            currentRecord.set(me.getDisplayField(), display);
        
        var decimal = lookupRecord.get(me.getLookupDecimalPrecisionField());
        currentRecord.set(me.getDecimalPrecisionField(), decimal);
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

    setComboboxSelection: function(id) {
        var me = this;
        var index = me.store.findExact(me.getLookupValueField(), id);
        var record = me.store.getAt(index);
        if(record) {
            me.cboUom.setSelection(record);
        }
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
        if(me.column.container.component)
            return me.column.container.component.view.editingPlugin;
        return null;
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

    getDecimalPrecisionField: function() {
        var me = this;
        return me.column && me.column.decimalPrecisionField ? me.column.decimalPrecisionField : 'intDecimalPlaces';
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
        }
    ]
});