Ext.define('Inventory.search.FuelType', {
    alias: 'search.icfueltype',
    singleton: true,
    searchConfigs: [
        {
            title:  'Search Fuel Type',
            type: 'Inventory.FuelType',
            api: {
                read: '../Inventory/api/FuelType/Search'
            },
            columns: [
                {dataIndex: 'intFuelTypeId',text: "Fuel Type", flex: 1, defaultSort:true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strRinFuelTypeCodeId', text: 'Fuel Type', flex: 1,  dataType: 'string'},
                {dataIndex: 'strRinFeedStockId', text: 'Feed Stock', flex: 1,  dataType: 'string'},
                {dataIndex: 'strRinFuelId', text: 'Fuel Code', flex: 1,  dataType: 'string'},
                {dataIndex: 'strRinProcessId', text: 'Process Code', flex: 1,  dataType: 'string'}
            ],
            buttons: [
                {
                    text: 'Fuel Category',
                    itemId: 'btnFuelCategory',
                    clickHandler: 'onFuelCategoryDrilldown',
                    width: 100
                },
                {
                    text: 'Feed Stock',
                    itemId: 'btnFeedStock',
                    clickHandler: 'onFeedStockDrilldown',
                    width: 100
                },
                {
                    text: 'Fuel Code',
                    itemId: 'btnFuelCode',
                    clickHandler: 'onFuelCodeDrilldown',
                    width: 100
                },
                {
                    text: 'Production Process',
                    itemId: 'btnProductionProcess',
                    clickHandler: 'onProductionProcessDrilldown',
                    width: 100
                },
                {
                    text: 'Feed Stock UOM',
                    itemId: 'btnFeedStockUOM',
                    clickHandler: 'onFeedStockUomDrilldown',
                    width: 100
                }
            ]
        }
    ],

    //Drilldown functions
    onFuelCategoryDrilldown: function() {
        iRely.Functions.openScreen('Inventory.view.FuelCategory', {viewConfig: { modal: true }});
    },

    onFeedStockDrilldown: function() {
        iRely.Functions.openScreen('Inventory.view.FeedStockCode', {viewConfig: { modal: true }});
    },

    onFuelCodeDrilldown: function() {
        iRely.Functions.openScreen('Inventory.view.FuelCode', {viewConfig: { modal: true }});
    },

    onProductionProcessDrilldown: function() {
        iRely.Functions.openScreen('Inventory.view.ProcessCode', {viewConfig: { modal: true }});
    },

    onFeedStockUomDrilldown: function() {
        iRely.Functions.openScreen('Inventory.view.FeedStockUom', {viewConfig: { modal: true }});
    }
});


        