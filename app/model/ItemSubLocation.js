Ext.define('Inventory.model.ItemSubLocation', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemSubLocationId',

    fields: [
        { name: 'intItemSubLocationId', type: 'int'},
        { name: 'intItemLocationId', type: 'int',
            reference: {
                type: 'Inventory.model.ItemLocation',
                inverse: {
                    role: 'tblICItemSubLocations',
                    storeConfig: {
                        sortOnLoad: true,
                        autoLoad: false,
                        sorters: {
                            direction: 'DESC',
                            property: 'intSort'
                        },
                        proxy: {
                            api: {
                                read: '../Inventory/api/ItemSubLocation/GetItemSubLocations',
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
        { name: 'intSubLocationId', type: 'int' },
        { name: 'strSubLocationName', type: 'string' }
    ]
});