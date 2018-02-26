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
                        sortOnLoad: true,
                        autoLoad: false,
                        sorters: {
                            direction: 'DESC',
                            property: 'intSort'
                        },
                        proxy: {
                            api: {
                                read: './inventory/api/itemcontract/getcontractdocument',
                            },
                            type: 'rest',
                            reader: {
                                type: 'json',
                                rootProperty: 'data',
                                messageProperty: 'message'
                            }
                        }
                    }
                }
            }
        },
        { name: 'intDocumentId', type: 'int', allowNull: true },
        { name: 'intSort', type: 'int'},

        { name: 'strDocumentName', type: 'string', auditKey: true}
    ],

    validators: [
        { type: 'presence', field: 'strDocumentName' }
    ]
});