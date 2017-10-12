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
                        remoteFilter: true,
                        proxy: {
                            extraParams: { include: 'tblARCustomer, tblICItemLocation.vyuICGetItemLocation' },
                            type: 'rest',
                            api: {
                                read: './inventory/api/itemcustomerxref/get'
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
        { name: 'intCustomerId', type: 'int', allowNull: true },
        { name: 'strCustomerProduct', type: 'string' },
        { name: 'strProductDescription', type: 'string' },
        { name: 'strPickTicketNotes', type: 'string' },
        { name: 'intSort', type: 'int', allowNull: true },

        { name: 'strLocationName', type: 'string'},
        { name: 'strCustomerNumber', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strCustomerNumber'},
        {type: 'presence', field: 'strCustomerProduct'},
        {type: 'presence', field: 'strProductDescription'}
    ]
});