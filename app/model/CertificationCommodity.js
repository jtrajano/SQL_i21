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
        { name: 'intCertificationId', type: 'int'},
        { name: 'intCommodityId', type: 'int'},
        { name: 'intCurrencyId', type: 'int'},
        { name: 'dblCertificationPremium', type: 'float'},
        { name: 'intUnitMeasureId', type: 'int'},
        { name: 'dtmDateEffective', type: 'date'},
        { name: 'intSort', type: 'int'}
    ]
});