/**
 * Created by LZabala on 11/24/2014.
 */
Ext.define('Inventory.model.Measurement', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intMeasurementId',

    fields: [
        { name: 'intMeasurementId', type: 'int'},
        { name: 'strMeasurementName', type: 'string'},
        { name: 'strDescription', type: 'string'},
        { name: 'strMeasurementType', type: 'string'},
        { name: 'intSort', type: 'int'}
    ],

    validators: [
        {type: 'presence', field: 'strMeasurementName'},
        {type: 'presence', field: 'strMeasurementType'}

    ]
});