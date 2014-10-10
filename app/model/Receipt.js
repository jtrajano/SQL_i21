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
        { name: 'intVendorId', type: 'int'},
        { name: 'strReceiptType', type: 'string'},
        { name: 'intSourceId', type: 'int'},
        { name: 'intBlanketRelease', type: 'int'},
        { name: 'intLocationId', type: 'int'},
        { name: 'intWarehouseId', type: 'int'},
        { name: 'strVendorRefNo', type: 'string'},
        { name: 'strBillOfLading', type: 'string'},
        { name: 'intShipViaId', type: 'int'},
        { name: 'intReceiptSequenceNo', type: 'int'},
        { name: 'intBatchNo', type: 'int'},
        { name: 'intTermId', type: 'int'},
        { name: 'intProductOrigin', type: 'int'},
        { name: 'strReceiver', type: 'string'},
        { name: 'intCurrencyId', type: 'int'},
        { name: 'strVessel', type: 'string'},
        { name: 'strAPAccount', type: 'string'},
        { name: 'strBillingStatus', type: 'string'},
        { name: 'strOrderNumber', type: 'string'},
        { name: 'intFreightTermId', type: 'int'},
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
        { name: 'intTrailerTypeId', type: 'int'},
        { name: 'dteTrailerArrivalDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'dteTrailerArrivalTime', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'strSealNo', type: 'string'},
        { name: 'strSealStatus', type: 'string'},
        { name: 'dteReceiveTime', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'dblActualTempReading', type: 'float'},
    ],

    hasMany: [
        {
            model: 'Inventory.model.ReceiptItem',
            name: 'tblICInventoryReceiptItems',
            foreignKey: 'intInventoryReceiptId',
            primaryKey: 'intInventoryReceiptId',
            storeConfig: {
                sortOnLoad: true,
                sorters: {
                    direction: 'ASC',
                    property: 'intSort'
                }
            }
        },
        {
            model: 'Inventory.model.ReceiptInspection',
            name: 'tblICInventoryReceiptInspections',
            foreignKey: 'intInventoryReceiptId',
            primaryKey: 'intInventoryReceiptId',
            storeConfig: {
                sortOnLoad: true,
                sorters: {
                    direction: 'ASC',
                    property: 'intSort'
                }
            }
        }
    ]
});