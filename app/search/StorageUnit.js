Ext.define('Inventory.search.StorageUnit', {
    alias: 'search.icstorageunit',
    singleton: true,
    searchConfigs: [
        {
            title:  'Search Storage Locations',
            type: 'Inventory.StorageLocation',
            api: {
                read: '../Inventory/api/StorageLocation/Search'
            },
            columns: [
                {dataIndex: 'intStorageLocationId',text: "Storage Location Id", flex: 1, defaultSort:true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strName', text: 'Name', flex: 1,  dataType: 'string'},
                {dataIndex: 'strDescription', text: 'Description', flex: 1,  dataType: 'string'},
                {dataIndex: 'strStorageUnitType', text: 'Storage Unit Type', flex: 1,  dataType: 'string'},
                {dataIndex: 'strLocationName', text: 'Location', flex: 1,  dataType: 'string'},
                {dataIndex: 'strSubLocationName', text: 'Sub Location', flex: 1,  dataType: 'string'},
                {dataIndex: 'strParentStorageLocationName', text: 'Parent Unit', flex: 1.5,  dataType: 'string'},
                {dataIndex: 'strRestrictionCode', text: 'Restriction Type', flex: 1,  dataType: 'string'}
            ]
        }
    ]
});


        