/**
 * Created by rnkumashi on 22-09-2014.
 */

Ext.define('Inventory.model.UnitMeasure', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.UnitMeasureConversion',
        'Ext.data.Field'
    ],

    idProperty: 'intUnitMeasureId',

    fields: [
        { name: 'intUnitMeasureId', type: 'int'},
        { name: 'strUnitMeasure', type: 'string'},
        { name: 'strSymbol', type: 'string'},
        { name: 'strUnitType', type: 'string'},
        { name: 'intDecimalPlaces', type: 'int', allowNull: true, defaultValue: 2 }
    ],

    validators: [
        {type: 'presence', field: 'strUnitMeasure'},
        {type: 'presence', field: 'strUnitType'}
    ]
});