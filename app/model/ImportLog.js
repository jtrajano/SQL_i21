Ext.define('Inventory.model.ImportLog', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field',
        'Inventory.model.ImportLogDetail'
    ],

    idProperty: 'intImportLogId',

    fields: [
        { name: 'intImportLogId', type: 'int'},
        { name: 'strDescription', type: 'string' },
        { name: 'intTotalRows', type: 'int', allowNull: true },
        { name: 'intRowsImported', type: 'int', allowNull: true },
        { name: 'intTotalErrors', type: 'int', allowNull: true },
        { name: 'intTotalWarnings', type: 'int', allowNull: true },
        { name: 'dblTimeSpentInSeconds', type: 'float', allowNull: true },
        { name: 'intUserEntityId', type: 'int', allowNull: true },
        { name: 'strType', type: 'string' },
        { name: 'strFileType', type: 'string' },
        { name: 'strFileName', type: 'string' },
        { name: 'dtmDateImported', type: 'date', allowNull: true },
        { name: 'ysnAllowDuplicates', type: 'boolean' },
        { name: 'ysnAllowOverwriteOnImport', type: 'boolean' },
        { name: 'strLineOfBusiness', type: 'string' },
        { name: 'ysnContinueOnFailedImports', type: 'boolean' },
    ],

    validators: [
        {type: 'presence', field: 'intImportLogId'}
    ]
});
