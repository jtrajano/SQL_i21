/**
 * Created by LZabala on 4/16/2015.
 */
Ext.define('Inventory.model.TransferNote', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryTransferNoteId',

    fields: [
        { name: 'intInventoryTransferNoteId', type: 'int' },
        { name: 'intInventoryTransferId', type: 'int',
            reference: {
                type: 'Inventory.model.Transfer',
                inverse: {
                    role: 'tblICInventoryTransferNotes',
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
        { name: 'strNoteType', type: 'string' },
        { name: 'strNotes', type: 'string' },
        { name: 'intSort', type: 'int', allowNull: true }
    ],

    validators: [

    ]
});