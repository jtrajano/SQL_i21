/**
 * Created by LZabala on 10/10/2014.
 */
Ext.define('Inventory.model.ReceiptItemLot', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryReceiptItemLotId',

    fields: [
        { name: 'intInventoryReceiptItemLotId', type: 'int'},
        { name: 'intInventoryReceiptItemId', type: 'int',
            reference: {
                type: 'Inventory.model.ReceiptItem',
                inverse: {
                    role: 'tblICInventoryReceiptItemLots',
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
        { name: 'intParentLotId', type: 'int', allowNull: true },
        { name: 'intLotId', type: 'int', allowNull: true },
        { name: 'strParentLotId', type: 'string' },
        { name: 'strLotId', type: 'string' },
        { name: 'dblQuantity', type: 'float' },
        { name: 'intWeightUOMId', type: 'int', allowNull: true },
        { name: 'dblGrossWeight', type: 'float' },
        { name: 'dblTareWeight', type: 'float' },
        { name: 'dblCost', type: 'float' },
        { name: 'intStorageLocationId', type: 'int', allowNull: true },
        { name: 'intUnitUOMId', type: 'int', allowNull: true },
        { name: 'intUnits', type: 'int', allowNull: true },
        { name: 'intUnitPallet', type: 'int', allowNull: true },
        { name: 'dblStatedGrossPerUnit', type: 'float' },
        { name: 'dblStatedTarePerUnit', type: 'float' },
        { name: 'strContainerNo', type: 'string' },
        { name: 'intGarden', type: 'int', allowNull: true },
        { name: 'strGrade', type: 'string' },
        { name: 'intOriginId', type: 'int', allowNull: true },
        { name: 'intSeasonCropYear', type: 'int', allowNull: true },
        { name: 'strVendorLotId', type: 'string' },
        { name: 'dtmManufacturedDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'strRemarks', type: 'string' },
        { name: 'strCondition', type: 'string' },
        { name: 'dtmCertified', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'intSort', type: 'int', allowNull: true }
    ]
});