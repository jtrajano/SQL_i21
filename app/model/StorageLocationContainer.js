/**
 * Created by LZabala on 11/24/2014.
 */
Ext.define('Inventory.model.StorageLocationContainer', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intStorageLocationContainerId',

    fields: [
        { name: 'intStorageLocationContainerId', type: 'int'},
        { name: 'intStorageLocationId', type: 'int',
            reference: {
                type: 'Inventory.model.StorageLocation',
                inverse: {
                    role: 'tblICStorageLocationContainers',
                    storeConfig: {
                        complete: true,
                        sortOnLoad: true,
                        sorters: {
                            direction: 'DESC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'intContainerId', type: 'int', allowNull: true },
        { name: 'intExternalSystemId', type: 'int'},
        { name: 'intContainerTypeId', type: 'int', allowNull: true },
        { name: 'strLastUpdatedBy', type: 'string'},
        { name: 'dtmLastUpdatedOn', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'intSort', type: 'int'},
        { name: 'strContainer', type: 'string'},
        { name: 'strContainerType', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strContainer'}
    ]
});