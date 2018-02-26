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
        { name: 'intSourceId', type: 'int', allowNull: true },
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
        { name: 'intNewLotId', type: 'int', allowNull: true },
        { name: 'strNewLotId', type: 'string' },
        { name: 'dblCost', type: 'float' },
        { name: 'intTaxCodeId', type: 'int', allowNull: true },
        { name: 'dblFreightRate', type: 'float' },
        { name: 'dblFreightAmount', type: 'float' },
        { name: 'intSort', type: 'int', allowNull: true },

        { name: 'strItemNo', type: 'string', auditKey: true },
        { name: 'strUnitMeasure', type: 'string' },
        { name: 'dblTaxAmount', type: 'float'},

        { name: 'dblOriginalAvailableQty', type: 'float' },
        { name: 'dblOriginalStorageQty', type: 'float' },
        { name: 'strToStorageLocationName', type: 'string'},
        { name: 'strItemType', type: 'string'},
        { name: 'dblGross', type: 'float', defaultValue: 0.00, allowNull: true },
        { name: 'dblNet', type: 'float', defaultValue: 0.00, allowNull: true, persist: true, 
            convert: function(value, record) {
                if(!record) return value;
                var dblGross = iRely.Functions.isEmpty(record.get('dblGross')) ? 0 : record.get('dblGross');
                var dblTare = iRely.Functions.isEmpty(record.get('dblTare')) ? 0 : record.get('dblTare');
                return dblGross - dblTare;
            },
            depends: ['dblGross', 'dblTare']
        },
        { name: 'dblTare', type: 'float', defaultValue: 0.00, allowNull: true },
        { name: 'intNewLotStatusId', type: 'int', allowNull: true },
        { name: 'strNewLotStatus', type: 'string' },
        { name: 'strLotCondition', type: 'string' },
        { name: 'intGrossNetUOMId', type: 'int', allowNull: true },
        { name: 'strGrossNetUOM', type: 'string' },
        //{ name: 'dblGrossNetUnitQty', type: 'float', allowNull: true },
        //{ name: 'dblItemUnitQty', type: 'float', allowNull: true}
        { name: 'dblWeightPerQty', type: 'float', allowNull: true}
    ],

    validators: [
        { type: 'presence', field: 'strItemNo' },
        { type: 'presence', field: 'dblQuantity' }
    ],

    validate: function(options) {
        var errors = this.callParent(arguments);
        if (this.get('dblQuantity') <= 0 && this.get('strItemType') !== 'Comment') {
            errors.add({
                field: 'dblQuantity',
                message: 'Transfer Qty must be greater than zero(0).'
            })
        }

        if (this.get('intLotId') && !this.get('intToStorageLocationId') && this.get('strItemType') !== 'Comment') {
            errors.add({
                field: 'strToStorageLocationName',
                message: 'Storage Unit is required for lotted items.'
            })
        }

        return errors;
    }
});