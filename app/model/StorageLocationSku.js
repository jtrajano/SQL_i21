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
        { name: 'intItemId', type: 'int'},
        { name: 'intSkuId', type: 'int'},
        { name: 'dblQuantity', type: 'float'},
        { name: 'intContainerId', type: 'int'},
        { name: 'intLotCodeId', type: 'int'},
        { name: 'intLotStatusId', type: 'int'},
        { name: 'intOwnerId', type: 'int'},
        { name: 'intSort', type: 'int'}
    ],

    validators: [
        {type: 'presence', field: 'intItemId'},
        {type: 'presence', field: 'intSkuId'},
    ]
});