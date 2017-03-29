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
        { name: 'intNewStorageLocationId', type: 'int', allowNull: true },
        { name: 'strLotTracking', type: 'string', allowNull: true },
        { name: 'dblItemUOMUnitQty', type: 'float', allowNull: true},
        { name: 'dblNewItemUOMUnitQty', type: 'float', allowNull: true},
        { name: 'intItemOwnerId', type: 'int', allowNull: true },
        { name: 'intNewItemOwnerId', type: 'int', allowNull: true },
        { name: 'strOwnerName', type: 'string', allowNull: true },
        { name: 'strNewOwnerName', type: 'string', allowNull: true }        
    ],

    validators: [
        { type: 'presence', field: 'strItemNo' }
    ],
     validate: function(options) {
         var errors = this.callParent(arguments);

        //  if(this.get('dblAdjustByQuantity') == null || this.get('dblAdjustByQuantity') == '' || this.get('dblAdjustByQuantity') == 0) {
        //      errors.add({
        //         field: 'dblAdjustByQuantity',
        //         message: 'Adjust By Quantity must have a value.'
        //     })
        //  }

         if (this.joined.length > 0) {
            var data = this.joined[0].associatedEntity;
            var AdjustmentType = null;
            if (data) {
                AdjustmentType = data.get('intAdjustmentType');

                if(iRely.Functions.isEmpty(this.get('dblAdjustByQuantity')) && (AdjustmentType == 1 || AdjustmentType == 3 || AdjustmentType == 5 || AdjustmentType == 7 || AdjustmentType == 8)) {
                    errors.add({
                        field: 'dblAdjustByQuantity',
                        message: 'Adjust By Quantity must have a value.'
                    })
                }

                if(iRely.Functions.isEmpty(this.get('dblNewQuantity')) && (AdjustmentType == 1 || AdjustmentType == 3 || AdjustmentType == 5 || AdjustmentType == 7 || AdjustmentType == 8)) {
                    errors.add({
                        field: 'dblNewQuantity',
                        message: 'New Quantity must have a value.'
                    })
                }

                if(iRely.Functions.isEmpty(this.get('strNewItemNo')) && (AdjustmentType == 3)) {
                    errors.add({
                        field: 'strNewItemNo',
                        message: 'New Item Number must have a value.'
                    })
                }

                if(iRely.Functions.isEmpty(this.get('strSubLocation')) && (AdjustmentType == 4 || AdjustmentType == 9)) {
                    errors.add({
                        field: 'strSubLocation',
                        message: 'Storage Location must have a value.'
                    })
                }

                if(iRely.Functions.isEmpty(this.get('strStorageLocation')) && (AdjustmentType == 4 || AdjustmentType == 9)) {
                    errors.add({
                        field: 'strStorageLocation',
                        message: 'Storage Unit must have a value.'
                    })
                }

                if(iRely.Functions.isEmpty(this.get('strLotNumber')) && (AdjustmentType == 3 || AdjustmentType == 4 || AdjustmentType == 5 || AdjustmentType == 7 || AdjustmentType == 8 || AdjustmentType == 9)) {
                    errors.add({
                        field: 'strLotNumber',
                        message: 'Lot ID must have a value.'
                    })
                }

                if(iRely.Functions.isEmpty(this.get('strNewLotStatus')) && AdjustmentType == 4) {
                    errors.add({
                        field: 'strNewLotStatus',
                        message: 'New Lot Status must have a value.'
                    })
                }

                 if(iRely.Functions.isEmpty(this.get('strNewLotNumber')) && (AdjustmentType == 5 || AdjustmentType == 8)) {
                    errors.add({
                        field: 'strNewLotNumber',
                        message: 'New Lot Number must have a value.'
                    })
                }

                if(iRely.Functions.isEmpty(this.get('strNewItemUOM')) && AdjustmentType == 5) {
                    errors.add({
                        field: 'strNewItemUOM',
                        message: 'New Split Lot UOM must have a value.'
                    })
                }

                if(iRely.Functions.isEmpty(this.get('dblNewSplitLotQuantity')) && AdjustmentType == 5) {
                    errors.add({
                        field: 'dblNewSplitLotQuantity',
                        message: 'New Split Lot Qty must have a value.'
                    })
                }

                if(iRely.Functions.isEmpty(this.get('strNewLocation')) && (AdjustmentType == 5 || AdjustmentType == 7 || AdjustmentType == 8)) {
                    errors.add({
                        field: 'strNewLocation',
                        message: 'New Location must have a value.'
                    })
                }

                if(iRely.Functions.isEmpty(this.get('strNewSubLocation')) && (AdjustmentType == 5 || AdjustmentType == 7 || AdjustmentType == 8)) {
                    errors.add({
                        field: 'strNewSubLocation',
                        message: 'New Storage Location must have a value.'
                    })
                }

                if(iRely.Functions.isEmpty(this.get('strNewStorageLocation')) && (AdjustmentType == 5 || AdjustmentType == 7 || AdjustmentType == 8)) {
                    errors.add({
                        field: 'strNewStorageLocation',
                        message: 'New Storage Unit must have a value.'
                    })
                }
                
                if(iRely.Functions.isEmpty(this.get('dtmNewExpiryDate')) && AdjustmentType == 6) {
                    errors.add({
                        field: 'dtmNewExpiryDate',
                        message: 'New Expiry Date must have a value.'
                    })
                }

                if(iRely.Functions.isEmpty(this.get('strNewOwnerName')) && AdjustmentType == 9) {
                    errors.add({
                        field: 'strNewOwnerName',
                        message: 'New Owner Name must have a value.'
                    })
                }
            }
         }

         return errors;
    }
});