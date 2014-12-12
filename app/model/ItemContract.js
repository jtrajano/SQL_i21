/**
 * Created by LZabala on 9/29/2014.
 */
Ext.define('Inventory.model.ItemContract', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.ItemContractDocument',
        'Ext.data.Field'
    ],

    idProperty: 'intItemContractId',

    fields: [
        { name: 'intItemContractId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemContracts',
                    storeConfig: {
                        remoteFilter: true,
                        proxy: {
                            type: 'rest',
                            api: {
                                read: '../Inventory/api/ItemContract/GetItemContracts'
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
        { name: 'intLocationId', type: 'int', allowNull: true},
        { name: 'strContractItemName', type: 'string', allowNull: true},
        { name: 'intCountryId', type: 'int', allowNull: true },
        { name: 'strGrade', type: 'string'},
        { name: 'strGradeType', type: 'string'},
        { name: 'strGarden', type: 'string'},
        { name: 'dblYieldPercent', type: 'float'},
        { name: 'dblTolerancePercent', type: 'float'},
        { name: 'dblFranchisePercent', type: 'float'},
        { name: 'intSort', type: 'int'},

        { name: 'strLocationName', type: 'string'},
        { name: 'strCountry', type: 'string'}
    ],

    validators: [
        { type: 'presence', field: 'strLocationName' },
        { type: 'presence', field: 'strContractItemName' }
    ]
});