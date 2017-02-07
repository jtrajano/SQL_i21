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
Ext.define('Inventory.ux.GridUnitMeasureField', {
    extend: 'Inventory.ux.UnitMeasureField',
    alias: 'widget.gridunitmeasurefield',
    mixins: {
        field: 'Ext.form.field.Base'
    },

    publishes: [
        'getValue',
        'setValue'
    ],

    initComponent: function() {
        this.callParent(arguments);

        var panel = this.items.items[0];
        var txt = panel.items.items[0];
        var cbo = panel.items.items[1];
        txt.hideLabel = true;
        txt.flex = 2;
        panel.margin = 0;

        var grid = this.column.container.component.grid;
        var selection = grid.selection;
        var val = { quantity: selection.get(this.column.dataIndex), unitMeasureId: selection.get(this.valueField) };
        var uom = cbo.findRecordByValue(val.unitMeasureId);
        if(uom && uom.get('strUnitMeasure'))
            cbo.setRawValue(uom.get('strUnitMeasure'));
        else
            cbo.setRawValue(selection.get(this.displayField));
        
        this.setValue(val);
        cbo.setValue(val.unitMeasureId);
        cbo.on('select', this.onUnitMeasurementChange);
    },

    onQuantityChange: function(textfield, newValue, oldValue) {
        return;
        var panel = textfield.up('panel');
        var cboUnitMeasure = panel.down('gridcombobox');
        var grid = panel.column.container.component.grid;

        var decimal = 6;
        if(cboUnitMeasure.selection) {
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
                var decimalToDisplay = (((numeral(formatted)._value).toString()).split('.')[1] || []).length;//decimalPlaces(numeral(formatted)._value);
                textfield.setDecimalPrecision(decimal);
                textfield.setDecimalToDisplay(decimalToDisplay);
                textfield.setValue(formatted);
                textfield.setRawValue(formatted);  
            }
        }
        else {
            var store = Ext.create('Inventory.store.BufferedUnitMeasure', { pageSize: 50 });
            cboUnitMeasure.bindStore(store);
            store.load({
                callback: function(records, op, success) {
                    if(success) {
                        var m = _.map(records, function(a) { return a.data; });
                        var f = _.filter(m, function(a) { return a.intUnitMeasureId === grid.selection.get('intUnitMeasureId'); });
                        
                        cboUnitMeasure.setValue(grid.selection.get('intUnitMeasureId'));
                        cboUnitMeasure.setRawValue(grid.selection.get('strUnitMeasure'));
                        
                        if(f && f.length > 0)
                            decimal = f[0].intDecimalPlaces;
                        
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
                            var decimalToDisplay = (((numeral(formatted)._value).toString()).split('.')[1] || []).length;//decimalPlaces(numeral(formatted)._value);
                            textfield.setDecimalPrecision(decimal);
                            textfield.setDecimalToDisplay(decimalToDisplay);
                            textfield.setValue(formatted);
                            textfield.setRawValue(formatted);  
                        }
                    }
                }
            });
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
            if(decimal === null)
                decimal = 6;
            var formatted = numeral(val).format('0,0.[' + format + ']');
            var decimalToDisplay = (((numeral(formatted)._value).toString()).split('.')[1] || []).length; //decimalPlaces(numeral(formatted)._value);
            txtQuantity.setDecimalPrecision(decimal);
            txtQuantity.setDecimalToDisplay(decimalToDisplay);
            txtQuantity.setValue(formatted);
            txtQuantity.setRawValue(formatted);

            var grid = panel.column.container.component.grid;
            grid.selection.set(panel.valueField, records[0].get('intUnitMeasureId'));
            grid.selection.set(panel.displayField, records[0].get('strUnitMeasure'));
        }
    },

    constructor: function(config) {
        this.callParent([config]);
    },

    getValue : function(){
        var vm = this.viewModel;
        return vm.get('quantity');
    },

    setValue : function(value){
        var grid = this.column.container.component.grid;
        var selection = grid.selection;
        var val = { quantity: value, unitMeasureId: selection.get(this.valueField) };
        var qty = null;
        var uomId = null;
        var panel = this.items.items[0];
        var cbo = panel.items.items[1];
        var txt = panel.items.items[0];

        if(val) {
            if(val.quantity) {
                qty = val.quantity;
                this.viewModel.set('quantity', qty);
            }

            if(val.unitMeasureId) {
                uomId = val.unitMeasureId;
                this.viewModel.set('unitMeasureId', uomId);
            }


            var store = Ext.create('Inventory.store.BufferedUnitMeasure', { pageSize: 50 });
            cbo.bindStore(store);
            store.load({
                callback: function(records, op, success) {
                    if(success) {
                        var m = _.map(records, function(a) { return a.data; });
                        var filtered = _.filter(m, function(a) { return a.intUnitMeasureId === grid.selection.get('intUnitMeasureId'); });

                        cbo.setValue(grid.selection.get('intUnitMeasureId'));
                        cbo.setRawValue(grid.selection.get('strUnitMeasure'));

                        if(filtered && filtered.length > 0)
                            decimal = filtered[0].intDecimalPlaces;
                        
                        var format = "";
                        for (var i = 0; i < decimal; i++)
                            format += "0";
                        if(decimal === 0) {
                            txt.setDecimalPrecision(0);
                            txt.setDecimalToDisplay(0);
                            var f = numeral(qty).format('0,0');
                            txt.setValue(numeral(qty)._value);
                            txt.setRawValue(f);
                        } else {
                            var formatted = numeral(qty).format('0,0.[' + format + ']');
                            var decimalToDisplay = (((numeral(formatted)._value).toString()).split('.')[1] || []).length;
                            txt.setDecimalPrecision(decimal);
                            txt.setDecimalToDisplay(decimalToDisplay);
                            txt.setValue(numeral(qty)._value);
                            txt.setRawValue(formatted);
                        }
                    }
                }
            });
        }
    }
});