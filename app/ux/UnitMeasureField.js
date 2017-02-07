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

Ext.define('Inventory.ux.UnitMeasureField', {
    extend: 'Ext.panel.Panel',
    xtype: 'unitmeasurefield',
    alias: 'widget.icunitmeasurefield',
    
    requires: [
        'Ext.form.field.ComboBox',
        'Ext.form.field.Text',
        'Ext.form.Label',
        'Inventory.ux.CurrencyNumberField',
        'Inventory.ux.UnitMeasureFieldViewModel'
    ],

    viewModel: 'icunitmeasurefield',

    layout: 'fit',
    padding: 0, 
    margin: 0,
    border: 0,

    publishes: [
        'getUnitMeasure',
        'setUnitMeasure',
        'getQuantity',
        'setQuantity'
    ],

    config: {
         unitMeasure: null,
         quantity: 0.00
    },

    getUnitMeasure: function() {
        if(this.viewModel)
            return this.viewModel.get('unitMeasureId');
        return null;
    },

    setUnitMeasure: function(value) {
        if(this.viewModel)
            this.viewModel.set('unitMeasureId', value);
    },

    getQuantity: function() {
        if(this.viewModel)
            return this.viewModel.get('quantity');
        return null;
    },

    setQuantity: function(value) {
        if(this.viewModel)
            this.viewModel.set('quantity', value);
    },

    getValue: function() {
        return {
            quantity: this.getQuantity(),
            unitMeasureId: this.getUnitMeasure()
        };
    },

    setValue: function(value) {
        if(value) {
            if(value.unitMeasureId)
                this.setUnitMeasure(value.unitMeasureId);
            if(value.quantity)
                this.setQuantity(value.quantity);
        }
    },

    initComponent: function(options) {
        this.callParent(arguments);
        
        var txtQuantity = this.down('numberfield');
        var cboUnitMeasure = this.down('gridcombobox');
        var store = Ext.create('Inventory.store.BufferedUnitMeasure', { pageSize: 50 });
        if(this.defaultFilters)
            cboUnitMeasure.defaultFilters = this.defaultFilters;
        cboUnitMeasure.bindStore(store);
        store.load();
        var uomId = parseInt(this.viewModel.get('unitMeasureId'));
        cboUnitMeasure.setValue(uomId);
        var uom = cboUnitMeasure.findRecordByValue(uomId);
        if(uom && uom.get('strUnitMeasure'))
            cboUnitMeasure.setRawValue(uom.get('strUnitMeasure'));
        else
            cboUnitMeasure.setRawValue(uomId);
        //cboUnitMeasure.on('select', this.onUnitMeasurementChange);
       // txtQuantity.on('change', this.onQuantityChange);
    },

    onQuantityChange: function(textfield, newValue, oldValue) {
        var panel = textfield.up('panel');
        var cboUnitMeasure = panel.down('gridcombobox');

        var decimal = 2;
        if(cboUnitMeasure.selection)
            decimal = cboUnitMeasure.selection.get('intDecimalPlaces');
        var format = "";
        for (var i = 0; i < decimal; i++)
            format += "0";
        if(decimal === 0) {
            textfield.setDecimalPrecision(0);
            textfield.setDecimalToDisplay(0);
            var f = numeral(newValue).format('0,0');
            textfield.setValue(f);
            textfield.setRawValue(f);
        } else {
            var formatted = numeral(newValue).format('0,0.[' + format + ']');
            var decimalToDisplay = (((numeral(formatted)._value).toString()).split('.')[1] || []).length; //decimalPlaces(numeral(formatted)._value);
            textfield.setDecimalPrecision(decimal);
            textfield.setDecimalToDisplay(decimalToDisplay);
            textfield.setValue(formatted);
            textfield.setRawValue(formatted);  
        }
    },

    onUnitMeasurementChange: function(combo, records, eOptss) {
        var panel = combo.up('panel');
        var txtQuantity = panel.down('numberfield');
        if(records && records.length > 0) {
            var decimal = records[0].get('intDecimalPlaces');      
            var format = "";
            for (var i = 0; i < decimal; i++)
                format += "0";
            var val = txtQuantity.getValue();
            var formatted = numeral(val).format('0,0.[' + format + ']');
            var decimalToDisplay = (((numeral(formatted)._value).toString()).split('.')[1] || []).length; //decimalPlaces(numeral(formatted)._value);
            txtQuantity.setDecimalPrecision(decimal);
            txtQuantity.setDecimalToDisplay(decimalToDisplay);
            txtQuantity.setValue(formatted);
            txtQuantity.setRawValue(formatted);
        }
    },

    items: [
        {
            xtype: 'container',
            margin: '0 0 5 0',
            layout: {
                type: 'hbox',
                align: 'stretch'
            },
            items: [
                {
                    xtype: 'numberfield',
                    flex: 3,
                    margin: '0 5 0 0',
                    decimalPrecision: 6,
                    decimalToDisplay: 6,
                    fieldLabel: 'Quantity',
                    bind: {
                        value: '{quantity}'
                    },
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
                            flex: 1
                        }
                    ],
                    dataIndex: 'intUnitMeasureId',
                    displayField: 'strUnitMeasure',
                    valueField: 'intUnitMeasureId',
                    labelWidth: 60,
                    hideLabel: true,
                    bind: {
                        value: '{unitMeasureId}'
                    }
                }
            ]
        }
    ]
});