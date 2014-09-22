Ext.define('Inventory.view.override.PatronageCategoryViewModel', {
    override: 'Inventory.view.PatronageCategoryViewModel',

    stores: {
        PurchaseSales: {
            autoLoad: true,
            data: [
                {
                    strPurchaseSale: 'Purchase'
                },
                {
                    strPurchaseSale: 'Sale'
                }
            ],
            fields: [
                {
                    name: 'strPurchaseSale'
                }
            ]
        },
        UnitAmount:{
            autoLoad: true,
            data: [
                {
                    strUnitAmount: 'Unit'
                },
                {
                    strUnitAmount: 'Amount'
                }
            ],
            fields: [
                {
                    name: 'strUnitAmount'
                }
            ]
        }
    }

});