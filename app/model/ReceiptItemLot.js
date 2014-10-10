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
        { name: 'intInventoryReceiptItemId', type: 'int'},
        { name: 'strParentLotId', type: 'string'},
        { name: 'strLotId', type: 'string'},
        { name: 'strContainerNo', type: 'string'},
        { name: 'dblQuantity', type: 'float'},
        { name: 'intUnits', type: 'int'},
        { name: 'intUnitUOMId', type: 'int'},
        { name: 'intUnitPallet', type: 'int'},
        { name: 'dblGrossWeight', type: 'float'},
        { name: 'dblTareWeight', type: 'float'},
        { name: 'intWeightUOMId', type: 'int'},
        { name: 'dblStatedGrossPerUnit', type: 'float'},
        { name: 'dblStatedTarePerUnit', type: 'float'},
        { name: 'intStorageBinId', type: 'int'},
        { name: 'intGarden', type: 'int'},
        { name: 'strGrade', type: 'string'},
        { name: 'intOriginId', type: 'int'},
        { name: 'intSeasonCropYear', type: 'int'},
        { name: 'strVendorLotId', type: 'string'},
        { name: 'dtmManufacturedDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'strRemarks', type: 'string'},
        { name: 'intSort', type: 'int'},
    ]
});