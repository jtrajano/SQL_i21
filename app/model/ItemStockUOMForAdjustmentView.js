Ext.define('Inventory.model.ItemStockUOMForAdjustmentView', {
    extend: 'Ext.data.Model',

    requires: [
        'Ext.data.Field'
    ],

    //idProperty: 'intItemStockUOMId',
    idProperty: null,

    fields: [
        { name: 'intItemStockUOMId', type: 'int' },
        { name: 'intItemId', type: 'int' },
        { name: 'strItemNo', type: 'string' },
        { name: 'strItemDescription', type: 'string' },
        { name: 'intLocationId', type: 'int', allowNull: true },
        { name: 'intItemLocationId', type: 'int', allowNull: true },
        { name: 'strLocationName', type: 'string' },
        { name: 'intItemUOMId', type: 'int', allowNull: true },
        { name: 'strUnitMeasure', type: 'string' },
        { name: 'strUnitType', type: 'string' },
        { name: 'intSubLocationId', type: 'int', allowNull: true },
        { name: 'strSubLocationName', type: 'string' },
        { name: 'intStorageLocationId', type: 'int', allowNull: true },
        { name: 'strStorageLocationName', type: 'string' },
        { name: 'dblOnHand', type: 'float' },
        { name: 'dblOnOrder', type: 'float' },
        { name: 'dblUnitQty', type: 'float' },
        { name: 'ysnStockUnit', type: 'boolean' }
    ]
});