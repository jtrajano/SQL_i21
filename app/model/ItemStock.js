/**
 * Created by LZabala on 10/20/2014.
 */
Ext.define('Inventory.model.ItemStock', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemStockId',

    fields: [
        { name: 'intItemStockId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemStocks',
                    storeConfig: {
                        remoteFilter: true,
                        proxy: {
                            extraParams: { include: 'tblICItemLocation.tblSMCompanyLocation' },
                            type: 'rest',
                            api: {
                                read: '../Inventory/api/ItemStock/Get'
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
        { name: 'intItemLocationId', type: 'int', allowNull: true },
        { name: 'intSubLocationId', type: 'int', allowNull: true },
        { name: 'dblUnitOnHand', type: 'float' },
        { name: 'dblUnitInCustody', type: 'float' },
        { name: 'dblUnitInConsigned', type: 'float' },
        { name: 'dblOrderCommitted', type: 'float' },
        { name: 'dblOnOrder', type: 'float' },
        { name: 'dblBackOrder', type: 'float' },
        { name: 'dblLastCountRetail', type: 'float' },
        { name: 'intSort', type: 'int', allowNull: true }

    ],

    validators: [
        {type: 'presence', field: 'strLocationName'}
    ]
});