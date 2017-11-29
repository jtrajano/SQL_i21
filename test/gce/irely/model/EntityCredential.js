Ext.define('iRely.model.EntityCredential', {
    extend: 'iRely.BaseEntity',
    alias: 'model.entitycredential',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intEntityCredentialId',

    fields: [
        {
            name: 'intEntityCredentialId',
            type: 'int'
        },
        {
            name: 'intEntityId',
            type: 'int',
            reference: {
                type: 'iRely.model.Entity',
                inverse: 'tblEntityCredentials'
            }
        },
        {
            name: 'strUserName',
            type: 'string'
        },
        {
            name: 'strPassword',
            type: 'string'
        }
    ]

});