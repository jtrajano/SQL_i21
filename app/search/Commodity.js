Ext.define('Inventory.search.Commodity', {
    alias: 'search.iccommodity',
    singleton: true,
    searchConfigs: [{
        title: 'Search Commodity',
        type: 'Inventory.Commodity',
        api: {
            read: '../Inventory/api/Commodity/Search'
        },
        columns: [
            { dataIndex: 'intCommodityId', text: "Commodity Id", flex: 1, defaultSort: true, dataType: 'numeric', key: true, hidden: true },
            { dataIndex: 'strCommodityCode', text: 'Commodity Code', flex: 1, dataType: 'string' },
            { dataIndex: 'strDescription', text: 'Description', flex: 1, dataType: 'string' }
        ]
    }]
});