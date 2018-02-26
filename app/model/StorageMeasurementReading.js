/**
 * Created by LZabala on 10/1/2015.
 */
Ext.define('Inventory.model.StorageMeasurementReading', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.StorageMeasurementReadingConversion',
        'Ext.data.Field'
    ],

    idProperty: 'intStorageMeasurementReadingId',

    fields: [
        { name: 'intStorageMeasurementReadingId', type: 'int' },
        { name: 'intLocationId', type: 'int', allowNull: true },
        { name: 'dtmDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'strReadingNo', type: 'string', auditKey: true },
        { name: 'intSort', type: 'int', allowNull: true }
    ],

    validators: [
        {type: 'presence', field: 'intLocationId'}
    ]
});