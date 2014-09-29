/**
 * Created by LZabala on 9/29/2014.
 */
Ext.define('Inventory.model.Certification', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intCertificationId',

    fields: [
        { name: 'intCertificationId', type: 'int'},
        { name: 'strCertificationName', type: 'string'},
        { name: 'strIssuingOrganization', type: 'string'},
        { name: 'ysnGlobalCertification', type: 'boolean'},
        { name: 'intCountryId', type: 'int'},
        { name: 'strCertificationIdName', type: 'string'}
    ],

    hasMany: {
        model: 'Inventory.model.CertificationCommodity',
        name: 'tblICCertificationCommodities',
        foreignKey: 'intCertificationId',
        primaryKey: 'intItemId',
        storeConfig: {
            sortOnLoad: true,
            sorters: {
                direction: 'ASC',
                property: 'intSort'
            }
        }
    }
});