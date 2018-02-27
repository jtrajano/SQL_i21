Ext.define('GlobalComponentEngine.model.MultiCompany', {

    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intMultiCompanyId',

    fields: [
        {
            name: 'intMultiCompanyId',
            type: 'int'
        },
        {
            name: 'strCompanyName',
            type: 'string'
        },
        {
            name: 'strDatabaseName',
            type: 'string'
        },
        {
            name: 'strServer',
            type: 'string'
        },
        {
            name: 'strAuthentication',
            type: 'string'
        },
        {
            name: 'strUserName',
            type: 'string'
        },
        {
            name: 'strPassword',
            type: 'string'
        },
        {
            name: 'strType',
            type: 'string'
        },
        {
            name: 'intMultiCompanyParentId',
            type: 'int',
            allowNull: true,
            reference: {
                type: 'GlobalComponentEngine.model.MultiCompany',
                role: 'parent',
                inverse: {
                    role: 'tblSMMultiCompanies',
                    storeConfig: {
                        complete: true,
                        sortOnLoad: true,
                        sorters: [
                            {
                                property: 'intMultiCompanyId',
                                direction: 'ASC'
                            }
                        ]
                    }
                }
            }
        }
    ]
});