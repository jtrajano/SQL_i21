/**
 * Created by LZabala on 9/29/2014.
 */
Ext.define('Inventory.model.Certification', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.CertificationCommodity',
        'Ext.data.Field'
    ],

    idProperty: 'intCertificationId',

    fields: [
        { name: 'intCertificationId', type: 'int'},
        { name: 'strCertificationName', type: 'string'},
        { name: 'strIssuingOrganization', type: 'string'},
        { name: 'ysnGlobalCertification', type: 'boolean'},
        { name: 'intCountryId', type: 'int', allowNull: true},
        { name: 'strCertificationIdName', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strCertificationName'}
    ]
});