Ext.define('Inventory.view.override.ManufacturingCellViewModel', {
    override: 'Inventory.view.ManufacturingCellViewModel',

    requires: [
        'i21.store.CompanyLocation',
        'Inventory.store.BufferedUnitMeasure'
    ],

    stores: {
        capacityUOM: {
            type: 'inventorybuffereduom'
        },
        capacityRateUOM: {
            type: 'inventorybuffereduom'
        },
        location: {
            type: 'companylocation'
        },
        packType: {
            type: 'inventorypacktype'
        },
        packTypeCapacityUOM: {
            type: 'inventorybuffereduom'
        },
        packTypeCapacityRateUOM: {
            type: 'inventorybuffereduom'
        }
    }
    
});