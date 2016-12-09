Ext.define('Inventory.model.ItemStockUOMViewTotals', {
    extend: 'Ext.data.Model',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemStockUOMId',

    fields: [
        { name: 'intItemStockUOMId', type: 'int' },
        { name: 'intItemId', type: 'int' },
        { name: 'intItemLocationId', type: 'int', allowNull: true },
        { name: 'intItemUOMId', type: 'int', allowNull: true },
        { name: 'strUnitMeasure', type: 'string' },
        { name: 'intSubLocationId', type: 'int', allowNull: true },
        { name: 'strSubLocationName', type: 'string' },
        { name: 'strStorageLocationName', type: 'string' },
        { name: 'dblAvailableQty', type: 'float', allowNull: true },
        { name: 'dblStorageQty', type: 'float', allowNull: true }
    ]
});