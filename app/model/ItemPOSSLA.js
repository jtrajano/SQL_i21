/**
 * Created by LZabala on 9/24/2014.
 */
Ext.define('Inventory.model.ItemPOSSLA', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemPOSSLAId',

    fields: [
        { name: 'intItemPOSSLAId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemPOSSLAs',
                    storeConfig: {
                        remoteFilter: true,
                        proxy: {
                            type: 'rest',
                            api: {
                                read: './inventory/api/itempossla/get'
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
        { name: 'strSLAContract', type: 'string'},
        { name: 'dblContractPrice', type: 'float'},
        { name: 'ysnServiceWarranty', type: 'boolean'}
    ],

    validators: [
        {type: 'presence', field: 'strSLAContract'}
    ]
});