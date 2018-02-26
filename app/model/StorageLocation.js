/**
 * Created by LZabala on 11/19/2014.
 */
Ext.define('Inventory.model.StorageLocation', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.StorageLocationCategory',
        'Inventory.model.StorageLocationMeasurement',
        'Inventory.model.StorageLocationSku',
        'Inventory.model.StorageLocationContainer',
        'Ext.data.Field'
    ],

    idProperty: 'intStorageLocationId',

    fields: [
        { name: 'intStorageLocationId', type: 'int'},
        { name: 'strName', type: 'string', auditKey: true},
        { name: 'strDescription', type: 'string'},
        { name: 'intStorageUnitTypeId', type: 'int', allowNull: true },
        { name: 'intLocationId', type: 'int', allowNull: true },
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
        { name: 'intSequence', type: 'int', allowNull: true },
        { name: 'ysnActive', type: 'boolean'},
        { name: 'intRelativeX', type: 'int', allowNull: true },
        { name: 'intRelativeY', type: 'int', allowNull: true },
        { name: 'intRelativeZ', type: 'int', allowNull: true },
        { name: 'intCommodityId', type: 'int', allowNull: true },
        { name: 'dblPackFactor', type: 'float'},
        { name: 'dblEffectiveDepth', type: 'float'},
        { name: 'dblUnitPerFoot', type: 'float'},
        { name: 'dblResidualUnit', type: 'float'},
        { name: 'strStorageUnitType', type: 'string'},
        { name: 'strLocation', type: 'string'},
        { name: 'strSubLocation', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strName'},
        {type: 'presence', field: 'strStorageUnitType'},
        {type: 'presence', field: 'strLocation'},
        {type: 'presence', field: 'strSubLocation'}
    ]
});