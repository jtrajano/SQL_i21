var decimalPlaces = function(){
   function isInt(n){
      return typeof n === 'number' && 
             parseFloat(n) == parseInt(n, 10) && !isNaN(n);
   }
   return function(n){
      var a = Math.abs(n);
      var c = a, count = 1;
      while(!isInt(c) && isFinite(c)){
         c = a * Math.pow(10,count++);
      }
      return count-1;
   };
}();
/**
 * The following fields are required in the grid:
 * 1. intUnitMeasureId
 * 2. strUnitMeasure
 * 3. dblUnitQty
 */
Ext.define('Inventory.ux.GridUOMField', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.griduomfield',
    mixins: {
        field: 'Ext.form.field.Field'
    },

    initComponent: function() {
        this.callParent(arguments);
        var me = this;
        var panel = me.items.items[0];
        var cbo = panel.items.items[1];
        var txt = panel.items.items[0];
        var grid = me.column.container.component.grid;
        var selection = grid.selection;

        this.setupCombobox(me, cbo);
    },

    constructor: function(config) {
        this.callParent([config]);
    },

    getValue : function(){
        var me = this;
        var panel = me.items.items[0];
        var cbo = panel.items.items[1];
        var txt = panel.items.items[0];
        var grid = me.column.container.component.grid;
        var selection = grid.selection;

        var value = txt.getValue();
        return value;
    },

    setValue: function(value) {
        var me = this;
        var panel = me.items.items[0];
        var cbo = panel.items.items[1];
        var txt = panel.items.items[0];
        var grid = me.column.container.component.grid;
        var selection = grid.selection;
        var currentValue = {
            quantity: value,
            id: selection.get(me.getValueField()),
            uom: selection.get(me.getDisplayField())
        };
        
        cbo.setValue(currentValue.id);
        cbo.setRawValue(currentValue.uom);
        txt.setValue(currentValue.quantity);
    },
    
    setupCombobox: function(me, cbo) {
        var grid = me.column.container.component.grid;
        var selection = grid.selection;

        cbo.displayField = me.getDisplayField();
        cbo.valueField = me.getValueField();
        
        this.setupComboboxFilters(me, cbo);
        this.setupComboboxEvents(cbo);
        this.setupStore(me, cbo);
    },

    formatDisplay: function(value) {
        return 0.00;
    },

    getRoundedNumberObject: function(value, decimals, defaultDecimals) {
        if(!decimals)
            decimals = defaultDecimals ? defaultDecimals : 6;
        var zeroes = "";
        for(var i = 0; i < decimals; i++) {
            zeroes += "0";
        }

        var pattern = "0,0.[" + zeroes + "]";
        var precision = decimals;
        var decimalToDisplay = decimals;

        var formatted = numeral(value).format(pattern);
        var formattedNoTrailingZeroes = (formatted._value.toString().split(".")[1] || []);
        var decimalPlaces = formattedTrimmed.length;

        return {
            value: value,
            pattern: pattern,
            precision: precision,
            formatted: formatted,
            decimalPlaces: decimalPlaces,
            formattedNoTrailingZeroes: formattedNoTrailingZeroes,
            decimals: decimals
        };
    },

    setupComboboxEvents: function(cbo) {
        cbo.on('select', this.onSelectUOM);
        cbo.on('expand', this.onDropdown);
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

    onSelectUOM: function(combo, records, options) {
        var me = this.up('panel');
        var grid = me.column.container.component.grid;
        var selection = grid.selection;
        if(records.length > 0) {
            selection.set(me.getUpdateField(), records[0].get(me.getLookupValueField()));
            selection.set(me.getDisplayField(), records[0].get(me.getLookupDisplayField()));
        }
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
                    }
                    actualFilter.conjunction = (filter.conjunction ? filter.conjunction : 'and');
                    actualFilter.condition = (filter.condition ? filter.condition : 'eq');
                    return actualFilter;
                });
                cbo.defaultFilters = filters;    
            }
        }
    },

    createStore: function(type, cfg) {
        return Ext.create(type, cfg ? cfg : { pageSize: 50, autoLoad: true });
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
        return me.valueField;
    },

    getDisplayField: function() {
        var me = this;
        return me.displayField;
    },

    getUpdateField: function() {
        var me = this;
        return me.updateField ? me.updateField : me.valueField;
    },

    getLookupValueField: function() {
        var me = this;
        return me.lookupvalueField ? me.lookupvalueField : me.valueField;
    },

    getLookupDisplayField: function() {
        var me = this;
        return me.lookupDisplayField ? me.lookupDisplayField : me.displayField;
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