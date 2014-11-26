/**
 * Created by LZabala on 11/24/2014.
 */
Ext.define('Inventory.model.StorageLocationSku', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intStorageLocationSkuId',

    fields: [
        { name: 'intStorageLocationSkuId', type: 'int'},
        { name: 'intStorageLocationId', type: 'int',
            reference: {
                type: 'Inventory.model.StorageLocation',
                inverse: {
                    role: 'tblICStorageLocationSkus',
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
        { name: 'intItemId', type: 'int', allowNull: true },
        { name: 'intSkuId', type: 'int', allowNull: true },
        { name: 'dblQuantity', type: 'float'},
        { name: 'intContainerId', type: 'int', allowNull: true },
        { name: 'intLotCodeId', type: 'int', allowNull: true },
        { name: 'intLotStatusId', type: 'int', allowNull: true },
        { name: 'intOwnerId', type: 'int', allowNull: true },
        { name: 'intSort', type: 'int'},

        { name: 'strSKU', type: 'string'},
        { name: 'strItemNo', type: 'string'},
        { name: 'strContainer', type: 'string'},
        { name: 'strLotStatus', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'intItemId'},
        {type: 'presence', field: 'intSkuId'}
    ]
});