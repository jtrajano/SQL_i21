Ext.define('iRely.model.Entity', {
    extend: 'iRely.BaseEntity',

    requires: [
        'iRely.model.EntityLocation',
        'iRely.model.EntityToContact',
        'iRely.model.EntityNote',
        'iRely.model.EntityCredential'
    ],

    idProperty: 'intEntityId',

    fields: [
        {
            name: 'intEntityId',
            type: 'int'
        },
        {
            name: 'strName',
            type: 'string'
        },
        {
            name: 'strEmail',
            type: 'string'
        },
        {
            name: 'strWebsite',
            type: 'string'
        },
        {
            name: 'strInternalNotes',
            type: 'string'
        },
        {
            name: 'ysnPrint1099',
            type: 'boolean'
        },
        {
            name: 'str1099Name',
            type: 'string'
        },
        {
            name: 'str1099Form',
            type: 'string'
        },
        {
            name: 'str1099Type',
            type: 'string'
        },
        {
            name: 'strFederalTaxId',
            type: 'string'
        },
        {
            name: 'dtmW9Signed',
            type: 'date',
            dateFormat: 'c'
        },
        {
            name: 'imgPhoto',
            type: 'string'
        }
    ],

    validators: [
//        {
//            type: 'url',
//            field: 'strWebsite'
//        }
    ]
});