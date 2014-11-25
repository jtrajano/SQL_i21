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
        { name: 'intFactoryId', type: 'int', allowNull: true },
        { name: 'ysnDefault', type: 'boolean'},
        { name: 'intSort', type: 'int'},

        { name: 'strLocationName', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'intFactoryId'}
    ]
});