/**
 * Created by LZabala on 10/15/2014.
 */
Ext.define('Inventory.model.ItemNote', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemNoteId',

    fields: [
        { name: 'intItemNoteId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemNotes',
                    storeConfig: {
                        complete: true,
                        sortOnLoad: true,
                        sorters: {
                            direction: 'ASC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'intLocationId', type: 'int', allowNull: true },
        { name: 'strCommentType', type: 'string'},
        { name: 'strComments', type: 'string'},
        { name: 'intSort', type: 'int'},

        { name: 'strLocationName', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strLocationName'}
    ]
});