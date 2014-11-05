/**
 * Created by LZabala on 9/29/2014.
 */
Ext.define('Inventory.model.ItemContractDocument', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemContractDocumentId',

    fields: [
        { name: 'intItemContractDocumentId', type: 'int'},
        { name: 'intItemContractId', type: 'int',
            reference: {
                type: 'Inventory.model.ItemContract',
                inverse: {
                    role: 'tblICItemContractDocuments',
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
        { name: 'intDocumentId', type: 'int'},
        { name: 'intSort', type: 'int'},

        { name: 'strDocumentName', type: 'string'}
    ],

    validators: [
        { type: 'presence', field: 'intDocumentId' }
    ]
});