Ext.define('Inventory.ux.GridUnitMeasureColumn', {
    extend: 'Ext.grid.column.Column',
    alias: 'widget.unitmeasurecolumn',

    requires: ['Inventory.ux.GridUnitMeasureField'],

    renderer: function(e, column, record) {
        return record.get('dblUnitQty').toString() + ' ' + record.get('strUnitMeasure');
    },

    getEditor: function() {
        return Ext.create('Inventory.ux.GridUnitMeasureField', {
            data: arguments[0]
        });
    }
});