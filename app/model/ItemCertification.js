/**
 * Created by LZabala on 9/29/2014.
 */
Ext.define('Inventory.model.ItemCertification', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemCertificationId',

    fields: [
        { name: 'intItemCertificationId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemCertifications',
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
        { name: 'intCertificationId', type: 'int'},
        { name: 'intSort', type: 'int'},

        { name: 'strCertificationName', type: 'string'}
    ],

    validators: [
        { type: 'presence', field: 'intCertificationId' }
    ]
});