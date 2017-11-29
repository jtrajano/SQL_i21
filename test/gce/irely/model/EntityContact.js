Ext.define('iRely.model.EntityContact', {
    extend: 'iRely.model.Entity',
    alias: 'model.entitycontact',

    requires: [
        'Ext.data.Field',
        'iRely.model.EntityToContact'
    ],

    idProperty: 'intContactId',

    fields: [
        {
            name: 'intEntityId',
            type: 'int'
        },
        {
            name: 'intContactId',
            type: 'int'
        },
        {
            name: 'strContactName',
            mapping: 'strName',
            type: 'string'
        },
        {
            name: 'strName',
            persist: false,
            type: 'string'
        },
        {
            name: 'strContactNumber',
            type: 'string'
        },
        {
            name: 'strTitle',
            type: 'string'
        },
        {
            name: 'strDepartment',
            type: 'string'
        },
        {
            name: 'strMobile',
            type: 'string'
        },
        {
            mapping: 'strPhone',
            name: 'strContactPhone',
            type: 'string',
            allowNull: true
        },
        {
            mapping: 'strEmail',
            name: 'strContactEmail',
            type: 'string'
        },
        {
            name: 'strPhone2',
            type: 'string'
        },
        {
            name: 'strEmail2',
            type: 'string'
        },
        {
            mapping: 'strFax',
            name: 'strContactFax',
            type: 'string',
            allowNull: true
        },
        {
            name: 'strNotes',
            type: 'string'
        },
        {
            name: 'strContactMethod',
            type: 'string'
        },
        {
            name: 'strTimezone',
            type: 'string'
        },
        {
            name: 'strContactLocationName',
            mapping: 'strLocationName',
            type: 'string'
        },
        {
            name: 'ysnContactActive',
            mapping: 'ysnActive',
            type: 'boolean'
        },
        {
            name: 'intContactEntityId',
            type: 'string'
        },
        //Not Mapped
        {
            name: 'ysnPortalAccess',
            //persist: false,
            type: 'boolean'
        },
        {
            name: 'strUserType',
            //persist: false,
            type: 'string'
        }
    ],

    validators: [
        {
            type: 'presence',
            field: 'strContactName',
            message: 'This field is required'
        },
        {
            type: 'optionalEmail',
            field: 'strContactEmail',
            message: 'This field should be an e-mail address in the format "user@example.com"'
        },
        {
            type: 'optionalEmail',
            field: 'strEmail2',
            message: 'This field should be an e-mail address in the format "user@example.com"'
        },
        {
            type: 'optionalPhone',
            field: 'strPhone'
        },
        {
            type: 'optionalPhone',
            field: 'strPhone2'
        }
    ]
//    ,
//
//    hasMany: [
//        {
//            model: 'iRely.model.EntityToContact',
//            primaryKey: 'intEntityId',
//            foreignKey: 'intContactId',
//            name: 'tblEntityToContacts_Contacts'
//        }
//    ]
}, function() {
    //This is use to pass the data and association from tblEntityCredential to tblEntityContact since tblEntityContact uses intContactId as its idProperty
    var record = this;
    record.associations.tblEntityCredentials = iRely.model.Entity.prototype.associations.tblEntityCredentials;

});