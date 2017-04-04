Ext.define('Inventory.search.Item', {
    alias: 'search.icitem',
    singleton: true,

    searchConfigs: [
        {
            title: 'Search Items',
            type: 'Inventory.Item',
            api: {
                read: '../Inventory/api/Item/Search'
            },
            columns: [
                { dataIndex: 'intItemId', text: "Item Id", flex: 1, dataType: 'numeric', key: true, hidden: true },
                { dataIndex: 'strItemNo', text: 'Item No', flex: 1, defaultSort: true, sortOrder: 'ASC', dataType: 'string', minWidth: 150 },
                { dataIndex: 'strType', text: 'Type', flex: 1, dataType: 'string', minWidth: 150 },
                { dataIndex: 'strDescription', text: 'Description', flex: 1, dataType: 'string', minWidth: 250 },
                { dataIndex: 'strStatus', text: 'Status', flex: 1, dataType: 'string', minWidth: 150 },
                { dataIndex: 'strTracking', text: 'Inv Valuation', flex: 1, dataType: 'string', minWidth: 150 },
                { dataIndex: 'strLotTracking', text: 'Lot Tracking', flex: 1, dataType: 'string', minWidth: 150 },
                { dataIndex: 'strCategory', text: 'Category', flex: 1, dataType: 'string', minWidth: 150 },
                { dataIndex: 'strCommodity', text: 'Commodity', flex: 1, dataType: 'string', minWidth: 150 },
                { dataIndex: 'strManufacturer', text: 'Manufacturer', flex: 1, dataType: 'string', minWidth: 150 },
                { dataIndex: 'strBrandCode', text: 'Brand', flex: 1, dataType: 'string', minWidth: 150 },
                { dataIndex: 'strModelNo', text: 'Model No', flex: 1, dataType: 'string', minWidth: 150 }
            ]
        },
        {
            title: 'Locations',
            api: {
                read: '../Inventory/api/ItemLocation/SearchItemLocationViews'
            },
            columns: [

                { dataIndex: 'intItemLocationId', text: 'Item Location Id', width: 100, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', hidden: true },
                { dataIndex: 'intItemId', text: 'Item Id', width: 100, dataType: 'numeric', key: true, hidden: true },
                { dataIndex: 'strItemNo', text: 'Item No', width: 150, dataType: 'string' },
                { dataIndex: 'strItemDescription', text: 'Item Description', width: 150, dataType: 'string' },
                { dataIndex: 'intLocationId', text: 'Location Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strLocationName', text: 'Location Name', width: 200, dataType: 'string' },
                { dataIndex: 'intVendorId', text: 'Vendor Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strVendorId', text: 'Vendor Id', width: 100, dataType: 'string' },
                { dataIndex: 'strVendorName', text: 'Vendor Name', width: 100, dataType: 'string' },
                { dataIndex: 'strDescription', text: 'Description', width: 100, dataType: 'string' },
                { dataIndex: 'intCostingMethod', text: 'Costing Method', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strCostingMethod', text: 'Costing Method', width: 120, dataType: 'string' },
                { dataIndex: 'intAllowNegativeInventory', text: 'Allow Negative Inventory', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strAllowNegativeInventory', text: 'Allow Negative Inventory', width: 150, dataType: 'string' },
                { dataIndex: 'intSubLocationId', text: 'Storage Location Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strSubLocationName', text: 'Storage Location', width: 120, dataType: 'string' },
                { dataIndex: 'intStorageLocationId', text: 'Storage Unit Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strStorageLocationName', text: 'Storage Unit', width: 120, dataType: 'string' },
                { dataIndex: 'intIssueUOMId', text: 'Issue UOM Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strIssueUOM', text: 'Issue UOM', width: 100, dataType: 'string' },
                { dataIndex: 'intReceiveUOMId', text: 'Receive UOM Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strReceiveUOM', text: 'Receive UOM', width: 100, dataType: 'string' },
                { dataIndex: 'intFamilyId', text: 'Family Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strFamily', text: 'Family', width: 100, dataType: 'string', hidden: true },
                { dataIndex: 'intClassId', text: 'Class Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strClass', text: 'Class', width: 100, dataType: 'string', hidden: true },
                { dataIndex: 'intProductCodeId', text: 'Product Code Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strRegProdCode', text: 'Product Code', width: 100, dataType: 'string', hidden: true },
                { dataIndex: 'strPassportFuelId1', text: 'Passport Fuel Id 1', width: 100, dataType: 'string', hidden: true },
                { dataIndex: 'strPassportFuelId2', text: 'Passport Fuel Id 2', width: 100, dataType: 'string', hidden: true },
                { dataIndex: 'strPassportFuelId3', text: 'Passport Fuel Id 3', width: 100, dataType: 'string', hidden: true },
                { dataIndex: 'ysnTaxFlag1', text: 'Tax Flag 1', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'ysnTaxFlag2', text: 'Tax Flag 2', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'ysnTaxFlag3', text: 'Tax Flag 3', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'ysnTaxFlag4', text: 'Tax Flag 4', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'ysnPromotionalItem', text: 'Promotional Item', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'intMixMatchId', text: 'Mix Match Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strPromoItemListId', text: 'PromoItemListId', width: 100, dataType: 'string', hidden: true },
                { dataIndex: 'ysnDepositRequired', text: 'Deposit Required', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'intDepositPLUId', text: 'Deposit PLU Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strDepositPLU', text: 'Deposit PLU', width: 100, dataType: 'string', hidden: true },
                { dataIndex: 'intBottleDepositNo', text: 'Bottle Deposit No', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'ysnSaleable', text: 'Saleable', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'ysnQuantityRequired', text: 'Quantity Required', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'ysnScaleItem', text: 'Scale Item', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'ysnFoodStampable', text: 'Food Stampable', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'ysnReturnable', text: 'Returnable', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'ysnPrePriced', text: 'PrePriced', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'ysnOpenPricePLU', text: 'Open Price PLU', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'ysnLinkedItem', text: 'Linked Item', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'strVendorCategory', text: 'Vendor Category', width: 100, dataType: 'string', hidden: true },
                { dataIndex: 'ysnCountBySINo', text: 'Count By SI No', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'strSerialNoBegin', text: 'Serial No Begin', width: 100, dataType: 'string', hidden: true },
                { dataIndex: 'strSerialNoEnd', text: 'Serial No End', width: 100, dataType: 'string', hidden: true },
                { dataIndex: 'ysnIdRequiredLiquor', text: 'Id Required Liquor', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'ysnIdRequiredCigarette', text: 'Id Required Cigarette', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'intMinimumAge', text: 'Minimum Age', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'ysnApplyBlueLaw1', text: 'Apply Blue Law 1', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'ysnApplyBlueLaw2', text: 'Apply Blue Law 2', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'ysnCarWash', text: 'Car Wash', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'intItemTypeCode', text: 'Item Type Code Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strItemTypeCode', text: 'Item Type Code', width: 100, dataType: 'string', hidden: true },
                { dataIndex: 'intItemTypeSubCode', text: 'Item Type Sub Code', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'ysnAutoCalculateFreight', text: 'Auto Calculate Freight', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'intFreightMethodId', text: 'Freight Method Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strFreightTerm', text: 'Freight Term', width: 100, dataType: 'string', hidden: true },
                { dataIndex: 'dblFreightRate', text: 'Freight Rate', width: 100, dataType: 'float', xtype: 'numbercolumn', hidden: true },
                { dataIndex: 'intShipViaId', text: 'Ship Via Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strShipVia', text: 'Ship Via', width: 100, dataType: 'string', hidden: true },
                { dataIndex: 'dblReorderPoint', text: 'Reorder Point', width: 100, dataType: 'float', xtype: 'numbercolumn', hidden: true },
                { dataIndex: 'dblMinOrder', text: 'Min Order', width: 100, dataType: 'float', xtype: 'numbercolumn', hidden: true },
                { dataIndex: 'dblSuggestedQty', text: 'Suggested Qty', width: 100, dataType: 'float', xtype: 'numbercolumn', hidden: true },
                { dataIndex: 'dblLeadTime', text: 'Lead Time', width: 100, dataType: 'float', xtype: 'numbercolumn', hidden: true },
                { dataIndex: 'strCounted', text: 'Counted', width: 100, dataType: 'string', hidden: true },
                { dataIndex: 'intCountGroupId', text: 'Count Group Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strCountGroup', text: 'Count Group', width: 100, dataType: 'string', hidden: true },
                { dataIndex: 'ysnCountedDaily', text: 'Counted Daily', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'ysnLockedInventory', text: 'Locked Inventory', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'intSort', text: 'Sort', width: 100, dataType: 'numeric', hidden: true }
            ],
            customControl: [
                {
                    xtype: 'button',
                    text: 'Copy Location',
                    itemId: 'btnCopyLocation',
                    iconCls: 'small-import',
                    listeners: {
                        click: function (e) {
                            iRely.Functions.openScreen('Inventory.view.CopyItemLocation');
                        }
                    }
                }
            ]
        },
        {
            title: 'Pricing',
            api: {
                read: '../Inventory/api/ItemPricing/SearchItemStockPricingViews'
            },
            columns: [
                { dataIndex: 'intPricingKey', text: 'Pricing Key', width: 100, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', hidden: true },
                { dataIndex: 'strItemNo', text: 'Item No', width: 100, dataType: 'string' },
                { dataIndex: 'strDescription', text: 'Description', width: 100, dataType: 'string' },
                { dataIndex: 'strVendorId', text: 'Vendor Id', width: 100, dataType: 'string', hidden: true },
                { dataIndex: 'strVendorName', text: 'Vendor Name', width: 100, dataType: 'string', hidden: true },
                { dataIndex: 'strUpcCode', text: 'Upc Code', width: 100, dataType: 'string' },
                { dataIndex: 'strLongUPCCode', text: 'Long UPC Code', width: 100, dataType: 'string' },
                { dataIndex: 'intItemId', text: 'Item Id', width: 100, dataType: 'numeric', key: true, hidden: true },

                { dataIndex: 'strLocationName', text: 'Location Name', width: 100, dataType: 'string' },
                { dataIndex: 'strLocationType', text: 'Location Type', width: 100, dataType: 'string', hidden: true },
                { dataIndex: 'strUnitMeasure', text: 'Unit Measure', width: 100, dataType: 'string' },
                { dataIndex: 'strUnitType', text: 'Unit Type', width: 100, dataType: 'string', hidden: true },
                { dataIndex: 'ysnStockUnit', text: 'Stock Unit', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'ysnAllowPurchase', text: 'Allow Purchase', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'ysnAllowSale', text: 'Allow Sale', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                // {dataIndex: 'dblUnitQty', text: 'Unit Qty', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'dblAmountPercent', text: 'Amount/Percent', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'dblSalePrice', text: 'Sale Price', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'dblMSRPPrice', text: 'MSRP Price', width: 100, dataType: 'float', xtype: 'numbercolumn', hidden: true },
                { dataIndex: 'strPricingMethod', text: 'Pricing Method', width: 100, dataType: 'string' },
                { dataIndex: 'dblLastCost', text: 'Last Cost', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'dblStandardCost', text: 'Standard Cost', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'dblAverageCost', text: 'Average Cost', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'dblEndMonthCost', text: 'End Month Cost', width: 100, dataType: 'float', xtype: 'numbercolumn', hidden: true },
                { dataIndex: 'intSort', text: 'Sort', width: 100, dataType: 'numeric', hidden: true }
            ]
        },
        {
            title: 'Item UOM',
            api: {
                read: '../Inventory/api/ItemUOM/SearchUOMs'
            },
            columns: [
                { dataIndex: 'intItemUOMId', text: 'Item UOM Id', width: 100, flex: 1, dataType: 'numeric', hidden: true },
                { dataIndex: 'intItemId', text: 'Item Id', width: 100, flex: 1, dataType: 'numeric', key: true, hidden: true },
                { dataIndex: 'intItemUOMId', text: 'Item UOM Id', width: 100, flex: 1, dataType: 'numeric', hidden: true },
                { dataIndex: 'strItemNo', text: 'Item No', width: 100, flex: 1, dataType: 'string', defaultSort: true, sortOrder: 'ASC' },
                { dataIndex: 'strItemDescription', text: 'Item Description', width: 100, flex: 1, dataType: 'string' },
                { dataIndex: 'strType', text: 'Item Type', width: 100, flex: 1, dataType: 'string' },
                { dataIndex: 'intItemId', text: 'Item Id', width: 100, flex: 1, dataType: 'numeric', hidden: true },
                { dataIndex: 'strCategory', text: 'Category', width: 100, flex: 1, dataType: 'string' },
                { dataIndex: 'strCategoryCode', text: 'Category Code', width: 100, flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'intCategoryId', text: 'Category Id', width: 100, flex: 1, dataType: 'numeric', hidden: true },
                { dataIndex: 'strCommodity', text: 'Commodity', width: 100, flex: 1, dataType: 'string' },
                { dataIndex: 'strCommodityCode', text: 'Commodity Code', width: 100, flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'intCommodityId', text: 'Commodity Id', width: 100, flex: 1, dataType: 'numeric', hidden: true },
                { dataIndex: 'strUnitMeasure', text: 'Unit Measure', width: 100, flex: 1, dataType: 'string' },
                { dataIndex: 'strStockUOM', text: 'Stock UOM', width: 100, flex: 1, dataType: 'string' },
                { dataIndex: 'ysnStockUnit', text: 'Is Stock Unit', xtype: 'checkcolumn', width: 100, flex: 1, dataType: 'string' },
                { dataIndex: 'ysnAllowPurchase', text: 'Allow Purchase', xtype: 'checkcolumn', width: 100, flex: 1, dataType: 'boolean' },
                { dataIndex: 'ysnAllowSale', text: 'Allow Sale', xtype: 'checkcolumn', width: 100, flex: 1, dataType: 'boolean' },
                { dataIndex: 'dblMaxQty', text: 'Max Qty', width: 100, flex: 1, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'dblUnitQty', text: 'Unit Qty', width: 100, flex: 1, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'dblHeight', text: 'Height', hidden: true, width: 100, flex: 1, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'dblLength', text: 'Length', hidden: true, width: 100, flex: 1, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'dblWeight', text: 'Weight', hidden: true, width: 100, flex: 1, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'dblVolume', text: 'Volume', hidden: true, width: 100, flex: 1, dataType: 'float', xtype: 'numbercolumn' }
            ]
        }
    ],
    buttons: [
        {
            text: 'Categories',
            itemId: 'btnCategory',
            clickHandler: 'onCategoryClick',
            width: 100
        },
        {
            text: 'Commodities',
            itemId: 'btnCommodity',
            clickHandler: 'onCommodityClick',
            width: 100
        },
        {
            text: 'Inventory UOM',
            itemId: 'btnInventoryUOM',
            clickHandler: 'onInventoryUOMClick',
            width: 100
        },
        {
            text: 'Lot Status',
            itemId: 'btnLotStatus',
            clickHandler: 'onLotStatusClick',
            width: 100
        }
    ],

    onInventoryUOMClick: function () {
        iRely.Functions.openScreen('Inventory.view.InventoryUOM', { action: 'new', viewConfig: { modal: true }});
    },

    onCategoryClick: function () {
        iRely.Functions.openScreen('Inventory.view.Category', { action: 'new', viewConfig: { modal: true }});
    },

    onCommodityClick: function () {
        iRely.Functions.openScreen('Inventory.view.Commodity', { action: 'new', viewConfig: { modal: true }});
    },

    onLotStatusClick: function () {
        iRely.Functions.openScreen('Inventory.view.LotStatus');
    },
});