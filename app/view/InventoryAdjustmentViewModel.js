Ext.define('Inventory.view.InventoryAdjustmentViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icinventoryadjustment',

    requires: [
        'i21.store.CompanyLocationBuffered'
    ],

    stores: {
        location: {
            type: 'companylocationbuffered'
        },
        adjustmentTypes: {
            data: [
                {
                    intAdjustmentTypeId : '1',
                    strDescription: 'Quantity Change'
                },{
                    intAdjustmentTypeId : '2',
                    strDescription: 'UOM Change'
                },{
                    intAdjustmentTypeId : '3',
                    strDescription: 'Item Change'
                },{
                    intAdjustmentTypeId : '4',
                    strDescription: 'Lot Status Change'
                },{
                    intAdjustmentTypeId : '5',
                    strDescription: 'Lot Id Change'
                },{
                    intAdjustmentTypeId : '6',
                    strDescription: 'Expiry Date Change'
                }
            ],
            fields: [
                {
                    type: 'int',
                    name: 'intAdjustmentTypeId'
                },
                {
                    name: 'strDescription'
                }
            ]
        }
    },

    formulas: {

    }

});