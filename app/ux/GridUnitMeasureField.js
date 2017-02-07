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
        this.setValue(val);
        cbo.setValue(val.unitMeasureId);
        var uom = cbo.findRecordByValue(val.unitMeasureId);
        if(uom && uom.get('strUnitMeasure'))
            cbo.setRawValue(uom.get('strUnitMeasure'));
        else
            cbo.setRawValue(selection.get(this.displayField));
        
        cbo.on('select', this.onUnitMeasurementChange);
        //txt.on('change', this.onQuantityChange);
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
            var decimalToDisplay = decimalPlaces(numeral(formatted)._value);
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
            var decimalToDisplay = decimalPlaces(numeral(formatted)._value);
            txtQuantity.setDecimalPrecision(decimal);
            txtQuantity.setDecimalToDisplay(decimalToDisplay);
            txtQuantity.setValue(formatted);
            txtQuantity.setRawValue(formatted);

            var grid = this.column.container.component.grid;
            grid.selection.set(this.valueField, records[0].get('intUnitMeasureId'));
            grid.selection.set(this.displayField, records[0].get('strUnitMeasure'));
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
        if(val) {
            if(val.quantity) {
                qty = val.quantity;
                this.viewModel.set('quantity', qty);
            }

            if(val.unitMeasureId) {
                uomId = val.unitMeasureId;
                this.viewModel.set('unitMeasureId', uomId);
            }
        }
    }
});