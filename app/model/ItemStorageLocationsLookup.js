Ext.define('Inventory.model.ItemStorageLocationsLookup', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intStorageLocationId',

    fields: [
        { name: 'intItemId', type: 'int' },
        { name: 'strItemNo', type: 'string' },
        { name: 'intLocationId', type: 'int' },
        { name: 'intSubLocationId', type: 'int' },
        { name: 'strSubLocationName', type: 'string' },
        { name: 'intStorageLocationId', type: 'int' },
        { name: 'strStorageLocationName', type: 'string' },
        { name: 'strStorageLocationDescription', type: 'string' }
    ]
});