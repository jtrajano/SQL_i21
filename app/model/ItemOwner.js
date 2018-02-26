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
                        remoteFilter: true,
                        complete: true, 
                        proxy: {
                            extraParams: { include: 'tblARCustomer' },
                            type: 'rest',
                            api: {
                                read: './inventory/api/itemowner/get'
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
        { name: 'intOwnerId', type: 'int', allowNull: true },
        { name: 'ysnDefault', type: 'boolean'},
        { name: 'intSort', type: 'int'},

        { name: 'strCustomerNumber', type: 'string', auditKey: true},
        { name: 'strName', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strCustomerNumber'}
    ]
});