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
        { name: 'dtmShipDate', type: 'date'},
        { name: 'intOrderType', type: 'int'},
        { name: 'strReferenceNumber', type: 'string'},
        { name: 'dtmRequestedArrivalDate', type: 'date'},
        { name: 'intShipFromLocationId', type: 'int'},
        { name: 'intCustomerId', type: 'int'},
        { name: 'strShipToAddress', type: 'string'},
        { name: 'intFreightTermId', type: 'int'},
        { name: 'ysnDirectShipment', type: 'boolean'},
        { name: 'intCarrierId', type: 'int'},
        { name: 'strVessel', type: 'string'},
        { name: 'strProNumber', type: 'string'},
        { name: 'strDriverId', type: 'string'},
        { name: 'strSealNumber', type: 'string'},
        { name: 'dtmAppointmentTime', type: 'date'},
        { name: 'dtmDepartureTime', type: 'date'},
        { name: 'dtmArrivalTime', type: 'date'},
        { name: 'dtmDeliveredDate', type: 'date'},
        { name: 'dtmFreeTime', type: 'date'},
        { name: 'strReceivedBy', type: 'string'},

        { name: 'strOrderType', type: 'int'}
    ],

    validators: [
        {type: 'presence', field: 'strBOLNumber'},
        {type: 'presence', field: 'dtmShipDate'},
        {type: 'presence', field: 'intOrderType'},
        {type: 'presence', field: 'intShipFromLocationId'},
        {type: 'presence', field: 'strShipToAddress'},
        {type: 'presence', field: 'intFreightTermId'}
    ]
});