Ext.define('Inventory.view.override.FuelTaxClassViewModel', {
    override: 'Inventory.view.FuelTaxClassViewModel',

    requires: [
        'Inventory.store.FuelTaxClass'
    ],

    stores: {
        States: {
            autoLoad: true,
            data: [
                { strState: 'Alabama', strCode: 'AL' },
                { strState: 'Alaska', strCode: 'AK' },
                { strState: 'Arizona', strCode: 'AZ' },
                { strState: 'Arkansas', strCode: 'AR' },
                { strState: 'California', strCode: 'CA' },
                { strState: 'Colorado', strCode: 'CO' },
                { strState: 'Connecticut', strCode: 'CT' },
                { strState: 'Delaware', strCode: 'DE' },
                { strState: 'Florida', strCode: 'FL' },
                { strState: 'Georgia', strCode: 'GA' },
                { strState: 'Hawaii', strCode: 'HI' },
                { strState: 'Idaho', strCode: 'ID' },
                { strState: 'Illinois', strCode: 'IL' },
                { strState: 'Indiana', strCode: 'IN' },
                { strState: 'Iowa', strCode: 'IA' },
                { strState: 'Kansas', strCode: 'KS' },
                { strState: 'Kentucky', strCode: 'KY' },
                { strState: 'Louisiana', strCode: 'LA' },
                { strState: 'Maine', strCode: 'ME' },
                { strState: 'Maryland', strCode: 'MD' },
                { strState: 'Massachusetts', strCode: 'MA' },
                { strState: 'Michigan', strCode: 'MI' },
                { strState: 'Minnesota', strCode: 'MN' },
                { strState: 'Mississippi', strCode: 'MS' },
                { strState: 'Missouri', strCode: 'MO' },
                { strState: 'Montana', strCode: 'MT' },
                { strState: 'Nebraska', strCode: 'NE' },
                { strState: 'Nevada', strCode: 'NV' },
                { strState: 'New Hampshire', strCode: 'NH' },
                { strState: 'New Jersey', strCode: 'NJ' },
                { strState: 'New Mexico', strCode: 'NM' },
                { strState: 'New York', strCode: 'NY' },
                { strState: 'North Carolina', strCode: 'NC' },
                { strState: 'North Dakota', strCode: 'ND' },
                { strState: 'Ohio', strCode: 'OH' },
                { strState: 'Oklahoma', strCode: 'OK' },
                { strState: 'Oregon', strCode: 'OR' },
                { strState: 'Pennsylvania', strCode: 'PA' },
                { strState: 'Rhode Island', strCode: 'RI' },
                { strState: 'South Carolina', strCode: 'SC' },
                { strState: 'South Dakota', strCode: 'SD' },
                { strState: 'Tennessee', strCode: 'TN' },
                { strState: 'Texas', strCode: 'TX' },
                { strState: 'Utah', strCode: 'UT' },
                { strState: 'Vermont', strCode: 'VT' },
                { strState: 'Virginia', strCode: 'VA' },
                { strState: 'Washington', strCode: 'WA' },
                { strState: 'West Virginia', strCode: 'WV' },
                { strState: 'Wisconsin', strCode: 'WI' },
                { strState: 'Wyoming', strCode: 'WY' }
            ],
            fields: [
                {
                    name: 'strState'
                },
                {
                    name: 'strCode'
                }
            ]
        }
    }
    
});