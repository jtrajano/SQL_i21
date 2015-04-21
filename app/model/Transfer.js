/**
 * Created by LZabala on 4/16/2015.
 */
Ext.define('Inventory.model.Transfer', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.TransferDetail',
        'Inventory.model.TransferNote',
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryTransferId',

    fields: [
        { name: 'intInventoryTransferId', type: 'int', allowNull: true },
        { name: 'strTransferNo', type: 'string' },
        { name: 'dtmTransferDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'strTransferType', type: 'string' },
        { name: 'intTransferredById', type: 'int', allowNull: true },
        { name: 'strDescription', type: 'string' },
        { name: 'intFromLocationId', type: 'int', allowNull: true },
        { name: 'intToLocationId', type: 'int', allowNull: true },
        { name: 'ysnShipmentRequired', type: 'boolean' },
        { name: 'intShipViaId', type: 'int', allowNull: true },
        { name: 'intFreightUOMId', type: 'int', allowNull: true },
        { name: 'intAccountCategoryId', type: 'int', allowNull: true },
        { name: 'intAccountId', type: 'int', allowNull: true },
        { name: 'intSort', type: 'int', allowNull: true },

        { name: 'dblTaxAmount', type: 'float' }

    ],

    validators: [
        { type: 'presence', field: 'dtmTransferDate' },
        { type: 'presence', field: 'strTransferType' },
        { type: 'presence', field: 'intFromLocationId' },
        { type: 'presence', field: 'intToLocationId' }
    ]
});