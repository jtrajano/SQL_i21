/**
 * Created by LZabala on 10/9/2014.
 */
Ext.define('Inventory.model.EquipmentLength', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intEquipmentLengthId',

    fields: [
        { name: 'intEquipmentLengthId', type: 'int'},
        { name: 'strEquipmentLength', type: 'string'},
        { name: 'strDescription', type: 'string'},
        { name: 'intSort', type: 'int'}
    ],

    validators: [
        {type: 'presence', field: 'intEquipmentLengthId'}
    ]
});