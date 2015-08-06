/**
 * Created by LZabala on 9/29/2014.
 */
Ext.define('Inventory.model.Commodity', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.CommodityUnitMeasure',
        'Inventory.model.CommodityAccount',
        'Inventory.model.CommodityClass',
        'Inventory.model.CommodityGrade',
        'Inventory.model.CommodityOrigin',
        'Inventory.model.CommodityProductLine',
        'Inventory.model.CommodityProductType',
        'Inventory.model.CommodityRegion',
        'Inventory.model.CommoditySeason',
        'Ext.data.Field'
    ],

    idProperty: 'intCommodityId',

    fields: [
        { name: 'intCommodityId', type: 'int' },
        { name: 'strCommodityCode', type: 'string' },
        { name: 'strDescription', type: 'string' },
        { name: 'ysnExchangeTraded', type: 'boolean' },
        { name: 'intFutureMarketId', type: 'int', allowNull: true },
        { name: 'intDecimalDPR', type: 'int', allowNull: true },
        { name: 'dblConsolidateFactor', type: 'float' },
        { name: 'ysnFXExposure', type: 'boolean' },
        { name: 'dblPriceCheckMin', type: 'float' },
        { name: 'dblPriceCheckMax', type: 'float' },
        { name: 'strCheckoffTaxDesc', type: 'string' },
        { name: 'strCheckoffAllState', type: 'string' },
        { name: 'strInsuranceTaxDesc', type: 'string' },
        { name: 'strInsuranceAllState', type: 'string' },
        { name: 'dtmCropEndDateCurrent', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'dtmCropEndDateNew', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'strEDICode', type: 'string' },
        { name: 'intScheduleStoreId', type: 'int', allowNull: true },
        { name: 'intScheduleDiscountId', type: 'int', allowNull: true },
        { name: 'intScaleAutoDistId', type: 'int', allowNull: true },
        { name: 'ysnAllowLoadContracts', type: 'boolean' },
        { name: 'dblMaxUnder', type: 'float' },
        { name: 'dblMaxOver', type: 'float' },
        { name: 'intPatronageCategoryId', type: 'int', allowNull: true },
        { name: 'intPatronageCategoryDirectId', type: 'int', allowNull: true }
    ],

    validators: [
        {type: 'presence', field: 'strCommodityCode'}
    ]
});