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
                        remoteFilter: true,
                        complete: true, 
                        proxy: {
                            extraParams: { include: 'tblICCertification' },
                            type: 'rest',
                            api: {
                                read: './inventory/api/itemcertification/get'
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
        { name: 'intCertificationId', type: 'int', allowNull: true },
        { name: 'intSort', type: 'int'},

        { name: 'strCertificationName', type: 'string', auditKey: true}
    ],

    validators: [
        { type: 'presence', field: 'strCertificationName' }
    ]
});