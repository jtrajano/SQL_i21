Ext.define('Inventory.model.ItemSubLocationsLookup', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intSubLocationId',

    fields: [
        { name: 'intItemId', type: 'int' },
        { name: 'strItemNo', type: 'string' },
        { name: 'intLocationId', type: 'int' },
        { name: 'intItemLocationId', type: 'int' },
        { name: 'intSubLocationId', type: 'int' },
        { name: 'strSubLocationName', type: 'string' },
        { name: 'strClassification', type: 'string' }
    ]
});