/**
 * Created by LZabala on 7/3/2015.
 */
Ext.define('Inventory.model.CompanyPreference', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intCompanyPreferenceId',

    fields: [
        { name: 'intCompanyPreferenceId', type: 'int'},
        { name: 'intInheritSetup', type: 'int'},
        { name: 'intSort', type: 'int'},
        { name: 'strLotCondition', type: 'string'},
        { name: 'strReceiptType', type: 'string'},
        { name: 'intReceiptSourceType', type: 'int', allowNull: true},
        { name: 'intShipmentOrderType', type: 'int', allowNull: true},
        { name: 'intShipmentSourceType', type: 'int', allowNull: true}
    ]
});