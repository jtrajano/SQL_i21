Ext.define('Inventory.ux.GridUOMCellEditor', {
    extend: 'Ext.grid.CellEditor',
    alias: 'widget.griduomcelleditor',
    requires: ['Inventory.ux.GridUOMField', 'Ext.grid.CellEditor'],
    field: 'griduomfield'
});