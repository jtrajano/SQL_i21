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
                role: 'tblICInventoryReceiptItem',
                inverse: {
                    role: 'tblICInventoryReceiptItemLots',
                    storeConfig: {
                        complete: true,
                        sortOnLoad: true,
                        sorters: {
                            direction: 'DESC',
                            property: 'intSort'
                        },
                        autoLoad: false,
                        pruneModifiedRecords: false,
                        proxy: {
                            api: {
                                create: '../Inventory/api/InventoryReceiptItemLot/Post',
                                read: '../Inventory/api/InventoryReceiptItemLot/SearchLots',
                                update: '../Inventory/api/InventoryReceiptItemLot/Put',
                                destroy: '../Inventory/api/InventoryReceiptItemLot/Delete'
                            },
                            type: 'rest',
                            reader: {
                                type: 'json',
                                rootProperty: 'data',
                                messageProperty: 'message'
                            },
                            writer: {
                                type: 'json',
                                allowSingle: false
                            },
                            sortOnLoad: true,
                            sorters: {
                                direction: 'DESC',
                                property: 'intSort'
                            }
                        }
                    }
                }
            }
        },
        { name: 'intLotId', type: 'int', allowNull: true },
        { name: 'strLotNumber', type: 'string' },
        { name: 'strLotAlias', type: 'string' },
        { name: 'intSubLocationId', type: 'int', allowNull: true },
        { name: 'intStorageLocationId', type: 'int', allowNull: true },
        { name: 'dblQuantity', type: 'float' },
        { name: 'dblGrossWeight', type: 'float' },
        { name: 'dblTareWeight', type: 'float' },
        { name: 'dblCost', type: 'float' },
        { name: 'intUnitPallet', type: 'int', allowNull: true },
        { name: 'dblStatedGrossPerUnit', type: 'float' },
        { name: 'dblStatedTarePerUnit', type: 'float' },
        { name: 'strContainerNo', type: 'string' },
        { name: 'intEntityVendorId', type: 'int', allowNull: true },
        { name: 'intItemUnitMeasureId', type: 'int', allowNull: false },
        { name: 'strGarden', type: 'string' },
        { name: 'strMarkings', type: 'string' },
        { name: 'strGrade', type: 'string' },
        { name: 'intOriginId', type: 'int', allowNull: true },
        { name: 'intSeasonCropYear', type: 'int', allowNull: true },
        { name: 'strVendorLotId', type: 'string' },
        { name: 'dtmManufacturedDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'strRemarks', type: 'string' },
        { name: 'strCondition', type: 'string' },
        { name: 'dtmCertified', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'dtmExpiryDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'intSort', type: 'int', allowNull: true },
        { name: 'dblNetWeight', type: 'float' },
        { name: 'strWeightUOM', type: 'string' },
        { name: 'intParentLotId', type: 'int', allowNull: true },
        { name: 'strParentLotNumber', type: 'string' },
        { name: 'strParentLotAlias', type: 'string' },
        { name: 'strStorageLocation', type: 'string' },
        { name: 'strSubLocationName', type: 'string' },
        { name: 'dblStatedNetPerUnit', type: 'float' },
        { name: 'dblStatedTotalNet', type: 'float' },
        { name: 'dblPhysicalVsStated', type: 'float' },
        { name: 'strUnitMeasure', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strStorageLocation'}
    ],

    validate: function(options){
        var errors = this.callParent(arguments);
        if (this.get('intWeightUOMId')) {
            var netWeight = this.get('dblGrossWeight') - this.get('dblTareWeight');
            if (netWeight <= 0) {
                errors.add({
                    field: 'dblGrossWeight',
                    message: 'Gross is used to calculate Net Weight. Net Weight could not be zero or lower.'
                })
            }
        }
        
       if (this.get('strWeightUOM') === '' && this.get('dblNetWeight') !== 0) {
                errors.add({
                    field: 'strWeightUOM',
                    message: 'Lot Weight UOM must be present. Please add value in Gross/Net UOM.'
                });
        }
        return errors;
    }
});