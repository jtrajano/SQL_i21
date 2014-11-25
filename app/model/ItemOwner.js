/**
 * Created by LZabala on 11/25/2014.
 */
Ext.define('Inventory.model.ItemOwner', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemOwnerId',

    fields: [
        { name: 'intItemOwnerId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemOwners',
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
        { name: 'intOwnerId', type: 'int', allowNull: true },
        { name: 'ysnActive', type: 'boolean'},
        { name: 'intSort', type: 'int'},

        { name: 'strCustomerNumber', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'intOwnerId'}
    ]
});