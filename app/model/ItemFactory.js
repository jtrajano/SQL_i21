/**
 * Created by LZabala on 11/25/2014.
 */
Ext.define('Inventory.model.ItemFactory', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.ItemFactoryManufacturingCell',
        'Ext.data.Field'
    ],

    idProperty: 'intItemFactoryId',

    fields: [
        { name: 'intItemFactoryId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemFactories',
                    storeConfig: {
                        remoteFilter: true,
                        complete: true, 
                        proxy: {
                            extraParams: { include: 'tblICItemFactoryManufacturingCells.vyuICGetItemFactoryManufacturingCell, tblSMCompanyLocation' },
                            type: 'rest',
                            api: {
                                read: './inventory/api/itemfactory/get'
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
        { name: 'intFactoryId', type: 'int', allowNull: true },
        { name: 'ysnDefault', type: 'boolean'},
        { name: 'intSort', type: 'int'},

        { name: 'strLocationName', type: 'string', auditKey: true}
    ],

    validators: [
        {type: 'presence', field: 'strLocationName'}
    ]
});