Ext.define('Inventory.model.ItemSubstitute', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemSubstituteId',

    fields: [
        { name: 'intItemSubstituteId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemSubstitutes',
                    storeConfig: {
                        remoteFilter: true,
                        complete: true, 
                        proxy: {
                            type: 'rest',
                            api: {
                                read: './inventory/api/item/searchsubstitutes'
                            },
                            reader: {
                                type: 'json',
                                rootProperty: 'data',
                                messageProperty: 'message'
                            }
                        },
                        sortOnLoad: true
                    }
                }
            }},
        { name: 'intSubstituteItemId', type: 'int' },
        { name: 'dblQuantity', type: 'float', defaultValue: 1.00 },
        { name: 'dblMarkUpOrDown', type: 'float', defaultValue: 1.00 },
        { name: 'dtmBeginDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'dtmEndDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },       
        { name: 'intItemUOMId', type: 'int', allowNull: true },
        { name: 'strSubstituteItemNo', type: 'string' },
        { name: 'strUnitMeasure', type: 'string' },
        { name: 'strDescription', type: 'string' }
    ],

    validators: [
        {type: 'presence', field: 'strSubstituteItemNo', auditKey: true},
        {type: 'presence', field: 'strUnitMeasure'}
    ]
});