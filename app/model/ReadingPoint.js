/**
 * Created by LZabala on 11/24/2014.
 */
Ext.define('Inventory.model.ReadingPoint', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intReadingPointId',

    fields: [
        { name: 'intReadingPointId', type: 'int'},
        { name: 'strReadingPoint', type: 'string'},
        { name: 'intSort', type: 'int'}
    ],

    validators: [
        {type: 'presence', field: 'strReadingPoint'}
    ]
});