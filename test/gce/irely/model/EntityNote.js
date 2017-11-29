Ext.define('iRely.model.EntityNote', {
    extend: 'iRely.BaseEntity',
    alias: 'model.entitynote',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intEntityNoteId',

    fields: [
        {
            name: 'intEntityNoteId',
            type: 'int'
        },
        {
            name: 'intEntityId',
            type: 'int',
            reference: {
                type: 'iRely.model.Entity',
                role: 'tblEntity',
                inverse: 'tblEntityNotes'
            }
        },
        {
            name: 'dtmDate',
            type: 'date',
            dateFormat: 'c'
        },
        {
            name: 'dtmTime',
            type: 'date',
            dateFormat: 'c'
        },
        {
            name: 'intDuration',
            type: 'int',
            allowNull: true
        },
        {
            name: 'strUser',
            type: 'string'
        },
        {
            name: 'strSubject',
            type: 'string'
        },
        {
            name: 'strNote',
            mapping: 'strNotes',
            type: 'string'
        }
    ],

    validators: [
        {
            type: 'presence',
            field: 'dtmDate',
            message: 'This field is required'
        },
        {
            type: 'presence',
            field: 'dtmTime',
            message: 'This field is required'
        }
    ]

});