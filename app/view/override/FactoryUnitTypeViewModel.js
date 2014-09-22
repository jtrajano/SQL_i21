Ext.define('Inventory.view.override.FactoryUnitTypeViewModel', {
    override: 'Inventory.view.FactoryUnitTypeViewModel',

    stores: {
        internalCodes: {
            data: [
                {
                    strInternalCode: 'MACHINES'
                },
                {
                    strInternalCode: 'PROD_STAGING'
                },
                {
                    strInternalCode: 'STAGING'
                },
                {
                    strInternalCode: 'STORAGE'
                },
                {
                    strInternalCode: 'WH_AISLE'
                },
                {
                    strInternalCode: 'WH_ASN_LOCATION'
                },
                {
                    strInternalCode: 'WH_BUILDING'
                },
                {
                    strInternalCode: 'WH_BULK'
                },
                {
                    strInternalCode: 'WH_CASE_PICK'
                },
                {
                    strInternalCode: 'WH_DOCK_DOOR'
                },
                {
                    strInternalCode: 'WH_FG_STORAGE'
                },
                {
                    strInternalCode: 'WH_FLOOR_RESERVE'
                },
                {
                    strInternalCode: 'WH_INVOICE_LOCATION'
                },
                {
                    strInternalCode: 'WH_KIT_CONSTRUCTION'
                },
                {
                    strInternalCode: 'WH_RACK_RESERVE'
                },
                {
                    strInternalCode: 'WH_RESERVED_BY_SYSTEM'
                },
                {
                    strInternalCode: 'WH_RM_STORAGE'
                },
                {
                    strInternalCode: 'WH_ROOM'
                },
                {
                    strInternalCode: 'WH_Staging'
                },
                {
                    strInternalCode: 'WH_TRANSPORT'
                }
            ],
            fields: [
                {
                    name: 'strInternalCode'
                }
            ]
        }
    }
});