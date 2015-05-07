/**
 * Created by LZabala on 3/27/2015.
 */
Ext.define('Inventory.model.AdjustmentDetail', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryAdjustmentDetailId',

    fields: [
        { name: 'intInventoryAdjustmentDetailId', type: 'int' },
        { name: 'intInventoryAdjustmentId', type: 'int',
            reference: {
                type: 'Inventory.model.Adjustment',
                inverse: {
                    role: 'tblICInventoryAdjustmentDetails',
                    storeConfig: {
                        complete: true,
                        sortOnLoad: true,
                        sorters: {
                            direction: 'DESC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'intSubLocationId', type: 'int', allowNull: true },
        { name: 'intStorageLocationId', type: 'int', allowNull: true },
        { name: 'intItemId', type: 'int', allowNull: true },
        { name: 'intNewItemId', type: 'int', allowNull: true },
        { name: 'intLotId', type: 'int', allowNull: true },
        { name: 'intNewLotId', type: 'int', allowNull: true },
        { name: 'strNewLotNumber', type: 'string', allowNull: true },
        { name: 'dblQuantity', type: 'float', allowNull: true  },
        { name: 'dblAdjustByQuantity', type: 'float', allowNull: true  },
        { name: 'dblNewQuantity', type: 'float', allowNull: true },
        { name: 'dblNewSplitLotQuantity', type: 'float', allowNull: true },
        { name: 'dblNetWeight', type: 'float', allowNull: true  },
        { name: 'intItemUOMId', type: 'int', allowNull: true },
        { name: 'intNewItemUOMId', type: 'int', allowNull: true },
        { name: 'intWeightUOMId', type: 'int', allowNull: true },
        { name: 'intNewWeightUOMId', type: 'int', allowNull: true },
        { name: 'dblWeight', type: 'float', allowNull: true  },
        { name: 'dblNewWeight', type: 'float', allowNull: true  },
        { name: 'dblWeightPerQty', type: 'float', allowNull: true  },
        { name: 'dblNewWeightPerQty', type: 'float', allowNull: true  },
        { name: 'dtmExpiryDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d', allowNull: true  },
        { name: 'dtmNewExpiryDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d', allowNull: true  },
        { name: 'intLotStatusId', type: 'int', allowNull: true },
        { name: 'intNewLotStatusId', type: 'int', allowNull: true },
        { name: 'dblCost', type: 'float', allowNull: true  },
        { name: 'dblNewCost', type: 'float', allowNull: true  },
        { name: 'dblLineTotal', type: 'float', allowNull: true  },
        { name: 'intSort', type: 'int', allowNull: true },
        { name: 'strItemNo', type: 'string'},
        { name: 'intNewLocationId', type: 'int', allowNull: true },
        { name: 'intNewSubLocationId', type: 'int', allowNull: true },
        { name: 'intNewStorageLocationId', type: 'int', allowNull: true }
    ],

    validators: [
        { type: 'presence', field: 'strItemNo' }
    ]
});