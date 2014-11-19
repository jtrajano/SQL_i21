/**
 * Created by LZabala on 11/19/2014.
 */
Ext.define('Inventory.model.StorageLocation', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.StorageLocationCategory',
        'Inventory.model.StorageLocationMeasurement',
        'Ext.data.Field'
    ],

    idProperty: 'intStorageLocationId',

    fields: [
        { name: 'intStorageLocationId', type: 'int'},
        { name: 'strName', type: 'string'},
        { name: 'strDescription', type: 'string'},
        { name: 'intStorageUnitTypeId', type: 'int', allowNull: true },
        { name: 'intSubLocationId', type: 'int', allowNull: true },
        { name: 'intParentStorageLocationId', type: 'int', allowNull: true },
        { name: 'ysnAllowConsume', type: 'boolean'},
        { name: 'ysnAllowMultipleItem', type: 'boolean'},
        { name: 'ysnAllowMultipleLot', type: 'boolean'},
        { name: 'ysnMergeOnMove', type: 'boolean'},
        { name: 'ysnCycleCounted', type: 'boolean'},
        { name: 'ysnDefaultWHStagingUnit', type: 'boolean'},
        { name: 'intRestrictionId', type: 'int', allowNull: true },
        { name: 'strUnitGroup', type: 'string'},
        { name: 'dblMinBatchSize', type: 'float'},
        { name: 'dblBatchSize', type: 'float'},
        { name: 'intBatchSizeUOMId', type: 'int', allowNull: true },
        { name: 'intSequence', type: 'int'},
        { name: 'ysnActive', type: 'boolean'},
        { name: 'intRelativeX', type: 'int'},
        { name: 'intRelativeY', type: 'int'},
        { name: 'intRelativeZ', type: 'int'},
        { name: 'intCommodityId', type: 'int', allowNull: true },
        { name: 'dblPackFactor', type: 'float'},
        { name: 'dblUnitPerFoot', type: 'float'},
        { name: 'dblResidualUnit', type: 'float'}
    ],

    validators: [
        {type: 'presence', field: 'strName'}
    ]
});