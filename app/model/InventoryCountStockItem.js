Ext.define('Inventory.model.InventoryCountStockItem', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intKey',

    fields: [
        { name: 'intKey', type: 'int' },
        { name: 'intItemId', type: 'int', allowNull: true },   
        { name: 'strItemNo', type: 'string', auditKey: true },             
        { name: 'dblOnHand', type: 'float' },
        { name: 'intItemStockUOMId', type: 'int', allowNull: true },
        { name: 'intSubLocationId', type: 'int', allowNull: true },
        { name: 'intStorageLocationId', type: 'int', allowNull: true },
        { name: 'intLocationId', type: 'int', allowNull: true },
        { name: 'strSubLocationName', type: 'string' },    
        { name: 'strStorageLocationName', type: 'string' },
        { name: 'intUnitMeasureId', type: 'int', allowNull: true },
        { name: 'strUnitMeasure', type: 'string' },        
        { name: 'intItemUOMId', type: 'int', allowNull: true }
    ]
});