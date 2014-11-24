/**
 * Created by LZabala on 11/24/2014.
 */
Ext.define('Inventory.model.ContainerType', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intContainerTypeId',

    fields: [
        { name: 'intContainerTypeId', type: 'int'},
        { name: 'intExternalSystemId', type: 'int'},
        { name: 'strInternalCode', type: 'string'},
        { name: 'strDisplayMember', type: 'string'},
        { name: 'intDimensionUnitMeasureId', type: 'int', allowNull: true},
        { name: 'dblHeight', type: 'float'},
        { name: 'dblWidth', type: 'float'},
        { name: 'dblDepth', type: 'float'},
        { name: 'intWeightUnitMeasureId', type: 'int', allowNull: true},
        { name: 'dblMaxWeight', type: 'float'},
        { name: 'ysnLocked', type: 'boolean'},
        { name: 'ysnDefault', type: 'boolean'},
        { name: 'dblPalletWeight', type: 'float'},
        { name: 'strLastUpdateBy', type: 'string'},
        { name: 'dtmLastUpdateOn', type: 'date', allowNull: true, dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'strContainerDescription', type: 'string'},
        { name: 'ysnReusable', type: 'boolean'},
        { name: 'ysnAllowMultipleItems', type: 'boolean'},
        { name: 'ysnAllowMultipleLots', type: 'boolean'},
        { name: 'ysnMergeOnMove', type: 'boolean'},
        { name: 'intTareUnitMeasureId', type: 'int', allowNull: true},
        { name: 'intSort', type: 'int'}
    ],

    validators: [
        {type: 'presence', field: 'strInternalCode'}
    ]
});