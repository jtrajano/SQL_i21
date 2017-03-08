/**
 * Created by LZabala on 12/22/2014.
 */
Ext.define('Inventory.model.ShipmentItem', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.ShipmentItemLot',
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryShipmentItemId',

    fields: [
        { name: 'intInventoryShipmentItemId', type: 'int'},
        { name: 'intInventoryShipmentId', type: 'int',
            reference: {
                type: 'Inventory.model.Shipment',
                inverse: {
                    role: 'tblICInventoryShipmentItems',
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
        { name: 'intOrderId', type: 'int', allowNull: true },
        { name: 'intSourceId', type: 'int', allowNull: true },
        { name: 'intLineNo', type: 'int', allowNull: true },
        { name: 'intItemId', type: 'int', allowNull: true },
        { name: 'intSubLocationId', type: 'int', allowNull: true },
        { name: 'intStorageLocationId', type: 'int', allowNull: true },
        { name: 'dblQuantity', type: 'float' },
        { name: 'intItemUOMId', type: 'int', allowNull: true },
        { name: 'intWeightUOMId', type: 'int', allowNull: true },
        { name: 'dblUnitCost', type: 'float' },
        { name: 'dblUnitPrice', type: 'float' },
        { name: 'intTaxCodeId', type: 'int', allowNull: true },
        { name: 'intDockDoorId', type: 'int', allowNull: true },
        { name: 'strNotes', type: 'string' },
        { name: 'intSort', type: 'int', allowNull: true },

        { name: 'strItemNo', type: 'string'},
        { name: 'strUnitMeasure', type: 'string'},
        { name: 'strWeightUOM', type: 'string'},
        { name: 'strSubLocationName', type: 'string'},
        { name: 'strStorageLocationName', type: 'string'},
        { name: 'intDecimalPlaces', type: 'int', allowNull: true },

        { name: 'dblLineTotal', type: 'float',
            persist: false,
            convert: function(value, record){
                var qty = iRely.Functions.isEmpty(record.get('dblQuantity')) ? 0 : record.get('dblQuantity');
                var price = iRely.Functions.isEmpty(record.get('dblUnitPrice')) ? 0 : record.get('dblUnitPrice');
                return qty * price;
            },
            depends: ['dblQuantity', 'dblUnitPrice']
        },
        { name: 'intCustomerStorageId', type: 'int', allowNull: true},
        { name: 'strStorageTypeDescription', type: 'string' },
        { name: 'intForexRateTypeId', type: 'int', allowNull: true },
        { name: 'strForexRateType', type: 'string'},
        { name: 'dblForexRate', type: 'float', allowNull: true }
        // { name: 'dblForeignLineTotal', type: 'float',
        //     persist: false,
        //     convert: function(value, record){
        //         var qty = iRely.Functions.isEmpty(record.get('dblQuantity')) ? 0 : record.get('dblQuantity');
        //         var price = iRely.Functions.isEmpty(record.get('dblForeignUnitPrice')) ? 0 : record.get('dblForeignUnitPrice');

        //         return qty * price;
        //     },
        //     depends: ['dblQuantity', 'dblForeignUnitPrice']
        // }
    ],

    validators: [
        {type: 'presence', field: 'strReferenceNumber'},
        {type: 'presence', field: 'strItemNo'},
        {type: 'presence', field: 'strUnitMeasure'}
    ],

    validate: function(options) {
        var errors = this.callParent(arguments);
        if (this.get('dblQuantity') <= 0) {
            errors.add({
                field: 'dblQuantity',
                message: 'Quantity must be greater than zero(0).'
            })
        }
        return errors;
    }
});