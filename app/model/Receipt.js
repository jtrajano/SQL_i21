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
        { name: 'strReceiptType', type: 'string'},
        { name: 'intVendorId', type: 'int', allowNull: true },
        { name: 'intTransferorId', type: 'int', allowNull: true },
        { name: 'intLocationId', type: 'int', allowNull: true },
        { name: 'strReceiptNumber', type: 'string'},
        { name: 'dtmReceiptDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'intCurrencyId', type: 'int', allowNull: true },
        { name: 'intBlanketRelease', type: 'int', allowNull: true },
        { name: 'strVendorRefNo', type: 'string'},
        { name: 'strBillOfLading', type: 'string'},
        { name: 'intShipViaId', type: 'int', allowNull: true },
        { name: 'intShipFromId', type: 'int', allowNull: true },
        { name: 'intReceiverId', type: 'int', allowNull: true },
        { name: 'strVessel', type: 'string'},
        { name: 'intFreightTermId', type: 'int', allowNull: true },
        { name: 'strAllocateFreight', type: 'string'},
        { name: 'intShiftNumber', type: 'int', allowNull: true },
        { name: 'strCalculationBasis', type: 'string'},
        { name: 'dblUnitWeightMile', type: 'float'},
        { name: 'dblFreightRate', type: 'float'},
        { name: 'dblFuelSurcharge', type: 'float'},
        { name: 'dblInvoiceAmount', type: 'float'},
        { name: 'ysnPrepaid', type: 'boolean'},
        { name: 'ysnInvoicePaid', type: 'boolean'},
        { name: 'intCheckNo', type: 'int'},
        { name: 'dtmCheckDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'intTrailerTypeId', type: 'int', allowNull: true },
        { name: 'dtmTrailerArrivalDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'dtmTrailerArrivalTime', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'strSealNo', type: 'string'},
        { name: 'strSealStatus', type: 'string'},
        { name: 'dtmReceiveTime', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'dblActualTempReading', type: 'float'},
        { name: 'ysnPosted', type: 'boolean'},
        { name: 'intCreatedUserId', type: 'int', allowNull: true },
        { name: 'intEntityId', type: 'int', allowNull: true }
    ],

    validators: [
        {type: 'presence', field: 'dtmReceiptDate'},
        {type: 'presence', field: 'intVendorId'},
        {type: 'presence', field: 'strReceiptType'},
        {type: 'presence', field: 'intLocationId'}
    ]
});