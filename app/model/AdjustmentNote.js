/**
 * Created by LZabala on 3/27/2015.
 */
Ext.define('Inventory.model.AdjustmentNote', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryAdjustmentNoteId',

    fields: [
        { name: 'intInventoryAdjustmentNoteId', type: 'int' },
        { name: 'intInventoryAdjustmentId', type: 'int',
            reference: {
                type: 'Inventory.model.Adjustment',
                inverse: {
                    role: 'tblICInventoryAdjustmentNotes',
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
        { name: 'strDescription', type: 'string' },
        { name: 'strNotes', type: 'string' },
        { name: 'intSort', type: 'int', allowNull: true }
    ],

    validators: [

    ]
});