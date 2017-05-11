/**
 * Created by LZabala on 12/22/2014.
 */
Ext.define('Inventory.model.Shipment', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.ShipmentItem',
        'Inventory.model.ShipmentCharge',
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryShipmentId',

    fields: [
        { name: 'intInventoryShipmentId', type: 'int' },
        { name: 'strShipmentNumber', type: 'string' },
        { name: 'dtmShipDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'intOrderType', type: 'int', allowNull: true },
        { name: 'intSourceType', type: 'int', allowNull: true },
        { name: 'strReferenceNumber', type: 'string' },
        { name: 'dtmRequestedArrivalDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'intShipFromLocationId', type: 'int', allowNull: true },
        { name: 'strShipFromLocation', type: 'string' },
        { name: 'intEntityCustomerId', type: 'int', allowNull: true },
        { name: 'intShipToLocationId', type: 'int', allowNull: true },
        { name: 'intFreightTermId', type: 'int', allowNull: true },
        { name: 'strFreightTerm', type: 'string' },
        { name: 'intCurrencyId', type: 'int', allowNull: true },
        { name: 'strCurrency', type: 'string' },
        { name: 'strBOLNumber', type: 'string' },
        { name: 'intShipViaId', type: 'int', allowNull: true },
        { name: 'strVessel', type: 'string' },
        { name: 'strProNumber', type: 'string' },
        { name: 'strDriverId', type: 'string' },
        { name: 'strSealNumber', type: 'string' },
        { name: 'strDeliveryInstruction', type: 'string' },
        { name: 'dtmAppointmentTime', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'dtmDepartureTime', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'dtmArrivalTime', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'dtmDeliveredDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'dtmFreeTime', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'strReceivedBy', type: 'string' },
        { name: 'strComment', type: 'string' },
        { name: 'ysnPosted', type: 'boolean' },
        { name: 'intEntityId', type: 'int', allowNull: true },
        { name: 'intCreatedUserId', type: 'int', allowNull: true },

        { name: 'strOrderType', type: 'string'},
        { name: 'strShipFromAddress', type: 'string'},
        { name: 'strShipToAddress', type: 'string'},
        { name: 'intShipToCompanyLocationId', type: 'int', allowNull: true },
        { name: 'strShipToLocation', type: 'string'}

    ],

    validators: [
        {type: 'presence', field: 'dtmShipDate'},
        {type: 'presence', field: 'intOrderType'},
        {type: 'presence', field: 'strShipFromLocation'},
        {type: 'presence', field: 'strShipToLocation'},
        {type: 'presence', field: 'strFreightTerm'},
        {type: 'presence', field: 'strCurrency'}
    ],

    validate: function(options) {
        var errors = this.callParent(arguments);

        // If not Transfer order, require to add a customer.
        if (this.get('intOrderType') !== 3 && iRely.Functions.isEmpty(this.get('intEntityCustomerId'))) {
            errors.add({
                field: 'intEntityCustomerId',
                message: 'Customer must not be empty.'
            })
        }

        // // If not Transfer order, require to add a Ship To Location.
        // if (this.get('intOrderType') !== 3 && iRely.Functions.isEmpty(this.get('intShipToLocationId'))) {
        //     errors.add({
        //         field: 'strShipToLocation',
        //         message: 'Ship To must not be empty.'
        //     })
        // }

        // // If it is a Transfer Order, require the Ship To Company Location Id
        // if (this.get('intOrderType') === 3 && iRely.Functions.isEmpty(this.get('intShipToCompanyLocationId'))) {
        //     errors.add({
        //         field: 'strShipToLocation',
        //         message: 'Ship To must not be empty.'
        //     })
        // }

        return errors;
    }
});