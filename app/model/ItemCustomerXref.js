/**
 * Created by LZabala on 9/29/2014.
 */
Ext.define('Inventory.model.ItemCustomerXref', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemCustomerXrefId',

    fields: [
        { name: 'intItemCustomerXrefId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemCustomerXrefs',
                    storeConfig: {
                        sortOnLoad: true,
                        sorters: {
                            direction: 'ASC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'intLocationId', type: 'int'},
        { name: 'strStoreName', type: 'string'},
        { name: 'intCustomerId', type: 'int'},
        { name: 'strCustomerProduct', type: 'string'},
        { name: 'strProductDescription', type: 'string'},
        { name: 'strPickTicketNotes', type: 'string'},
        { name: 'intSort', type: 'int'},

        { name: 'strLocationName', type: 'string'},
        { name: 'strCustomerNumber', type: 'string'}
    ]
});