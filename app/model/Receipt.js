/**
 * Created by LZabala on 10/10/2014.
 */
Ext.define('Inventory.model.Receipt', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.ReceiptItem',
        'Inventory.model.ReceiptInspection',
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryReceiptId',

    fields: [
        { name: 'intInventoryReceiptId', type: 'int'},
        { name: 'strReceiptNumber', type: 'string'},
        { name: 'dtmReceiptDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'intVendorId', type: 'int', allowNull: true },
        { name: 'strReceiptType', type: 'string'},
        { name: 'intSourceId', type: 'int', allowNull: true },
        { name: 'intBlanketRelease', type: 'int', allowNull: true },
        { name: 'intLocationId', type: 'int', allowNull: true },
        { name: 'strVendorRefNo', type: 'string'},
        { name: 'strBillOfLading', type: 'string'},
        { name: 'intShipViaId', type: 'int', allowNull: true },
        { name: 'intProductOrigin', type: 'int', allowNull: true },
        { name: 'intReceiverId', type: 'string'},
        { name: 'intCurrencyId', type: 'int', allowNull: true },
        { name: 'strVessel', type: 'string'},
        { name: 'intFreightTermId', type: 'int', allowNull: true },
        { name: 'strDeliveryPoint', type: 'string'},
        { name: 'strAllocateFreight', type: 'string'},
        { name: 'strFreightBilledBy', type: 'string'},
        { name: 'intShiftNumber', type: 'int'},
        { name: 'strNotes', type: 'string'},
        { name: 'strCalculationBasis', type: 'string'},
        { name: 'dblUnitWeightMile', type: 'float'},
        { name: 'dblFreightRate', type: 'float'},
        { name: 'dblFuelSurcharge', type: 'float'},
        { name: 'dblInvoiceAmount', type: 'float'},
        { name: 'ysnInvoicePaid', type: 'boolean'},
        { name: 'intCheckNo', type: 'int'},
        { name: 'dteCheckDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'intTrailerTypeId', type: 'int', allowNull: true },
        { name: 'dteTrailerArrivalDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'dteTrailerArrivalTime', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'strSealNo', type: 'string'},
        { name: 'strSealStatus', type: 'string'},
        { name: 'dteReceiveTime', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'dblActualTempReading', type: 'float'}
    ],

    validators: [
        {type: 'presence', field: 'dtmReceiptDate'},
        {type: 'presence', field: 'intVendorId'},
        {type: 'presence', field: 'strReceiptType'},
        {type: 'presence', field: 'intLocationId'}
    ]
});