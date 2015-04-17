/**
 * Created by LZabala on 4/16/2015.
 */
Ext.define('Inventory.model.TransferDetail', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryTransferDetailId',

    fields: [
        { name: 'intInventoryTransferDetailId', type: 'int' },
        { name: 'intInventoryTransferId', type: 'int',
            reference: {
                type: 'Inventory.model.Transfer',
                inverse: {
                    role: 'tblICInventoryTransferDetails',
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
        { name: 'intLotId', type: 'int', allowNull: true },
        { name: 'intFromSubLocationId', type: 'int', allowNull: true },
        { name: 'intToSubLocationId', type: 'int', allowNull: true },
        { name: 'intFromStorageLocationId', type: 'int', allowNull: true },
        { name: 'intToStorageLocationId', type: 'int', allowNull: true },
        { name: 'dblQuantity', type: 'float' },
        { name: 'intItemUOMId', type: 'int', allowNull: true },
        { name: 'intItemWeightUOMId', type: 'int', allowNull: true },
        { name: 'dblGrossWeight', type: 'float' },
        { name: 'dblTareWeight', type: 'float' },
        { name: 'dblNetWeight', type: 'float' },
        { name: 'intNewLotId', type: 'int', allowNull: true },
        { name: 'strNewLotId', type: 'string' },
        { name: 'dblCost', type: 'float' },
        { name: 'intCreditAccountId', type: 'int', allowNull: true },
        { name: 'intDebitAccountId', type: 'int', allowNull: true },
        { name: 'intTaxCodeId', type: 'int', allowNull: true },
        { name: 'dblFreightRate', type: 'float' },
        { name: 'dblFreightAmount', type: 'float' },
        { name: 'intSort', type: 'int', allowNull: true },

        { name: 'strItemNo', type: 'string' },
        { name: 'strUnitMeasure', type: 'string' }
    ],

    validators: [
        { type: 'presence', field: 'strItemNo' },
        { type: 'presence', field: 'dblQuantity' },
        { type: 'presence', field: 'strUnitMeasure' }
    ]
});