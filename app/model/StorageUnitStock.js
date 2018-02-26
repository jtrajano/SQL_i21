Ext.define('Inventory.model.StorageUnitStock', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemStockUOMId',

    fields: [
        { name: 'intItemStockUOMId', type: 'int' },
        { name: 'strItemNo', type: 'string', auditKey: true },
        { name: 'intItemId', type: 'int', allowNull: true },			
        { name: 'intCommodityId', type: 'string', allowNull: true },	
        { name: 'strCommodityCode', type: 'string' },	
        { name: 'intLocationId', type: 'string', allowNull: true },		
        { name: 'strLocation', type: 'string' },		
        { name: 'intStorageLocationId', type: 'string', allowNull: true },
        { name: 'strStorageLocation', type: 'string' },
        { name: 'intStorageUnitId', type: 'string', allowNull: true },	
        { name: 'strStorageUnit', type: 'string' },	
        { name: 'dblOnHand', type: 'string' },			
        { name: 'strUnitMeasure', type: 'string' },	
        { name: 'dblEffectiveDepth', type: 'string' },	
        { name: 'dblResidualUnit', type: 'string' },	
        { name: 'dblUnitPerFoot', type: 'string' },	
        { name: 'dblPackFactor', type: 'string' }		

    ]
});