Ext.define('Inventory.model.LotDetailHistory', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intLotId',

    fields: [
        { name: 'intLotId', type: 'int'},
        { name: 'strLotNumber', type: 'string' },
        { name: 'strParentLotNumber', type: 'string' },
        { name: 'strLotUOM', type: 'string' },
        { name: 'dtmExpiryDate', type: 'date', allowNull: true, dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'strEntityName', type: 'string' },
        { name: 'intEntityId', type: 'int', allowNull: true },
        { name: 'strTransactionType', type: 'string' },
        { name: 'intTransactionId', type: 'int', allowNull: true },
        { name: 'strTransactionId', type: 'string' },
        { name: 'dtmDate', type: 'date', allowNull: true, dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'dblWeightPerQty', type: 'float', allowNull: true },
        { name: 'dblQty', type: 'float', allowNull: true },
        { name: 'dblCost', type: 'float', allowNull: true },
        { name: 'dblAmount', type: 'float', allowNull: true },
        { name: 'dblWeight', type: 'float', allowNull: true },
        { name: 'strLocationName', type: 'string' },
        { name: 'intLocationId', type: 'int', allowNull: true },
        { name: 'strStorageLocationName', type: 'string' },
        { name: 'intStorageLocationId', type: 'int', allowNull: true }
    ]
});