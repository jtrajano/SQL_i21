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
                        autoLoad: true,
                        sorters: {
                            direction: 'DESC',
                            property: 'intSort'
                        },
                        proxy: {
                            api: {
                                read: '../Inventory/api/ItemContract/GetContractDocument',
                            },
                            type: 'rest',
                            reader: {
                                type: 'json',
                                rootProperty: 'data',
                                messageProperty: 'message'
                            },
                            writer: {
                                type: 'json',
                                allowSingle: false
                            },
                            sortOnLoad: true,
                            sorters: {
                                direction: 'DESC',
                                property: 'intSort'
                            }
                        }
                    }
                }
            }
        },
        { name: 'intDocumentId', type: 'int', allowNull: true },
        { name: 'intSort', type: 'int'},

        { name: 'strDocumentName', type: 'string'}
    ],

    validators: [
        { type: 'presence', field: 'strDocumentName' }
    ]
});