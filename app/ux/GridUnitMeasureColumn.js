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

Ext.define('Inventory.ux.GridUnitMeasureColumn', {
    extend: 'Ext.grid.column.Column',
    alias: 'widget.unitmeasurecolumn',

    requires: ['Inventory.ux.GridUnitMeasureField'],

    renderer: function(e, column, record) {
        var qty = record.get(column.column.dataIndex);
        if(!qty)
            qty = 0.00;
        var decimal = 2;
        if(record.get('intItemUOMDecimalPlaces'))
            decimal = record.get('intItemUOMDecimalPlaces');
        decimal = 6;
        var format = "";
        for (var i = 0; i < decimal; i++)
            format += "0";

        var result = qty.toString();

        if(decimal === 0) {
            result = numeral(qty).format('0,0');
        } else {
            var formatted = numeral(qty).format('0,0.[' + format + ']');
            //decimalPlaces(numeral(formatted)._value);
            result = formatted;
        }
        
        return result + ' ' + record.get('strUnitMeasure');
    }
});