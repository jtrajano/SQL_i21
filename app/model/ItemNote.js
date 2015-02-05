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
                        remoteFilter: true,
                        proxy: {
                            type: 'rest',
                            api: {
                                read: '../Inventory/api/ItemNote/GetItemNotes'
                            },
                            reader: {
                                type: 'json',
                                rootProperty: 'data',
                                messageProperty: 'message'
                            }
                        },
                        sortOnLoad: true,
                        sorters: {
                            direction: 'DESC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'intItemLocationId', type: 'int', allowNull: true },
        { name: 'strCommentType', type: 'string' },
        { name: 'strComments', type: 'string' },
        { name: 'intSort', type: 'int', allowNull: true },

        { name: 'strLocationName', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strLocationName'}
    ]
});