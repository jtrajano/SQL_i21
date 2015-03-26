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
                    role: 'tblICInventoryAdjustmentNotes',
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
        { name: 'intItemId', type: 'int', allowNull: true },
        { name: 'intSubLocationId', type: 'int', allowNull: true },
        { name: 'intStorageLocationId', type: 'int', allowNull: true },
        { name: 'intLotId', type: 'int', allowNull: true },
        { name: 'intNewLotId', type: 'int', allowNull: true },
        { name: 'dblNewQuantity', type: 'float' },
        { name: 'intNewItemUOMId', type: 'int', allowNull: true },
        { name: 'intNewItemId', type: 'int', allowNull: true },
        { name: 'dblNewPhysicalCount', type: 'float' },
        { name: 'dtmNewExpiryDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'intNewLotStatusId', type: 'int', allowNull: true },
        { name: 'intAccountCategoryId', type: 'int', allowNull: true },
        { name: 'intCreditAccountId', type: 'int', allowNull: true },
        { name: 'intDebitAccountId', type: 'int', allowNull: true },
        { name: 'intSort', type: 'int', allowNull: true },

        { name: 'strItemNo', type: 'string'}
    ],

    validators: [
        { type: 'presence', field: 'strItemNo' }
    ]
});