Ext.define('Inventory.view.BuildAssemblyBlendViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icbuildassemblyblend',

    requires: [
        'Inventory.store.BufferedAssemblyItem',
        'Inventory.store.BufferedItemUnitMeasure',
        'i21.store.CompanyLocationBuffered',
        'i21.store.CompanyLocationSubLocationBuffered'
    ],

    stores: {
        item:{
            type: 'icbufferedassemblyitem'
        },
        itemUOM:{
            type: 'icbuffereditemunitmeasure'
        },
        location:{
            type: 'companylocationbuffered'
        },
        subLocation: {
            type: 'smcompanylocationsublocationbuffered'
        }
    },

    formulas: {

    }

});