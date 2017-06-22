Ext.define('Inventory.model.CommodityGradeView', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intCommodityAttributeId',

    fields: [
        { name: 'intCommodityAttributeId', type: 'int'},
        { name: 'intCommodityId', type: 'int' },
        { name: 'strGrade', type: 'string'},
        { name: 'strCommodityCode', type: 'string' },
        { name: 'strCommodityDescription', type: 'string'}
    ]
});