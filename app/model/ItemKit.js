/**
 * Created by LZabala on 10/27/2014.
 */
Ext.define('Inventory.model.ItemKit', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.ItemKitDetail',
        'Ext.data.Field'
    ],

    idProperty: 'intItemKitId',

    fields: [
        { name: 'intItemKitId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemKits',
                    storeConfig: {
                        remoteFilter: true,
                        complete: true, 
                        proxy: {
                            extraParams: { include: 'tblICItemKitDetails.tblICItem, tblICItemKitDetails.tblICItemUOM' },
                            type: 'rest',
                            api: {
                                read: './inventory/api/itemkit/get'
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
            }},
        { name: 'strComponent', type: 'string', allowNull: true },
        { name: 'strInputType', type: 'string', allowNull: true },
        { name: 'intSort', type: 'int'}
    ],

    validators: [
        {type: 'presence', field: 'strComponent'},
        {type: 'presence', field: 'strInputType'}
    ]
});