Ext.define('Inventory.model.FiscalPeriod', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intGLFiscalYearPeriodId',
    fields: [
        { name: 'intGLFiscalYearPeriodId', type: 'int' },
        { name: 'strFiscalYear', type: 'string' },
        { name: 'strPeriod', type: 'string' },
        { name: 'dtmStartDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'dtmEndDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'ysnOpen', type: 'boolean' },
        { name: 'ysnINVOpen', type: 'boolean' },
        { name: 'ysnStatus', type: 'boolean' },
        { name: 'intFiscalYearId', type: 'int' },
        { name: 'intStartMonth', type: 'int' },
        { name: 'strStartMonth', type: 'string' },
        { name: 'intEndMonth', type: 'int' },
        { name: 'strEndMonth', type: 'string' }
    ]
});