/**
 * Created by LZabala on 12/16/2014.
 */
Ext.define('Inventory.model.QAProperty', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intQAPropertyId',

    fields: [
        { name: 'intQAPropertyId', type: 'int'},
        { name: 'strPropertyName', type: 'string'},
        { name: 'strDescription', type: 'string'},
        { name: 'strAnalysisType', type: 'string'},
        { name: 'strDataType', type: 'string'},
        { name: 'strListName', type: 'string'},
        { name: 'intDecimalPlaces', type: 'int'},
        { name: 'strMandatory', type: 'string'},
        { name: 'ysnActive', type: 'boolean'},
    ],

    validators: [
        {type: 'presence', field: 'strPropertyName'}
    ]
});