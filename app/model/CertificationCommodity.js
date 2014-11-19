/**
 * Created by LZabala on 9/29/2014.
 */
Ext.define('Inventory.model.CertificationCommodity', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intCertificationCommodityId',

    fields: [
        { name: 'intCertificationCommodityId', type: 'int'},
        { name: 'intCertificationId', type: 'int',
            reference: {
                type: 'Inventory.model.Certification',
                inverse: {
                    role: 'tblICCertificationCommodities',
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
        { name: 'intCommodityId', type: 'int', allowNull: true},
        { name: 'intCurrencyId', type: 'int', allowNull: true},
        { name: 'dblCertificationPremium', type: 'float'},
        { name: 'intUnitMeasureId', type: 'int', allowNull: true},
        { name: 'dtmDateEffective', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'intSort', type: 'int'}

    ],

    validators: [
        {type: 'presence', field: 'intCommodityId'}
    ]
});