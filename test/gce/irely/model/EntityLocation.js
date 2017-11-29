Ext.define('iRely.model.EntityLocation', {
    extend: 'iRely.BaseEntity',
    alias: 'model.entitylocation',

    requires: [
        'Ext.data.Field',
        'iRely.model.EntityToContact'
    ],

    idProperty: 'intEntityLocationId',

    fields: [
        {
            name: 'intEntityLocationId',
            type: 'int'
        },
        {
            name: 'intEntityId',
            type: 'int',
            reference: {
                type: 'iRely.model.Entity',
                role: 'tblEntity',
                inverse: 'tblEntityLocations'
            }
        },
        {
            name: 'strLocationName',
            type: 'string'
        },
        {
            name: 'strAddress',
            type: 'string'
        },
        {
            name: 'strZipCode',
            type: 'string'
        },
        {
            name: 'strCity'
        },
        {
            name: 'strState',
            type: 'string'
        },
        {
            name: 'strCountry',
            type: 'string'
        },
        {
            name: 'strPhoneLocation',
            mapping: 'strPhone',
            type: 'string'
        },
        {
            name: 'strLocationFax',
            mapping: 'strFax',
            type: 'string'
        },
        {
            name: 'strPricingLevel',
            type: 'string'
        },
        {
            name: 'intShipViaId',
            type: 'int',
            allowNull: true
        },
        {
            name: 'intTaxCodeId',
            type: 'int',
            allowNull: true
        },
        {
            name: 'intTermsId',
            allowNull: true
        },
        {
            name: 'intWarehouseId',
            type: 'int',
            allowNull: true
        },
        {
            name: 'strLocationNotes',
            mapping: 'strNotes',
            type: 'string'
        }
    ],

    validators: [
        {
            type: 'presence',
            field: 'strLocationName',
            message: 'This field is required'
        },
        {
            type: 'presence',
            field: 'intTermsId',
            message: 'This field is required'
        },
        {
            type: 'phone',
            field: 'strFax',
            message: 'Not a valid fax number'
        }
    ]
});