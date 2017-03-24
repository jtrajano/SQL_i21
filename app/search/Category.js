Ext.define('Inventory.search.Category', {
    alias: 'search.iccategory',
    singleton: true,

    searchConfigs: [
        {
            title: 'Search Category',
            type: 'Inventory.Category',
            api: {
                read: '../Inventory/api/Category/Search'
            },
            columns: [
                { dataIndex: 'intCategoryId', text: "Category Id", flex: 1, defaultSort: true, dataType: 'numeric', key: true, hidden: true },
                { dataIndex: 'strCategoryCode', text: 'Category Code', flex: 1, dataType: 'string' },
                { dataIndex: 'strDescription', text: 'Description', flex: 1, dataType: 'string' },
                { dataIndex: 'strInventoryType', text: 'Inventory Type', flex: 1, dataType: 'string' }
            ]
        }
    ]
});