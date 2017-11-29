Ext.define('iRely.model.EntityToContact', {
    extend: 'iRely.BaseEntity',
    alias: 'model.entitytocontact',

    requires: [
        'Ext.data.Field'
    ],
    uses: [
        'iRely.model.EntityContact',
        'iRely.model.EntityLocation'
    ],

    idProperty: 'intEntityToContactId',

    fields: [
        {
            name: 'intEntityToContactId',
            type: 'int'
        },
        {
            name: 'intEntityId',
            type: 'int',
            allowNull: true
        },
        {
            name: 'intContactId',
            type: 'int',
            allowNull: true
        },
        {
            name: 'intLocationId',
            type: 'int',
            allowNull: true
        }
    ]
});