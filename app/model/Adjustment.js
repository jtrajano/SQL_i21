/**
 * Created by LZabala on 3/27/2015.
 */
Ext.define('Inventory.model.Adjustment', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.AdjustmentDetail',
        'Inventory.model.AdjustmentNote',
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryAdjustmentId',

    fields: [
        { name: 'intInventoryAdjustmentId', type: 'int' },
        { name: 'intLocationId', type: 'int', allowNull: true },
        { name: 'dtmAdjustmentDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d', defaultValue: new Date() },
        { name: 'intAdjustmentType', type: 'int', allowNull: true },
        { name: 'strAdjustmentNo', type: 'string', auditKey: true },
        { name: 'strDescription', type: 'string' },
        { name: 'ysnPosted', type: 'boolean', defaultValue: false },
        { name: 'intSort', type: 'int', allowNull: true }
    ],

    validators: [
        { type: 'presence', field: 'intLocationId' },
        { type: 'presence', field: 'dtmAdjustmentDate' },
        { type: 'presence', field: 'intAdjustmentType' }
    ]
});