/**
 * Created by LZabala on 12/22/2014.
 */
Ext.define('Inventory.model.Shipment', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.ShipmentItem',
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryShipmentId',

    fields: [
        { name: 'intInventoryShipmentId', type: 'int'},
        { name: 'strBOLNumber', type: 'string'},
        { name: 'dtmShipDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'intOrderType', type: 'int', allowNull: true},
        { name: 'strReferenceNumber', type: 'string'},
        { name: 'dtmRequestedArrivalDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'intShipFromLocationId', type: 'int', allowNull: true},
        { name: 'intShipToLocationId', type: 'int', allowNull: true},
        { name: 'intCustomerId', type: 'int', allowNull: true},
        { name: 'intFreightTermId', type: 'int', allowNull: true},
        { name: 'ysnDirectShipment', type: 'boolean'},
        { name: 'intCarrierId', type: 'int', allowNull: true},
        { name: 'strVessel', type: 'string'},
        { name: 'strProNumber', type: 'string'},
        { name: 'strDriverId', type: 'string'},
        { name: 'strSealNumber', type: 'string'},
        { name: 'dtmAppointmentTime', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'dtmDepartureTime', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'dtmArrivalTime', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'dtmDeliveredDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'dtmFreeTime', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'strReceivedBy', type: 'string'},
        { name: 'strComment', type: 'string'},
        { name: 'strDeliveryInstruction', type: 'string'},

        { name: 'strOrderType', type: 'string'},
        { name: 'strShipFromAddress', type: 'string'},
        { name: 'strShipToAddress', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strBOLNumber'},
        {type: 'presence', field: 'dtmShipDate'},
        {type: 'presence', field: 'intOrderType'},
        {type: 'presence', field: 'intShipFromLocationId'},
        {type: 'presence', field: 'intShipToLocationId'},
        {type: 'presence', field: 'intFreightTermId'}
    ]
});