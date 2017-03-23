Ext.define('Inventory.search.InventoryUOM', {
    alias: 'search.icinventoryuom',
    singleton: true,
    searchConfigs: [
        {
            title:  'Search Inventory UOMs',
            type: 'Inventory.InventoryUOM',
            api: {
                read: '../Inventory/api/UnitMeasure/Search'
            },
            columns: [
                {dataIndex: 'intUnitMeasureId',text: "UOM Id", flex: 1, defaultSort:true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strUnitMeasure', text: 'UOM Name', flex: 2,  dataType: 'string'},
                {dataIndex: 'strSymbol', text: 'Symbol', flex: 1,  dataType: 'string'},
                {dataIndex: 'strUnitType', text: 'Unit Type', flex: 2,  dataType: 'string'},
                {dataIndex: 'intDecimalPlaces', text: 'Decimals', flex: 1, dataType: 'int' }
            ]
        }
    ]
});


        