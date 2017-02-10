Ext.define('Inventory.ux.GridUnitMeasureColumn', {
    extend: 'Ext.grid.column.Column',
    alias: 'widget.unitmeasurecolumn',

    getDecimals: function(me, record, decimalField) {
        var decimal = 6;
        if(record && record.get(decimalField))
            decimal = record.get(decimalField);

        if(me.onGetDecimalPlaces) {
            var custom = me.onGetDecimalPlaces(record);
            decimal = custom ? custom : decimal;
        }
        record.intDecimalPlacesInternal = decimal;
        return decimal;
    },

    renderer: function(value, cell, record) {
        var me = cell.column;
        var qtyField = me.dataIndex;      
        
        var uomField = me.displayField ? me.displayField : 'strUnitMeasure';

        var qty = 0.000000;
        var uom = "";
                
        if(record.get(qtyField))
            qty = record.get(qtyField);
        if(record.get(uomField))
            uom = record.get(uomField);

        var decimalField = me.decimalPrecisionField ? me.decimalPrecisionField : 'intDecimalPlaces';
        var decimal = me.getDecimals(me, record, decimalField);

        var o = me.getPrecisionNumberObject(qty, decimal);
        var strQty = "";
        if(o)
            strQty = o.formatted;

        return strQty + ' <i>' + uom + '</i>';
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
    }
});