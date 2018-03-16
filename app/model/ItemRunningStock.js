Ext.define('Inventory.model.ItemRunningStock', {
    extend: 'Ext.data.Model',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemId',

    fields: [
        { name: 'intItemId', type: 'int' },
        { name: 'strItemNo', type: 'string' },
        { name: 'intItemUOM', type: 'int', allowNull: true },
        { name: 'strItemUOM', type: 'string' },
        { name: 'intLocationId', type: 'int', allowNull: true },
        { name: 'strLocationName', type: 'string' },
        { name: 'intSubLocationId', type: 'int', allowNull: true },
        { name: 'strSubLocationName', type: 'string' },
        { name: 'intStorageLocationId', type: 'int', allowNull: true },
        { name: 'strStorageLocationName', type: 'string' },
        { name: 'intLotId', type: 'int', allowNull: true },
        { name: 'strLotNumber', type: 'string' },
        { name: 'intOwnershipType', type: 'int', allowNull: true },
        { name: 'intItemOwnerId', type: 'int', allowNull: true },
        { name: 'dtmExpiryDate', type: 'date', dateFormat: 'c' },
        { name: 'intWeightUOMId', type: 'int', allowNull: true },
        { name: 'strWeightUOM', type: 'string' },
        { name: 'dblWeight', type: 'float' },
        { name: 'dblWeightPerQty', type: 'float' },
        { name: 'intLotStatusId', type: 'int', allowNull: true },
        { name: 'strLotStatus', type: 'string' },
        { name: 'strLotPrimaryStatus', type: 'string' },
        { name: 'intOwnerId', type: 'int', allowNull: true },
        { name: 'strOwner', type: 'string' },
        { name: 'dtmAsOfDate' , type: 'date', dateFormat: 'c' },
        { name: 'dblRunningAvailableQty', type: 'float' },
        { name: 'dblStorageAvailableQty', type: 'float' },
        { name: 'dblCost', type: 'float' }
    ]
});