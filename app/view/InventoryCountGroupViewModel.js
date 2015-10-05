Ext.define('Inventory.view.InventoryCountGroupViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icinventorycountgroup',

    requires: [

    ],

    stores: {
        inventoryTypes: {
            autoLoad: true,
            data: [
                {
                    intInventoryType: 2,
                    strInventoryType: 'Bundle'
                },
                {
                    intInventoryType: 1,
                    strInventoryType: 'Inventory'
                },
                {
                    intInventoryType: 3,
                    strInventoryType: 'Kit'
                },
                {
                    intInventoryType: 4,
                    strInventoryType: 'Finished Good'
                },
                {
                    intInventoryType: 5,
                    strInventoryType: 'Non-Inventory'
                },
                {
                    intInventoryType: 6,
                    strInventoryType: 'Other Charge'
                },
                {
                    intInventoryType: 7,
                    strInventoryType: 'Raw Material'
                },
                {
                    intInventoryType: 8,
                    strInventoryType: 'Service'
                },
                {
                    intInventoryType: 9,
                    strInventoryType: 'Software'
                }
            ],
            fields: {
                name: 'intInventoryType',
                name: 'strInventoryType'
            }
        }
    }

});