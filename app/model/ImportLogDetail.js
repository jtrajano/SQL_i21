Ext.define('Inventory.model.ImportLogDetail', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intImportLogIdDetail',

    fields: [
        { name: 'intImportLogIdDetail', type: 'int'},
        { name: 'intImportLogId', type: 'int',
            reference: {
                type: 'Inventory.model.ImportLog',
                inverse: {
                    role: 'tblICImportLogDetails',
                    storeConfig: {
                        proxy: {
                            api: {
                                read: './inventory/api/importlogdetail/searchimportlogdetails'
                            },
                            type: 'rest',
                            reader: {
                                type: 'json',
                                rootProperty: 'data',
                                messageProperty: 'message'
                            }
                        },
                        complete: true,
                        sortOnLoad: true,
                        sorters: {
                            direction: 'DESC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'strType', type: 'string' },
        { name: 'intRecordNo', type: 'int', allowNull: true },
        { name: 'strField', type: 'string' },
        { name: 'strValue', type: 'string' },
        { name: 'strMessage', type: 'string' },
        { name: 'strStatus', type: 'string' },
        { name: 'strAction', type: 'string' }
    ],

    validators: [
        {type: 'presence', field: 'intImportLogIdDetail'},
        {type: 'presence', field: 'intImportLogId'}
    ]
});
