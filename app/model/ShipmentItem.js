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
        { name: 'strReferenceNumber', type: 'string'},
        { name: 'intItemId', type: 'int'},
        { name: 'intSubLocationId', type: 'int'},
        { name: 'dblQuantity', type: 'float'},
        { name: 'intUnitMeasureId', type: 'int'},
        { name: 'intWeightUomId', type: 'int'},
        { name: 'dblTareWeight', type: 'float'},
        { name: 'dbNetWeight', type: 'float'},
        { name: 'dblUnitPrice', type: 'float'},
        { name: 'intDockDoorId', type: 'int'},
        { name: 'strNotes', type: 'string'},
        { name: 'intSort', type: 'int'},

        { name: 'strItemNo', type: 'string'},
        { name: 'strUnitMeasure', type: 'string'},
    ],

    validators: [
        {type: 'presence', field: 'strReferenceNumber'},
        {type: 'presence', field: 'strItemNo'},
        {type: 'presence', field: 'dblQuantity'},
        {type: 'presence', field: 'strUnitMeasure'}
    ]
});