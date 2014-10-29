/**
 * Created by LZabala on 10/29/2014.
 */
Ext.define('Inventory.model.ManufacturingCell', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.ManufacturingCellPackType',
        'Ext.data.Field'
    ],

    idProperty: 'intManufacturingCellId',

    fields: [
        { name: 'intManufacturingCellId', type: 'int'},
        { name: 'strCellName', type: 'string'},
        { name: 'strDescription', type: 'string'},
        { name: 'intLocationId', type: 'int', allowNull: true },
        { name: 'strStatus', type: 'string'},
        { name: 'dblStdCapacity', type: 'float'},
        { name: 'intStdUnitMeasureId', type: 'int', allowNull: true },
        { name: 'intStdCapacityRateId', type: 'int', allowNull: true },
        { name: 'dblStdLineEfficiency', type: 'float'},
        { name: 'ysnIncludeSchedule', type: 'boolean'}
    ],

    validators: [
        {type: 'presence', field: 'strCellName'}
    ]
});