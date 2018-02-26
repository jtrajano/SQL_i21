/**
 * Created by LZabala on 12/22/2014.
 */
Ext.define('Inventory.model.ShipmentItemLot', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryShipmentItemLotId',

    fields: [
        { name: 'intInventoryShipmentItemLotId', type: 'int'},
        { name: 'intInventoryShipmentItemId', type: 'int',
            reference: {
                type: 'Inventory.model.ShipmentItem',
                role: 'tblICInventoryShipmentItem',
                inverse: {
                    role: 'tblICInventoryShipmentItemLots',
                    storeConfig: {
                        complete: true,
                        sortOnLoad: true,
                        sorters: {
                            direction: 'DESC',
                            property: 'intSort'
                        },
                        autoLoad: false,
                        proxy: {
                            api: {
                                create: './inventory/api/inventoryshipmentitemlot/post',
                                read: './inventory/api/inventoryshipmentitemlot/searchshipmentlots',
                                update: './inventory/api/inventoryshipmentitemlot/put',
                                destroy: './inventory/api/inventoryshipmentitemlot/delete'
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
        { name: 'dblQuantityShipped', type: 'float' },
        { name: 'dblLotQty', type: 'float' },
        { name: 'dblAvailableQty', type: 'float' },
        { name: 'intItemUOMId', type: 'int', allowNull: true },
        { name: 'intWeightUOMId', type: 'int', allowNull: true },
        { name: 'dblGrossWeight', type: 'float' },
        { name: 'dblTareWeight', type: 'float' },
        { name: 'dblNetWeight', type: 'float',
            persist: false,
            convert: function(value, record){
                return record.get('dblGrossWeight') - record.get('dblTareWeight');
            },
            depends: ['dblGrossWeight', 'dblTareWeight']
        },
        { name: 'strWarehouseCargoNumber', type: 'string' },
        { name: 'intSort', type: 'int', allowNull: true },
        { name: 'strLotNumber', type: 'string', auditKey: true},
        { name: 'strItemUOM', type: 'string'},
        { name: 'dblWeightPerQty', type: 'float' }
    ],

    validators: [
        {type: 'presence', field: 'strLotNumber'}
    ],

    validate: function(options){
        var errors = this.callParent(arguments);
        if (this.get('dblQuantityShipped') > this.get('dblAvailableQty')) {
            errors.add({
                field: 'dblQuantityShipped',
                message: 'Ship Qty cannot be more than the Available Qty.'
            })
        }
        return errors;
    }
});