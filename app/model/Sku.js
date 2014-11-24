/**
 * Created by LZabala on 11/24/2014.
 */
Ext.define('Inventory.model.Sku', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intSKUId',

    fields: [
        { name: 'intSKUId', type: 'int'},
        { name: 'intExternalSystemId', type: 'int', allowNull: true },
        { name: 'strSKU', type: 'string'},
        { name: 'intSKUStatusId', type: 'int', allowNull: true },
        { name: 'strLotCode', type: 'string'},
        { name: 'strSerialNo', type: 'string'},
        { name: 'dblQuantity', type: 'float'},
        { name: 'dtmReceiveDate', type: 'date', allowNull: true , dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'dtmProductionDate', type: 'date', allowNull: true , dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'intItemId', type: 'int', allowNull: true },
        { name: 'intContainerId', type: 'int', allowNull: true },
        { name: 'intOwnerId', type: 'int', allowNull: true },
        { name: 'strLastUpdateBy', type: 'string'},
        { name: 'dtmLastUpdateOn', type: 'date', allowNull: true , dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'intLotId', type: 'int', allowNull: true },
        { name: 'intUnitMeasureId', type: 'int', allowNull: true },
        { name: 'intReasonId', type: 'int', allowNull: true },
        { name: 'strComment', type: 'string'},
        { name: 'intParentSKUId', type: 'int', allowNull: true },
        { name: 'dblWeightPerUnit', type: 'float'},
        { name: 'intWeightPerUnitMeasureId', type: 'int', allowNull: true },
        { name: 'intUnitPerLayer', type: 'int'},
        { name: 'intLayerPerPallet', type: 'int'},
        { name: 'ysnSanitized', type: 'boolean'},
        { name: 'strBatch', type: 'string'},
        { name: 'intSort', type: 'int'}
    ],

    validators: [
        {type: 'presence', field: 'strSKU'}
    ]
});