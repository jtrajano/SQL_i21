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
        { name: 'intLocationId', type: 'int', allowNull: true},
        { name: 'intCustomerId', type: 'int', allowNull: true},
        { name: 'strCustomerProduct', type: 'string', allowNull: true},
        { name: 'strProductDescription', type: 'string'},
        { name: 'strPickTicketNotes', type: 'string'},
        { name: 'intSort', type: 'int'},

        { name: 'strLocationName', type: 'string'},
        { name: 'strCustomerNumber', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'intLocationId'},
        {type: 'presence', field: 'intCustomerId'},
        {type: 'presence', field: 'strCustomerProduct'}
    ]
});