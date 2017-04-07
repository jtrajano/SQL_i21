Ext.define('Inventory.view.ItemViewController', {
    extend: 'Inventory.view.InventoryBaseViewController',
    alias: 'controller.icitem',

    config: {
        helpURL: '/display/DOC/Items',
        searchConfig: {
            title: 'Search Item',
            type: 'Inventory.Item',
            api: {
                read: '../Inventory/api/Item/Search'
            },
            columns: [
                {dataIndex: 'intItemId', text: "Item Id", flex: 1, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strItemNo', text: 'Item No', flex: 1, defaultSort: true, sortOrder: 'ASC', dataType: 'string', minWidth: 150},
                {dataIndex: 'strType', text: 'Type', flex: 1, dataType: 'string', minWidth: 150},
                {dataIndex: 'strDescription', text: 'Description', flex: 1, dataType: 'string', minWidth: 250},
                {dataIndex: 'strStatus', text: 'Status', flex: 1, dataType: 'string', minWidth: 150},
                {dataIndex: 'strTracking', text: 'Inv Valuation', flex: 1, dataType: 'string', minWidth: 150},
                {dataIndex: 'strLotTracking', text: 'Lot Tracking', flex: 1, dataType: 'string', minWidth: 150},
                {dataIndex: 'strCategory', text: 'Category', flex: 1, dataType: 'string', minWidth: 150},
                {dataIndex: 'strCommodity', text: 'Commodity', flex: 1, dataType: 'string', minWidth: 150},
                {dataIndex: 'strManufacturer', text: 'Manufacturer', flex: 1, dataType: 'string', minWidth: 150},
                {dataIndex: 'strBrandCode', text: 'Brand', flex: 1, dataType: 'string', minWidth: 150},
                {dataIndex: 'strModelNo', text: 'Model No', flex: 1, dataType: 'string', minWidth: 150}
            ],
            searchConfig: [
                {
                    title: 'Locations',
                    api: {
                        read: '../Inventory/api/ItemLocation/GetItemLocationViews'
                    },
                    columns: [

                        {dataIndex: 'intItemLocationId', text: 'Item Location Id', width: 100, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', hidden: true },
                        {dataIndex: 'intItemId', text: 'Item Id', width: 100, dataType: 'numeric', key: true, hidden: true },
                        {dataIndex: 'strItemNo', text: 'Item No', width: 150, dataType: 'string' },
                        {dataIndex: 'strItemDescription', text: 'Item Description', width: 150, dataType: 'string' },
                        {dataIndex: 'intLocationId', text: 'Location Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strLocationName', text: 'Location Name', width: 200, dataType: 'string' },
                        {dataIndex: 'intVendorId', text: 'Vendor Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strVendorId', text: 'Vendor Id', width: 100, dataType: 'string' },
                        {dataIndex: 'strVendorName', text: 'Vendor Name', width: 100, dataType: 'string' },
                        {dataIndex: 'strDescription', text: 'Description', width: 100, dataType: 'string' },
                        {dataIndex: 'intCostingMethod', text: 'Costing Method', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strCostingMethod', text: 'Costing Method', width: 120, dataType: 'string' },
                        {dataIndex: 'intAllowNegativeInventory', text: 'Allow Negative Inventory', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strAllowNegativeInventory', text: 'Allow Negative Inventory', width: 150, dataType: 'string' },
                        {dataIndex: 'intSubLocationId', text: 'SubLocation Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strSubLocationName', text: 'SubLocation', width: 120, dataType: 'string' },
                        {dataIndex: 'intStorageLocationId', text: 'Storage Location Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strStorageLocationName', text: 'Storage Location', width: 120, dataType: 'string' },
                        {dataIndex: 'intIssueUOMId', text: 'Issue UOM Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strIssueUOM', text: 'Issue UOM', width: 100, dataType: 'string' },
                        {dataIndex: 'intReceiveUOMId', text: 'Receive UOM Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strReceiveUOM', text: 'Receive UOM', width: 100, dataType: 'string' },
                        {dataIndex: 'intFamilyId', text: 'Family Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strFamily', text: 'Family', width: 100, dataType: 'string', hidden: true },
                        {dataIndex: 'intClassId', text: 'Class Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strClass', text: 'Class', width: 100, dataType: 'string', hidden: true },
                        {dataIndex: 'intProductCodeId', text: 'Product Code Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strRegProdCode', text: 'Product Code', width: 100, dataType: 'string', hidden: true },
                        {dataIndex: 'strPassportFuelId1', text: 'Passport Fuel Id 1', width: 100, dataType: 'string', hidden: true },
                        {dataIndex: 'strPassportFuelId2', text: 'Passport Fuel Id 2', width: 100, dataType: 'string', hidden: true },
                        {dataIndex: 'strPassportFuelId3', text: 'Passport Fuel Id 3', width: 100, dataType: 'string', hidden: true },
                        {dataIndex: 'ysnTaxFlag1', text: 'Tax Flag 1', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                        {dataIndex: 'ysnTaxFlag2', text: 'Tax Flag 2', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                        {dataIndex: 'ysnTaxFlag3', text: 'Tax Flag 3', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                        {dataIndex: 'ysnTaxFlag4', text: 'Tax Flag 4', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                        {dataIndex: 'ysnPromotionalItem', text: 'Promotional Item', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                        {dataIndex: 'intMixMatchId', text: 'Mix Match Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strPromoItemListId', text: 'PromoItemListId', width: 100, dataType: 'string', hidden: true },
                        {dataIndex: 'ysnDepositRequired', text: 'Deposit Required', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                        {dataIndex: 'intDepositPLUId', text: 'Deposit PLU Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strDepositPLU', text: 'Deposit PLU', width: 100, dataType: 'string', hidden: true },
                        {dataIndex: 'intBottleDepositNo', text: 'Bottle Deposit No', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'ysnSaleable', text: 'Saleable', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                        {dataIndex: 'ysnQuantityRequired', text: 'Quantity Required', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                        {dataIndex: 'ysnScaleItem', text: 'Scale Item', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                        {dataIndex: 'ysnFoodStampable', text: 'Food Stampable', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                        {dataIndex: 'ysnReturnable', text: 'Returnable', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                        {dataIndex: 'ysnPrePriced', text: 'PrePriced', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                        {dataIndex: 'ysnOpenPricePLU', text: 'Open Price PLU', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                        {dataIndex: 'ysnLinkedItem', text: 'Linked Item', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                        {dataIndex: 'strVendorCategory', text: 'Vendor Category', width: 100, dataType: 'string', hidden: true },
                        {dataIndex: 'ysnCountBySINo', text: 'Count By SI No', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                        {dataIndex: 'strSerialNoBegin', text: 'Serial No Begin', width: 100, dataType: 'string', hidden: true },
                        {dataIndex: 'strSerialNoEnd', text: 'Serial No End', width: 100, dataType: 'string', hidden: true },
                        {dataIndex: 'ysnIdRequiredLiquor', text: 'Id Required Liquor', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                        {dataIndex: 'ysnIdRequiredCigarette', text: 'Id Required Cigarette', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                        {dataIndex: 'intMinimumAge', text: 'Minimum Age', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'ysnApplyBlueLaw1', text: 'Apply Blue Law 1', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                        {dataIndex: 'ysnApplyBlueLaw2', text: 'Apply Blue Law 2', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                        {dataIndex: 'ysnCarWash', text: 'Car Wash', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                        {dataIndex: 'intItemTypeCode', text: 'Item Type Code Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strItemTypeCode', text: 'Item Type Code', width: 100, dataType: 'string', hidden: true },
                        {dataIndex: 'intItemTypeSubCode', text: 'Item Type Sub Code', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'ysnAutoCalculateFreight', text: 'Auto Calculate Freight', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                        {dataIndex: 'intFreightMethodId', text: 'Freight Method Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strFreightTerm', text: 'Freight Term', width: 100, dataType: 'string', hidden: true },
                        {dataIndex: 'dblFreightRate', text: 'Freight Rate', width: 100, dataType: 'float', xtype: 'numbercolumn', hidden: true },
                        {dataIndex: 'intShipViaId', text: 'Ship Via Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strShipVia', text: 'Ship Via', width: 100, dataType: 'string', hidden: true },
                        {dataIndex: 'dblReorderPoint', text: 'Reorder Point', width: 100, dataType: 'float', xtype: 'numbercolumn', hidden: true },
                        {dataIndex: 'dblMinOrder', text: 'Min Order', width: 100, dataType: 'float', xtype: 'numbercolumn', hidden: true },
                        {dataIndex: 'dblSuggestedQty', text: 'Suggested Qty', width: 100, dataType: 'float', xtype: 'numbercolumn', hidden: true },
                        {dataIndex: 'dblLeadTime', text: 'Lead Time', width: 100, dataType: 'float', xtype: 'numbercolumn', hidden: true },
                        {dataIndex: 'strCounted', text: 'Counted', width: 100, dataType: 'string', hidden: true },
                        {dataIndex: 'intCountGroupId', text: 'Count Group Id', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strCountGroup', text: 'Count Group', width: 100, dataType: 'string', hidden: true },
                        {dataIndex: 'ysnCountedDaily', text: 'Counted Daily', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                        {dataIndex: 'ysnLockedInventory', text: 'Locked Inventory', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                        {dataIndex: 'intSort', text: 'Sort', width: 100, dataType: 'numeric', hidden: true }
                    ],
                    customControl: [
                        {
                            xtype: 'button',
                            text: 'Copy Location',
                            itemId: 'btnCopyLocation',
                            iconCls: 'small-import',
                            listeners: {
                                click: function(e) {
                                    iRely.Functions.openScreen('Inventory.view.CopyItemLocation');
                                }
                            }
                        }
                    ]
                },
                {
                    title: 'Pricing',
                    api: {
                        read: '../Inventory/api/ItemPricing/GetItemStockPricingViews'
                    },
                    columns: [
                        {dataIndex: 'intPricingKey', text: 'Pricing Key', width: 100, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', hidden: true },
                        {dataIndex: 'strItemNo', text: 'Item No', width: 100, dataType: 'string' },
                        {dataIndex: 'strDescription', text: 'Description', width: 100, dataType: 'string' },
                        {dataIndex: 'strVendorId', text: 'Vendor Id', width: 100, dataType: 'string', hidden: true },
                        {dataIndex: 'strVendorName', text: 'Vendor Name', width: 100, dataType: 'string', hidden: true },
                        {dataIndex: 'strUpcCode', text: 'Upc Code', width: 100, dataType: 'string' },
                        {dataIndex: 'strLongUPCCode', text: 'Long UPC Code', width: 100, dataType: 'string' },
                        {dataIndex: 'intItemId', text: 'Item Id', width: 100, dataType: 'numeric', key: true, hidden: true },

                        {dataIndex: 'strLocationName', text: 'Location Name', width: 100, dataType: 'string' },
                        {dataIndex: 'strLocationType', text: 'Location Type', width: 100, dataType: 'string', hidden: true },
                        {dataIndex: 'strUnitMeasure', text: 'Unit Measure', width: 100, dataType: 'string' },
                        {dataIndex: 'strUnitType', text: 'Unit Type', width: 100, dataType: 'string', hidden: true },
                        {dataIndex: 'ysnStockUnit', text: 'Stock Unit', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                        {dataIndex: 'ysnAllowPurchase', text: 'Allow Purchase', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                        {dataIndex: 'ysnAllowSale', text: 'Allow Sale', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                        // {dataIndex: 'dblUnitQty', text: 'Unit Qty', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'dblAmountPercent', text: 'Amount/Percent', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'dblSalePrice', text: 'Sale Price', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'dblMSRPPrice', text: 'MSRP Price', width: 100, dataType: 'float', xtype: 'numbercolumn', hidden: true },
                        {dataIndex: 'strPricingMethod', text: 'Pricing Method', width: 100, dataType: 'string' },
                        {dataIndex: 'dblLastCost', text: 'Last Cost', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'dblStandardCost', text: 'Standard Cost', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'dblAverageCost', text: 'Average Cost', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'dblEndMonthCost', text: 'End Month Cost', width: 100, dataType: 'float', xtype: 'numbercolumn', hidden: true },
                        {dataIndex: 'intSort', text: 'Sort', width: 100, dataType: 'numeric', hidden: true }
                    ]
                },
                {
                    title: 'Item UOM',
                    api: {
                        read: '../Inventory/api/ItemUOM/GetUOMs'
                    },
                    columns: [
                        { dataIndex: 'intItemUOMId', text: 'Item UOM Id', width:100, flex: 1, dataType: 'numeric', hidden: true },
                        { dataIndex: 'intItemId', text: 'Item Id', width:100, flex: 1, dataType: 'numeric', key: true, hidden: true },
                        { dataIndex: 'intItemUOMId', text: 'Item UOM Id', width:100, flex: 1, dataType: 'numeric', hidden: true },
                        { dataIndex: 'strItemNo', text: 'Item No', width:100, flex: 1, dataType: 'string', defaultSort: true, sortOrder: 'ASC' },
                        { dataIndex: 'strItemDescription', text: 'Item Description', width:100, flex: 1, dataType: 'string' },
                        { dataIndex: 'strType', text: 'Item Type', width:100, flex: 1, dataType: 'string' },
                        { dataIndex: 'intItemId', text: 'Item Id', width:100, flex: 1, dataType: 'numeric', hidden: true },
                        { dataIndex: 'strCategory', text: 'Category', width:100, flex: 1, dataType: 'string' },
                        { dataIndex: 'strCategoryCode', text: 'Category Code', width:100, flex: 1, dataType: 'string', hidden: true },
                        { dataIndex: 'intCategoryId', text: 'Category Id', width:100, flex: 1, dataType: 'numeric', hidden: true },
                        { dataIndex: 'strCommodity', text: 'Commodity', width:100, flex: 1, dataType: 'string' },
                        { dataIndex: 'strCommodityCode', text: 'Commodity Code', width:100, flex: 1, dataType: 'string', hidden: true },
                        { dataIndex: 'intCommodityId', text: 'Commodity Id', width:100, flex: 1, dataType: 'numeric', hidden: true },
                        { dataIndex: 'strUnitMeasure', text: 'Unit Measure', width:100, flex: 1, dataType: 'string' },
                        { dataIndex: 'strStockUOM', text: 'Stock UOM', width:100, flex: 1, dataType: 'string' },
                        { dataIndex: 'ysnStockUnit', text: 'Is Stock Unit', xtype: 'checkcolumn', width:100, flex: 1, dataType: 'string' },
                        { dataIndex: 'ysnAllowPurchase', text: 'Allow Purchase', xtype: 'checkcolumn', width:100, flex: 1, dataType: 'boolean' },
                        { dataIndex: 'ysnAllowSale', text: 'Allow Sale', xtype: 'checkcolumn', width:100, flex: 1, dataType: 'boolean' },
                        { dataIndex: 'dblMaxQty', text: 'Max Qty', width:100, flex: 1, dataType: 'float', xtype: 'numbercolumn' },
                        { dataIndex: 'dblUnitQty', text: 'Unit Qty', width:100, flex: 1, dataType: 'float', xtype: 'numbercolumn' },
                        { dataIndex: 'dblHeight', text: 'Height', hidden: true, width:100, flex: 1, dataType: 'float', xtype: 'numbercolumn' },
                        { dataIndex: 'dblLength', text: 'Length', hidden: true, width:100, flex: 1, dataType: 'float', xtype: 'numbercolumn' },
                        { dataIndex: 'dblWeight', text: 'Weight', hidden: true, width:100, flex: 1, dataType: 'float', xtype: 'numbercolumn' },
                        { dataIndex: 'dblVolume', text: 'Volume', hidden: true, width:100, flex: 1, dataType: 'float', xtype: 'numbercolumn' }
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
            ]
        },
        binding: {
            bind: {
                title: 'Item - {current.strItemNo}'
            },

            //-----------//
            //Details Tab//
            //-----------//
            btnBuildAssembly: {
                hidden: '{hideBuildAssembly}'
            },
            txtItemNo: '{current.strItemNo}',
            txtDescription: '{current.strDescription}',
            txtModelNo: {
                value: '{current.strModelNo}',
                readOnly: '{HideDisableForComment}'
             },
            cboType: {
                value: '{current.strType}',
                store: '{itemTypes}',
                readOnly: '{readOnlyForDiscountType}'
            },
            txtShortName: {
                value: '{current.strShortName}',
                readOnly: '{HideDisableForComment}'
            },
            cboManufacturer: {
                value: '{current.intManufacturerId}',
                store: '{manufacturer}',
                readOnly: '{HideDisableForComment}'
            },
            cboBrand: {
                value: '{current.intBrandId}',
                store: '{brand}',
                readOnly: '{HideDisableForComment}'
            },
            cboStatus: {
                value: '{current.strStatus}',
                store: '{itemStatuses}',
                readOnly: '{readOnlyForDiscountType}'
            },
            cboCategory: {
                value: '{current.intCategoryId}',
                store: '{itemCategory}',
                defaultFilters: [{
                    column: 'strInventoryType',
                    value: '{current.strType}',
                    conjunction: 'and'
                }],
                 readOnly: '{HideDisableForComment}'
            },
            cboCommodity: {
                readOnly: '{readOnlyCommodity}',
                value: '{current.intCommodityId}',
                store: '{commodity}'
            },
            cboLotTracking: {
                value: '{current.strLotTracking}',
                store: '{lotTracking}',
                readOnly: '{checkStockTracking}'
            },
            cboTracking: {
                value: '{current.strInventoryTracking}',
                store: '{invTracking}',
                readOnly: '{checkLotTracking}'
            },

            cfgStock: {
                hidden: '{pgeStockHide}'
            },
            cfgCommodity: {
                hidden: '{pgeCommodityHide}'
            },
            cfgAssembly: {
                hidden: '{pgeAssemblyHide}'
            },
            cfgBundle: {
                hidden: '{pgeBundleHide}'
            },
            cfgKit: {
                hidden: '{pgeKitHide}'
            },
            cfgFactory: {
                hidden: '{pgeFactoryHide}'
            },
            cfgSales: {
                hidden: '{pgeSalesHide}'
            },
            cfgPOS: {
                hidden: '{pgePOSHide}'
            },
            cfgManufacturing: {
                hidden: '{pgeManufacturingHide}'
            },
            cfgContract: {
                hidden: '{pgeContractHide}'
            },
            cfgXref: {
                hidden: '{pgeXrefHide}'
            },
            cfgCost: {
                hidden: '{pgeCostHide}'
            },
            cfgOthers: {
                hidden: '{pgeOthersHide}'
            },
            cfgSetup: {
                hidden: '{HideDisableForComment}'
            },
            cfgPricing: {
                hidden: '{HideDisableForComment}'
            },
            grdUnitOfMeasure: {
                hidden: '{HideDisableForComment}',
                colDetailUnitMeasure: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{uomUnitMeasure}'
                    }
                },
                colDetailUnitQty: {
                    dataIndex: 'dblUnitQty',
                    editor: {
                        readOnly: '{readOnlyStockUnit}'
                    }
                },
                colDetailWeight: {
                    dataIndex: 'dblWeight'
                },
                colDetailWeightUOM: {
                    dataIndex: 'strWeightUOM',
                    editor: {
                        origValueField: 'intUnitMeasureId',
                        origUpdateField: 'intWeightUOMId',
                        store: '{weightUOM}',
                        defaultFilters: [{
                            column: 'strUnitType',
                            value: 'Weight',
                            conjunction: 'and'
                        }]
                    }
                },
                colDetailShortUPC: 'strUpcCode',
                colDetailUpcCode: {
                    dataIndex: 'strLongUPCCode'
                },
                colStockUnit: 'ysnStockUnit',
                colAllowSale: 'ysnAllowSale',
                colAllowPurchase: {
                    disabled: '{readOnlyOnBundleItems}',
                    dataIndex: 'ysnAllowPurchase'
                },
                colConvertToStock: 'dblConvertToStock',
                colConvertFromStock: 'dblConvertFromStock',
                colDetailLength: 'dblLength',
                colDetailWidth: 'dblWidth',
                colDetailHeight: 'dblHeight',
                colDetailDimensionUOM: {
                    dataIndex: 'strDimensionUOM',
                    editor: {
                        origValueField: 'intUnitMeasureId',
                        origUpdateField: 'intDimensionUOMId',
                        store: '{dimensionUOM}',
                        defaultFilters: [{
                            column: 'strUnitType',
                            value: '',
                            conjunction: 'and'
                        }]
                    }
                },
                colDetailVolume: 'dblVolume',
                colDetailVolumeUOM: {
                    dataIndex: 'strVolumeUOM',
                    editor: {
                        origValueField: 'intUnitMeasureId',
                        origUpdateField: 'intVolumeUOMId',
                        store: '{volumeUOM}',
                        defaultFilters: [{
                            column: 'strUnitType',
                            value: 'Volume',
                            conjunction: 'and'
                        }]
                    }
                },
                colDetailMaxQty: 'dblMaxQty',
            },

            btnLoadUOM: {
                hidden: true
            },

            //----------//
            //Setup Tab//
            //----------//

            //------------------//
            //Location Store Tab//
            //------------------//
            btnEditLocation: {
                hidden: true
            },
            cboCopyLocation: {
                store: '{copyLocation}',
                defaultFilters: [{
                    column: 'intItemId',
                    value: '{current.intItemId}'
                }]
            },
            grdLocationStore: {
                colLocationLocation: 'strLocationName',
                colLocationPOSDescription: 'strDescription',
                colLocationVendor: 'strVendorId',
                colLocationCostingMethod: 'strCostingMethod'
            },

            grdItemSubLocations: {
                colsubSubLocationName: {
                    dataIndex: 'strSubLocationName',
                    editor: {
                        store: '{subLocations}',
                        origValueField: 'intCompanyLocationSubLocationId',
                        origUpdateField: 'intSubLocationId',
                        defaultFilters: [
                            {
                                column: 'intCompanyLocationId',
                                value: '{grdLocationStore.selection.intCompanyLocationId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                }
            },

            //--------------//
            //GL Account Tab//
            //--------------//
            grdGlAccounts: {
                colGLAccountCategory: {
                    dataIndex: 'strAccountCategory',
                    editor: {
                        store: '{accountCategory}',
                        defaultFilters: [{
                            column: 'strAccountCategoryGroupCode',
                            value: 'INV'
                        },
                        {
                            column: 'strAccountCategory',
                            value: 'Write-Off Sold',
                            conjunction: 'and',
                            condition: 'noteq'
                        },
                        {
                            column: 'strAccountCategory',
                            value: 'Revalue Sold',
                            conjunction: 'and',
                            condition: 'noteq'
                        }]
                    }
                },
                colGLAccountId: {
                    dataIndex: 'strAccountId',
                    editor: {
                        defaultFilters: [
                            {
                                column: 'strAccountCategory',
                                value: '{accountCategoryFilter}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colDescription: 'strDescription'
            },

            //---------//
            //Sales Tab//
            //---------//
            cboFuelTaxClass: {
                value: '{current.intFuelTaxClassId}',
                store: '{taxClass}'
            },
            cboSalesTaxGroup: {
                value: '{current.intSalesTaxGroupId}',
                store: '{salesTaxGroup}'
            },
            cboPurchaseTaxGroup: {
                value: '{current.intPurchaseTaxGroupId}',
                store: '{purchaseTaxGroup}'
            },
            chkStockedItem: '{current.ysnStockedItem}',
            chkDyedFuel: '{current.ysnDyedFuel}',
            cboBarcodePrint: {
                value: '{current.strBarcodePrint}',
                store: '{barcodePrints}'
            },
            cboRequired: {
                value: '{current.strRequired}',
                store: '{drugCategory}'
            },
            chkMsdsRequired: '{current.ysnMSDSRequired}',
            txtEpaNumber: '{current.strEPANumber}',
            chkInboundTax: '{current.ysnInboundTax}',
            chkOutboundTax: '{current.ysnOutboundTax}',
            chkRestrictedChemical: '{current.ysnRestrictedChemical}',
            chkFuelItem: '{current.ysnFuelItem}',
            chkTankRequired: '{current.ysnTankRequired}',
            chkAvailableForTm: '{current.ysnAvailableTM}',
            txtDefaultPercentFull: '{current.dblDefaultFull}',
            cboFuelInspectionFee: {
                value: '{current.strFuelInspectFee}',
                store: '{fuelInspectFees}'
            },
            cboRinRequired: {
                value: '{current.strRINRequired}',
                store: '{rinRequires}'
            },
            cboFuelCategory: {
                value: '{current.intRINFuelTypeId}',
                store: '{fuelCategory}'
            },
            chkListBundleSeparately: {
                disabled: '{!readOnlyOnBundleItems}',
                value: '{current.ysnListBundleSeparately}'
            },
            txtPercentDenaturant: '{current.dblDenaturantPercent}',
            chkTonnageTax: '{current.ysnTonnageTax}',
            cboTonnageTaxUOM: {
                store: '{uomTonnageTax}',
                disabled: '{!current.ysnTonnageTax}',
                value: '{current.intTonnageTaxUOMId}',
                defaultFilters: [
                    {
                        column: 'strUnitType',
                        value: 'Weight'
                    }
                ]
            },
            chkLoadTracking: '{current.ysnLoadTracking}',
            txtMixOrder: '{current.dblMixOrder}',
            chkHandAddIngredients: '{current.ysnHandAddIngredient}',
            cboMedicationTag: {
                value: '{current.intMedicationTag}',
                store: '{medicationTag}'
            },
            cboIngredientTag: {
                value: '{current.intIngredientTag}',
                store: '{ingredientTag}'
            },
            txtVolumeRebateGroup: '{current.strVolumeRebateGroup}',
            cboPhysicalItem: {
                value: '{current.intPhysicalItem}',
                store: '{physicalItem}'
            },
            chkExtendOnPickTicket: '{current.ysnExtendPickTicket}',
            chkExportEdi: '{current.ysnExportEDI}',
            chkHazardMaterial: '{current.ysnHazardMaterial}',
            chkMaterialFee: '{current.ysnMaterialFee}',
            chkAutoBlend: '{current.ysnAutoBlend}',
            txtUserGroupFee: '{current.dblUserGroupFee}',
            txtWgtTolerance: '{current.dblWeightTolerance}',
            txtOverReceiveTolerance: '{current.dblOverReceiveTolerance}',
            cboMaintenanceCalculationMethod: {
                value: '{current.strMaintenanceCalculationMethod}',
                store: '{maintenancaCalculationMethods}'
            },
            txtMaintenanceRate: '{current.dblMaintenanceRate}',
            cboModule: {
                value: '{current.intModuleId}',
                store: '{module}',
                hidden: '{hiddenNotSoftware}'
            },

            //-------//
            //POS Tab//
            //-------//
            txtNacsCategory: '{current.strNACSCategory}',
            cboWicCode: {
                value: '{current.strWICCode}',
                store: '{wicCodes}'
            },
            chkReceiptCommentReq: '{current.ysnReceiptCommentRequired}',
            cboCountCode: {
                value: '{current.strCountCode}',
                store: '{countCodes}'
            },
            chkLandedCost: '{current.ysnLandedCost}',
            txtLeadTime: '{current.strLeadTime}',
            chkTaxable: '{current.ysnTaxable}',
            txtKeywords: '{current.strKeywords}',
            txtCaseQty: '{current.dblCaseQty}',
            dtmDateShip: '{current.dtmDateShip}',
            txtTaxExempt: '{current.dblTaxExempt}',
            chkDropShip: '{current.ysnDropShip}',
            chkCommissionable: '{current.ysnCommisionable}',
            chkSpecialCommission: '{current.ysnSpecialCommission}',

            grdCategory: {
                colPOSCategoryName: {
                    dataIndex: 'strCategoryCode',
                    editor: {
                        store: '{posCategory}'
                    }
                }
            },

            grdServiceLevelAgreement: {
                colPOSSLAContract: 'strSLAContract',
                colPOSSLAPrice: 'dblContractPrice',
                colPOSSLAWarranty: 'ysnServiceWarranty'
            },


            //-----------------//
            //Manufacturing Tab//
            //-----------------//
            chkRequireApproval: '{current.ysnRequireCustomerApproval}',
            cboAssociatedRecipe: '{current.intRecipeId}',
            chkSanitizationRequired: '{current.ysnSanitationRequired}',
            cboReceiveLotStatus: {
                value: '{current.intLotStatusId}',
                store: '{lotStatus}'
            },
            txtLifeTime: '{current.intLifeTime}',
            cboLifetimeType: {
                value: '{current.strLifeTimeType}',
                store: '{lifeTimeTypes}'
            },
            txtReceiveLife: '{current.intReceiveLife}',
            txtGTIN: '{current.strGTIN}',
            cboRotationType: {
                value: '{current.strRotationType}',
                store: '{rotationTypes}'
            },
            cboNFMC: {
                value: '{current.intNMFCId}',
                store: '{materialNMFC}'
            },
            chkStrictFIFO: '{current.ysnStrictFIFO}',
            txtHeight: '{current.dblHeight}',
            txtWidth: '{current.dblWidth}',
            txtDepth: '{current.dblDepth}',
            cboDimensionUOM: {
                value: '{current.intDimensionUOMId}',
                store: '{mfgDimensionUom}'
            },
            cboWeightUOM: {
                value: '{current.intWeightUOMId}',
                store: '{weightUOMs}',
                defaultFilters: [
                    {
                        name: 'intUnitMeasureId',
                        condition: 'eq',
                        value: 0
                    }
                ]
            },
            txtWeight: '{current.dblWeight}',
            txtMaterialPack: '{current.intMaterialPackTypeId}',
            txtMaterialSizeCode: '{current.strMaterialSizeCode}',
            txtInnerUnits: '{current.intInnerUnits}',
            txtLayersPerPallet: '{current.intLayerPerPallet}',
            txtUnitsPerLayer: '{current.intUnitPerLayer}',
            txtStandardPalletRatio: '{current.dblStandardPalletRatio}',
            txtMask1: '{current.strMask1}',
            txtMask2: '{current.strMask2}',
            txtMask3: '{current.strMask3}',
            txtMaxWeightPerPack: '{current.dblMaxWeightPerPack}',

            cboPackType: {
                value: '{current.intPackTypeId}',
                store: '{packType}'
            },
            txtWeightControlCode: '{current.strWeightControlCode}',
            txtBlendWeight: '{current.dblBlendWeight}',
            txtNetWeight: '{current.dblNetWeight}',
            txtUnitsPerCase: '{current.dblUnitPerCase}',
            txtQuarantineDuration: '{current.dblQuarantineDuration}',
            txtOwner: {
                value: '{current.intOwnerId}',
                store: '{owner}'
            },
            txtCustomer: {
                value: '{current.intCustomerId}',
                store: '{customer}'
            },
            txtCaseWeight: '{current.dblCaseWeight}',
            txtWarehouseStatus: {
                value: '{current.strWarehouseStatus}',
                store: '{warehouseStatus}'
            },
            chkKosherCertified: '{current.ysnKosherCertified}',
            chkFairTradeCompliant: '{current.ysnFairTradeCompliant}',
            chkOrganicItem: '{current.ysnOrganic}',
            chkRainForestCertified: '{current.ysnRainForestCertified}',
            txtRiskScore: '{current.dblRiskScore}',
            txtDensity: '{current.dblDensity}',
            dtmDateAvailable: '{current.dtmDateAvailable}',
            chkMinorIngredient: '{current.ysnMinorIngredient}',
            chkExternalItem: '{current.ysnExternalItem}',
            txtExternalGroup: '{current.strExternalGroup}',
            chkSellableItem: '{current.ysnSellableItem}',
            txtMinimumStockWeeks: '{current.dblMinStockWeeks}',
            txtFullContainerSize: '{current.dblFullContainerSize}',




            //-------------------//
            //Cross Reference Tab//
            //-------------------//
            grdCustomerXref: {
                colCustomerXrefLocation: {
                    dataIndex: 'strLocationName',
                    editor: {
                        store: '{custXrefLocation}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{current.intItemId}'
                        }]
                    }
                },
                colCustomerXrefCustomer: {
                    dataIndex: 'strCustomerNumber',
                    editor: {
                        store: '{custXrefCustomer}'
                    }
                },
                colCustomerXrefProduct: 'strCustomerProduct',
                colCustomerXrefDescription: 'strProductDescription',
                colCustomerXrefPickTicketNotes: 'strPickTicketNotes'
            },

            grdVendorXref: {
                colVendorXrefLocation: {
                    dataIndex: 'strLocationName',
                    editor: {
                        store: '{vendorXrefLocation}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{current.intItemId}'
                        }]
                    }
                },
                colVendorXrefVendor: {
                    dataIndex: 'strVendorId',
                    editor: {
                        store: '{vendorXrefVendor}'
                    }
                },
                colVendorXrefProduct: 'strVendorProduct',
                colVendorXrefDescription: 'strProductDescription',
                colVendorXrefConversionFactor: 'dblConversionFactor',
                colVendorXrefUnitMeasure: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{vendorXrefUom}'
                    }
                }
            },

            //--------//
            //Cost Tab//
            //--------//
            chkInventoryCost: '{current.ysnInventoryCost}',
            chkAccrue: '{current.ysnAccrue}',
            chkMTM: '{current.ysnMTM}',
            cboM2M: {
                value: '{current.intM2MComputationId}',
                store: '{m2mComputations}'
            },
            chkPrice: '{current.ysnPrice}',
            chkBasisContract: '{current.ysnBasisContract}',
            cboCostMethod: {
                readOnly: '{readOnlyCostMethod}',
                value: '{current.strCostMethod}',
                store: '{costMethods}'
            },
            cboCostType: {
                value: '{current.strCostType}',
                store: '{costTypes}',
                readOnly: '{readOnlyForDiscountType}'
            },
            cboOnCost: {
                value: '{current.intOnCostTypeId}',
                store: '{otherCharges}',
                defaultFilters: [{
                    column: 'intItemId',
                    value: '{current.intItemId}',
                    condition: 'noteq',
                    conjunction: 'and'
                }]
            },
            txtAmount: '{current.dblAmount}',
            cboCostUOM: {
                readOnly: '{checkPerUnitCostMethod}',
                value: '{current.intCostUOMId}',
                store: '{costUOM}',
                defaultFilters: [{
                    column: 'intItemId',
                    value: '{current.intItemId}',
                    conjunction: 'and'
                }]
            },

            //--------------//
            //Motor Fuel Tax//
            //--------------//
            grdMotorFuelTax: {
                colMFTTaxAuthorityCode: {
                    dataIndex: 'strTaxAuthorityCode',
                    editor: {
                        origValueField: 'intTaxAuthorityId',
                        origUpdateField: 'intTaxAuthorityId',
                        store: '{taxAuthority}',
                        defaultFilters: [{
                            column: 'ysnFilingForThisTA',
                            value: true
                        }]
                    }
                },
                colMFTTaxDescription: 'strTaxAuthorityDescription',
                colMFTProductCode: {
                    dataIndex: 'strProductCode',
                    editor: {
                        origValueField: 'intProductCodeId',
                        origUpdateField: 'intProductCodeId',
                        store: '{productCode}',
                        defaultFilters: [{
                            column: 'intTaxAuthorityId',
                            value: '{grdMotorFuelTax.selection.intTaxAuthorityId}'
                        }]
                    }
                },
                colMFTProductCodeDescription: 'strProductDescription',
                colMFTProductCodeGroup: 'strProductCodeGroup'
            },

            cboPatronage: {
                value: '{current.intPatronageCategoryId}',
                store: '{patronage}'
            },
            cboPatronageDirect: {
                value: '{current.intPatronageCategoryDirectId}',
                store: '{directSale}'
            },

            //-----------------//
            //Contract Item Tab//
            //-----------------//
            grdContractItem: {
                colContractLocation: {
                    dataIndex: 'strLocationName',
                    editor: {
                        store: '{contractLocation}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{current.intItemId}'
                        }]
                    }
                },
                colContractItemName: 'strContractItemName',
                colContractOrigin: {
                    dataIndex: 'strCountry',
                    editor: {
                        store: '{origin}'
                    }
                },
                colContractGrade: 'strGrade',
                colContractGarden: 'strGarden',
                colContractGradeType: 'strGradeType',
                colContractYield: 'dblYieldPercent',
                colContractTolerance: 'dblTolerancePercent',
                colContractFranchise: 'dblFranchisePercent',
                colContractItemNo: 'strContractItemNo'
            },

            grdDocumentAssociation: {
                colDocument:  {
                    dataIndex: 'strDocumentName',
                    editor: {
                        store: '{document}'
                    }
                }
            },

            grdCertification: {
                colCertification:  {
                    dataIndex: 'strCertificationName',
                    editor: {
                        store: '{certification}'
                    }
                }
            },

            //-----------//
            //Pricing Tab//
            //-----------//
            grdPricing: {
                colPricingLocation: {
                    dataIndex: 'strLocationName',
                    editor: {
                        readOnly: true,
                        store: '{pricingLocation}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{current.intItemId}'
                        }]
                    }
                },
                colPricingUOM: 'strUnitMeasure',
                colPricingUPC: 'strUPC',
                colPricingLastCost: 'dblLastCost',
                colPricingStandardCost: 'dblStandardCost',
                colPricingAverageCost: 'dblAverageCost',
                colPricingEOMCost: 'dblEndMonthCost',
                colPricingMethod: {
                    dataIndex: 'strPricingMethod',
                    editor: {
                        store: '{pricingPricingMethods}'
                    }
                },
                colPricingAmount: 'dblAmountPercent',
                colPricingRetailPrice: 'dblSalePrice',
                colPricingMSRP: 'dblMSRPPrice'
            },

            grdPricingLevel: {
                colPricingLevelLocation: {
                    dataIndex: 'strLocationName',
                    editor: {
                        store: '{pricingLevelLocation}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{current.intItemId}'
                        }]
                    }
                },
                colPricingLevelPriceLevel: {
                    dataIndex: 'strPriceLevel',
                    editor: {
                        store: '{pricingLevel}',
                        defaultFilters: [{
                            column: 'intCompanyLocationId',
                            value: '{grdPricingLevel.selection.intLocationId}'
                        }]
                    }
                },
                colPricingLevelUOM: {
                    hidden: true,
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{pricingLevelUOM}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{current.intItemId}'
                        }]
                    }
                },
                colPricingLevelUPC: 'strUPC',
                colPricingLevelUnits: {
                    dataIndex: 'dblUnit',
                    hidden: true
                },
                colPricingLevelMin: 'dblMin',
                colPricingLevelMax: 'dblMax',
                colPricingLevelMethod: {
                    dataIndex: 'strPricingMethod',
                    editor: {
                        store: '{pricingMethods}'
                    }
                },
                colPricingLevelAmount: 'dblAmountRate',
                colPricingLevelUnitPrice: 'dblUnitPrice',
                colPricingLevelCommissionOn: {
                    dataIndex: 'strCommissionOn',
                    editor: {
                        store: '{commissionsOn}'
                    }
                },
                colPricingLevelCommissionRate: 'dblCommissionRate',
                colPricingLevelCurrency: {
                    dataIndex: 'strCurrency',
                    editor: {
                        store: '{currency}',
                        defaultFilters: [{
                            column: 'ysnSubCurrency',
                            value: false
                        }]
                    }
                }
            },

            grdSpecialPricing: {
                colSpecialPricingLocation: {
                    dataIndex: 'strLocationName',
                    editor: {
                        store: '{specialPricingLocation}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{current.intItemId}'
                        }]
                    }
                },
                colSpecialPricingPromotionType: {
                    dataIndex: 'strPromotionType',
                    editor: {
                        store: '{promotionTypes}'
                    }
                },
                colSpecialPricingUnit: {
                    hidden: true,
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{specialPricingUOM}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{current.intItemId}'
                        }]
                    }
                },
                colSpecialPricingUPC: 'strUPC',
                colSpecialPricingQty: {
                    dataIndex: 'dblUnit'
                },
                colSpecialPricingDiscountBy: {
                    dataIndex: 'strDiscountBy',
                    editor: {
                        store: '{discountsBy}'
                    }
                },
                colSpecialPricingDiscountRate: 'dblDiscount',
                colSpecialPricingUnitPrice: 'dblUnitAfterDiscount',
                colSpecialPricingDiscountedPrice: 'dblDiscountedPrice',
                colSpecialPricingBeginDate: 'dtmBeginDate',
                colSpecialPricingEndDate: 'dtmEndDate',
                colSpecialPricingDiscQty: 'dblDiscountThruQty',
                colSpecialPricingDiscAmount: 'dblDiscountThruAmount',
                colSpecialPricingAccumQty: 'dblAccumulatedQty',
                colSpecialPricingAccumAmount: 'dblAccumulatedAmount',
                colSpecialPricingCurrency: {
                    dataIndex: 'strCurrency',
                    editor: {
                        store: '{currency}',
                        defaultFilters: [{
                            column: 'ysnSubCurrency',
                            value: false
                        }]
                    }
                }
            },

            //---------//
            //Stock Tab//
            //---------//
            grdStock: {
                colStockLocation: 'strLocationName',
                colStockUOM: 'strUnitMeasure',
                colStockOnOrder: 'dblOnOrder',
                colStockInTransitInbound: 'dblInTransitInbound',
                colStockOnHand: 'dblUnitOnHand',
                colStockInTransitOutbound: 'dblInTransitOutbound',
                colStockBackOrder: 'dblCalculatedBackOrder', // formerly, this is: colStockBackOrder: 'dblBackOrder',
                colStockCommitted: 'dblOrderCommitted',
                colStockOnStorage: 'dblUnitStorage',
                colStockConsignedPurchase: 'dblConsignedPurchase',
                colStockConsignedSale: 'dblConsignedSale',
                colStockReserved: 'dblUnitReserved',
                colStockAvailable: 'dblAvailable'
            },

            //-------------//
            //Commodity Tab//
            //-------------//
            txtGaShrinkFactor: '{current.dblGAShrinkFactor}',
            cboOrigin: {
                value: '{current.intOriginId}',
                store: '{originAttribute}'
            },
            cboProductType: {
                value: '{current.intProductTypeId}',
                store: '{productTypeAttribute}',
                defaultFilters: [{
                    column: 'intCommodityId',
                    value: '{current.intCommodityId}'
                }]
            },
            cboRegion: {
                value: '{current.intRegionId}',
                store: '{regionAttribute}',
                defaultFilters: [{
                    column: 'intCommodityId',
                    value: '{current.intCommodityId}'
                }]
            },
            cboSeason: {
                value: '{current.intSeasonId}',
                store: '{seasonAttribute}',
                defaultFilters: [{
                    column: 'intCommodityId',
                    value: '{current.intCommodityId}'
                }]
            },
            cboClass: {
                value: '{current.intClassVarietyId}',
                store: '{classAttribute}',
                defaultFilters: [{
                    column: 'intCommodityId',
                    value: '{current.intCommodityId}'
                }]
            },
            cboProductLine: {
                value: '{current.intProductLineId}',
                store: '{productLineAttribute}',
                defaultFilters: [{
                    column: 'intCommodityId',
                    value: '{current.intCommodityId}'
                }]
            },
            cboGrade: {
                value: '{current.intGradeId}',
                store: '{gradeAttribute}',
                defaultFilters: [{
                    column: 'intCommodityId',
                    value: '{current.intCommodityId}'
                }]
            },
            cboMarketValuation: {
                value: '{current.strMarketValuation}',
                store: '{marketValuations}'
            },

            grdCommodityCost: {
                colCommodityLocation: {
                    dataIndex: 'strLocationName',
                    editor: {
                        origValueField: 'intItemLocationId',
                        origUpdateField: 'intItemLocationId',
                        store: '{commodityLocations}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{current.intItemId}'
                        }]
                    }
                },
                colCommodityLastCost: 'dblLastCost',
                colCommodityStandardCost: 'dblStandardCost',
                colCommodityAverageCost: 'dblAverageCost',
                colCommodityEOMCost: 'dblEOMCost'
            },

            //------------//
            //Assembly Tab//
            //------------//
            grdAssembly: {
                colAssemblyComponent: {
                    dataIndex: 'strItemNo',
                    editor: {
                        store: '{assemblyItem}',
                        defaultFilters: [
                            {
                                column: 'strLotTracking',
                                value: 'No',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colAssemblyQuantity: 'dblQuantity',
                colAssemblyDescription: 'strItemDescription',
                colAssemblyUOM: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{assemblyUOM}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdAssembly.selection.intAssemblyItemId}'
                        }]
                    }
                },
                colAssemblyUnit: 'dblUnit'
            },

            //------------------//
            //Bundle Details Tab//
            //------------------//
            grdBundle: {
                colBundleItem: {
                    dataIndex: 'strItemNo',
                    editor: {
                        origValueField: 'intItemId',
                        origUpdateField: 'intBundleItemId',
                        store: '{bundleItem}',
                        defaultFilters: [{
                            column: 'strType',
                            value: 'Inventory',
                            conjunction: 'and'
                        }, {
                            column: 'intCommodityId',
                            value: '{current.intCommodityId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colBundleQuantity: 'dblQuantity',
                colBundleDescription: 'strDescription',
                colBundleUOM: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{bundleUOM}',
                        origValueField: 'intItemUOMId',
                        origUpdateField: 'intItemUnitMeasureId',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdBundle.selection.intBundleItemId}',
                            conjunction: 'or'
                        }]
                    }
                },
                colBundleUnit: 'dblUnit'
            },

            //---------------//
            //Kit Details Tab//
            //---------------//
            grdKit: {
                colKitComponent: 'strComponent',
                colKitInputType: {
                    dataIndex: 'strInputType',
                    editor: {
                        store: '{inputTypes}'
                    }
                }
            },

            grdKitDetails: {
                colKitItem: {
                    dataIndex: 'strItemNo',
                    editor: {
                        store: '{kitItem}',
                        defaultFilters: [{
                            column: 'strType',
                            value: 'Inventory'
                        }]
                    }
                },
                colKitItemDescription: 'strDescription',
                colKitItemQuantity: 'dblQuantity',
                colKitItemUOM: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{kitUOM}'
                    }
                },
                colKitItemPrice: 'dblPrice',
                colKitItemSelected: 'ysnSelected'
            },
            //-------------------//
            //Factory & Lines Tab//
            //-------------------//
            grdFactory: {
                colFactoryName: {
                    dataIndex: 'strLocationName',
                    editor: {
                        origValueField: 'intCompanyLocationId',
                        origUpdateField: 'intFactoryId',
                        store: '{factory}'
                    }
                },
                colFactoryDefault: 'ysnDefault'
            },

            grdManufacturingCellAssociation: {
                colCellName: {
                    dataIndex: 'strCellName',
                    editor: {
                        origValueField: 'intManufacturingCellId',
                        origUpdateField: 'intManufacturingCellId',
                        store: '{factoryManufacturingCell}'
                    }
                },
                colCellNameDefault: 'ysnDefault',
                colCellPreference: 'intPreference'
            },

            grdOwner: {
                colOwner: {
                    dataIndex: 'strCustomerNumber',
                    editor: {
                        origValueField: 'intEntityCustomerId',
                        origUpdateField: 'intOwnerId',
                        store: '{owner}'
                    }
                },
                colOwnerName: 'strName',
                colOwnerDefault: 'ysnDefault'
            },

            //----------//
            //Others Tab//
            //----------//

            txtInvoiceComments: '{current.strInvoiceComments}',
            txtPickListComments: '{current.strPickListComments}'
        }
    },

    deleteMessage: function() {
        var win = Ext.WindowMgr.getActive();
        var itemNo = win.down("#txtItemNo").value;
        var msg = "Are you sure you want to delete Item <b>" + Ext.util.Format.htmlEncode(itemNo) + "</b>?";
        return msg;
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Item', { pageSize: 1 });

        var grdUOM = win.down('#grdUnitOfMeasure'),
            grdLocationStore = win.down('#grdLocationStore'),
            grdCategory = win.down('#grdCategory'),
            grdGlAccounts = win.down('#grdGlAccounts'),
            grdVendorXref = win.down('#grdVendorXref'),
            grdCustomerXref = win.down('#grdCustomerXref'),
            grdContractItem = win.down('#grdContractItem'),
            grdDocumentAssociation = win.down('#grdDocumentAssociation'),
            grdCertification = win.down('#grdCertification'),
            grdStock = win.down('#grdStock'),
            grdFactory = win.down('#grdFactory'),
            grdManufacturingCellAssociation = win.down('#grdManufacturingCellAssociation'),
            grdOwner = win.down('#grdOwner'),
            grdMotorFuelTax = win.down('#grdMotorFuelTax'),
            grdItemSubLocations = win.down('#grdItemSubLocations'),
            grdPricing = win.down('#grdPricing'),
            grdPricingLevel = win.down('#grdPricingLevel'),
            grdSpecialPricing = win.down('#grdSpecialPricing'),

            grdCommodityCost = win.down('#grdCommodityCost'),

            grdAssembly = win.down('#grdAssembly'),
            grdBundle = win.down('#grdBundle'),
            grdKit = win.down('#grdKit'),
            grdKitDetails = win.down('#grdKitDetails');

        win.context = Ext.create('iRely.mvvm.Engine', {
            window : win,
            store  : store,
            createRecord : me.createRecord,
            validateRecord : me.validateRecord,
            deleteMsg: me.deleteMessage,
            binding: me.config.binding,
            fieldTitle: 'strItemNo',
            enableAudit: true,
            enableActivity: true,
            enableCustomTab: true,
            createTransaction: Ext.bind(me.createTransaction, me),
            onSaveClick: me.saveAndPokeGrid(win, grdUOM),
            attachment: Ext.create('iRely.mvvm.attachment.Manager', {
                type: 'Inventory.Item',
                window: win
            }),
            details: [
                {
                    key: 'tblICItemUOMs',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdUOM,
                        deleteButton : grdUOM.down('#btnDeleteUom')
                    })
                },
                {
                    key: 'tblICItemLocations',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdLocationStore,
                        deleteButton : grdLocationStore.down('#btnDeleteLocation'),
                        position: 'none'
                    }),
                    details: [
                        {
                            key: 'tblICItemSubLocations',
                            component: Ext.create('iRely.mvvm.grid.Manager', {
                                grid: grdItemSubLocations,
                                deleteButton : grdItemSubLocations.down('#btnDeleteItemSubLocation')
                            })
                        }
                    ]
                },
                {
                    key: 'tblICItemVendorXrefs',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdVendorXref,
                        deleteButton : grdVendorXref.down('#btnDeleteVendorXref')
                    })
                },
                {
                    key: 'tblICItemCustomerXrefs',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdCustomerXref,
                        deleteButton : grdCustomerXref.down('#btnDeleteCustomerXref')
                    })
                },
                {
                    key: 'tblICItemContracts',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdContractItem,
                        deleteButton : grdContractItem.down('#btnDeleteContractItem')
                    }),
                    details: [
                        {
                            key: 'tblICItemContractDocuments',
                            component: Ext.create('iRely.mvvm.grid.Manager', {
                                grid: grdDocumentAssociation,
                                deleteButton : grdDocumentAssociation.down('#btnDeleteDocumentAssociation')
                            })
                        }
                    ]
                },
                {
                    key: 'tblICItemMotorFuelTaxes',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdMotorFuelTax,
                        deleteButton: grdMotorFuelTax.down('#btnDeleteMFT')
                    })
                },
                {
                    key: 'tblICItemCertifications',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdCertification,
                        deleteButton : grdCertification.down('#btnDeleteCertification')
                    })
                },
                {
                    key: 'tblICItemPOSCategories',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdCategory,
                        deleteButton : win.down('#btnDeleteCategories')
                    })
                },
                {
                    key: 'tblICItemPOSSLAs',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: win.down('#grdServiceLevelAgreement'),
                        deleteButton : win.down('#btnDeleteSLA')
                    })
                },
                {
                    key: 'tblICItemAccounts',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdGlAccounts,
                        deleteButton : grdGlAccounts.down('#btnDeleteGlAccounts')
                    })
                },
                {
                    key: 'tblICItemStocks',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdStock,
                        position: 'none'
                    })
                },
                {
                    key: 'tblICItemCommodityCosts',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdCommodityCost,
                        deleteButton : grdCommodityCost.down('#btnDeleteCommodityCost')
                    })
                },
                {
                    key: 'tblICItemPricings',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdPricing,
                        deleteButton : grdPricing.down('#btnDeletePricing')
                    })
                },
                {
                    key: 'tblICItemPricingLevels',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdPricingLevel,
                        deleteButton : grdPricingLevel.down('#btnDeletePricingLevel')
                    })
                },
                {
                    key: 'tblICItemSpecialPricings',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdSpecialPricing,
                        deleteButton : grdSpecialPricing.down('#btnDeleteSpecialPricing')
                    })
                },
                {
                    key: 'tblICItemAssemblies',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdAssembly,
                        deleteButton : grdAssembly.down('#btnDeleteAssembly')
                    })
                },
                {
                    key: 'tblICItemBundles',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdBundle,
                        deleteButton : grdBundle.down('#btnDeleteBundle')
                    })
                },
                {
                    key: 'tblICItemKits',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdKit,
                        deleteButton : grdKit.down('#btnDeleteKit')
                    }),
                    details: [
                        {
                            key: 'tblICItemKitDetails',
                            component: Ext.create('iRely.mvvm.grid.Manager', {
                                grid: grdKitDetails,
                                deleteButton : grdKitDetails.down('#btnDeleteKitDetail')
                            })
                        }
                    ]
                },
                {
                    key: 'tblICItemOwners',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdOwner,
                        deleteButton : grdOwner.down('#btnDeleteOwner')
                    })
                },
                {
                    key: 'tblICItemFactories',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdFactory,
                        deleteButton : grdFactory.down('#btnDeleteFactory')
                    }),
                    details: [
                        {
                            key: 'tblICItemFactoryManufacturingCells',
                            component: Ext.create('iRely.mvvm.grid.Manager', {
                                grid: grdManufacturingCellAssociation,
                                deleteButton : grdManufacturingCellAssociation.down('#btnDeleteManufacturingCellAssociation')
                            })
                        }
                    ]
                }
            ]
        });

        me.subscribeLocationEvents(grdLocationStore, me);

        var cepPricingLevel = grdPricingLevel.getPlugin('cepPricingLevel');
        if (cepPricingLevel){
            cepPricingLevel.on({
                edit: me.onEditPricingLevel,
                scope: me
            });
        }

        var cepPricing = grdPricing.getPlugin('cepPricing');
        if (cepPricing){
            cepPricing.on({
                edit: me.onEditPricing,
                scope: me
            });
        }

        var cepSpecialPricing = grdSpecialPricing.getPlugin('cepSpecialPricing');
        if (cepSpecialPricing) {
            cepSpecialPricing.on({
                edit: me.onEditSpecialPricing,
                scope: me
            });
        }

        var colLocationLocation = grdLocationStore.columns[0];
        colLocationLocation.renderer = function(value, opt, record) {
            return '<a style="color: #005FB2;text-decoration: none;" onMouseOut="this.style.textDecoration=\'none\'" onMouseOver="this.style.textDecoration=\'underline\'" href="javascript:void(0);">' + value + '</a>';
        };


        var colStockOnOrder = grdStock.columns[2];
        colStockOnOrder.summaryRenderer = this.StockSummaryRenderer;
        var colStockInTransitInbound = grdStock.columns[3];
        colStockInTransitInbound.summaryRenderer = this.StockSummaryRenderer
        var colStockOnHand = grdStock.columns[4];
        colStockOnHand.summaryRenderer = this.StockSummaryRenderer
        var colStockInTransitOutbound = grdStock.columns[5];
        colStockInTransitOutbound.summaryRenderer = this.StockSummaryRenderer
        var colStockBackOrder = grdStock.columns[6];
        colStockBackOrder.summaryRenderer = this.StockSummaryRenderer
        var colStockCommitted = grdStock.columns[7];
        colStockCommitted.summaryRenderer = this.StockSummaryRenderer
        var colStockOnStorage = grdStock.columns[8];
        colStockOnStorage.summaryRenderer = this.StockSummaryRenderer
        var colStockConsignedPurchase = grdStock.columns[9];
        colStockConsignedPurchase.summaryRenderer = this.StockSummaryRenderer
        var colStockConsignedSale = grdStock.columns[10];
        colStockConsignedSale.summaryRenderer = this.StockSummaryRenderer
        var colStockReserved = grdStock.columns[11];
        colStockReserved.summaryRenderer = this.StockSummaryRenderer
        var colStockAvailable = grdStock.columns[12];
        colStockAvailable.summaryRenderer = this.StockSummaryRenderer

        return win.context;
    },

    StockSummaryRenderer: function (value, params, data) {
        return i21.ModuleMgr.Inventory.roundDecimalFormat(value, 2);
    },

    createTransaction: function(config, action) {
        var me = this,
            current = me.getViewModel().get('current');

        action({
            strTransactionNo: current.get('strItemNo'), //Unique field
            intEntityId: current.get('intEntityId'), //Entity Associated
            dtmDate: current.get('dtmDate') // Date
        })
    },


    createRecord: function(config, action) {
        var me = this;
        var record = Ext.create('Inventory.model.Item');
        record.set('strStatus', 'Active');
        record.set('strM2MComputation', 'No');
        record.set('intM2MComputationId', 1);
        record.set('strType', 'Inventory');
        record.set('strLotTracking', 'No');
        record.set('strInventoryTracking', 'Item Level');
        record.set('ysnListBundleSeparately', true);
        action(record);
    },

    show : function(config) {
        "use strict";

        var me = this,
            win = this.getView();

        if (config) {
            win.show();
            var context = me.setupContext( {window : win} );

            if (config.action === 'new') {
                context.data.addRecord();
            } else {
                if (config.id) {
                    config.filters = [{
                        column: 'intItemId',
                        value: config.id
                    }];
                }
                context.data.load({
                    filters: config.filters
                });
            }
        }
    },

    validateRecord: function(config, action) {
        var win = config.window,
            current = win.viewModel.data.current;

        var pricings = config.viewModel.data.current.tblICItemPricings();
        if(pricings) {
            var items = pricings.data.items;
            for(var i = 0; i < items.length; i++) {
                var p = items[i];

                if((iRely.Functions.isEmpty(p.data.strLocationName, false) || p.data.intItemLocationId === null
                    || iRely.Functions.isEmpty(p.data.strPricingMethod, false)) && !p.dummy) {
                    var tabItem = win.down('#tabItem');
                    tabItem.setActiveTab('pgePricing');
                    var grid = win.down('#grdPricing');
                     var gridColumns = grid.headerCt.getGridColumns();
                    for (var i = 0; i < gridColumns.length; i++) {
                        if (gridColumns[i].itemId == 'colPricingLocation' || gridColumns[i].itemId == 'colPricingMethod') {
                            grid.columnManager.columns[i].setVisible(true);
                        }
                    }
                    action(false);
                    //iRely.Msg.showError('The Location in Pricing must not be blank.', Ext.MessageBox.OK, win);
                    //return;
                }
            }
        }

        this.validateRecord(config, function (result) {
            if (result) {
                var uomStore = config.viewModel.data.current.tblICItemUOMs();
                
                if(uomStore) {
                    var uoms = uomStore.data.items;
                    var cnt = false;
                    for(var i = 0; i < uoms.length; i++) {
                        var u = uoms[i];
                        if (!u.dummy) {
                            if (cnt > 1)
                                break;
                           // if (u.data.dblUnitQty === 1) {
                           //     cnt++;
                           // }
                            else {
                                //Check if all the Unit Quanitities have Unique values
                                var currentUnitQty = u.data.dblUnitQty;

                                for(var j = 0; j < uoms.length; j++) {
                                    var eachUOM = uoms[j];
                                    if (!eachUOM.dummy) {
                                        if (j !== i && eachUOM.data.dblUnitQty === currentUnitQty) {
                                            cnt++;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if(cnt > 1 && (current.get('strType') === 'Inventory' || current.get('strType') === 'Finished Good' || current.get('strType') === 'Raw Material')) {
                        var tabItem = win.down('#tabItem');
                        tabItem.setActiveTab('pgeDetails');
                        var grid = win.down('#grdUnitOfMeasure');
                        iRely.Msg.showError('UOMs must not have the same Unit Qty.', Ext.MessageBox.OK, win);
                        action(false);
                    } else
                        action(true);
                } else
                    action(true);
            }
            else {
                var tabItem = win.down('#tabItem');
                var tabSetup = win.down('#tabSetup');
                if (config.viewModel.data.current.get('strType') === 'Finished Good' || config.viewModel.data.current.get('strType') === 'Raw Material') {
                    if (iRely.Functions.isEmpty(config.viewModel.data.current.get('strLifeTimeType'))) {
                        tabItem.setActiveTab('pgeSetup');
                        tabSetup.setActiveTab('pgeManufacturing');
                        action(false);
                    }
                    else if (config.viewModel.data.current.get('intLifeTime') <= 0) {
                        tabItem.setActiveTab('pgeSetup');
                        tabSetup.setActiveTab('pgeManufacturing');
                        action(false);
                    }
                    else if (config.viewModel.data.current.get('intReceiveLife') <= 0) {
                        tabItem.setActiveTab('pgeSetup');
                        tabSetup.setActiveTab('pgeManufacturing');
                        action(false);
                    }
                }
                else {
//                    tabItem.setActiveTab('pgePricing');
                    action(false);
                }
            }
        });
    },

    // <editor-fold desc="Details Tab Methods and Event Handlers">

    onItemTabChange: function(tabPanel, newCard, oldCard, eOpts) {
        switch (newCard.itemId) {
            case 'pgeDetails':
                var pgeDetails = tabPanel.down('#pgeDetails');
                var grdUnitOfMeasure = pgeDetails.down('#grdUnitOfMeasure');
                if (grdUnitOfMeasure.store.complete === true)
                    grdUnitOfMeasure.getView().refresh();
                else
                    grdUnitOfMeasure.store.load();
                break;

            case 'pgeSetup':
                var tabSetup = tabPanel.down('#tabSetup');
                this.onItemTabChange(tabSetup, tabSetup.activeTab);

            case 'pgeLocation':
                var pgeLocation = tabPanel.down('#pgeLocation');
                var grdLocationStore = pgeLocation.down('#grdLocationStore');
                if (grdLocationStore.store.complete === true)
                    grdLocationStore.getView().refresh();
                else
                    grdLocationStore.store.load();
                break;

            case 'pgeGLAccounts':
                var pgeGLAccounts = tabPanel.down('#pgeGLAccounts');
                var grdGlAccounts = pgeGLAccounts.down('#grdGlAccounts');
                if (grdGlAccounts.store.complete === true)
                    grdGlAccounts.getView().refresh();
                else
                    grdGlAccounts.store.load();
                break;

            case 'pgePOS':
                var pgePOS = tabPanel.down('#pgePOS');
                var grdCategory = pgePOS.down('#grdCategory');
                if (grdCategory.store.complete === true)
                    grdCategory.getView().refresh();
                else
                    grdCategory.store.load();

                var grdServiceLevelAgreement = pgePOS.down('#grdServiceLevelAgreement');
                if (grdServiceLevelAgreement.store.complete === true)
                    grdServiceLevelAgreement.getView().refresh();
                else
                    grdServiceLevelAgreement.store.load();
                break;

            case 'pgeXref':
                var pgeXref = tabPanel.down('#pgeXref');
                var grdCustomerXref = pgeXref.down('#grdCustomerXref');
                if (grdCustomerXref.store.complete === true)
                    grdCustomerXref.getView().refresh();
                else
                    grdCustomerXref.store.load();

                var grdVendorXref = pgeXref.down('#grdVendorXref');
                if (grdVendorXref.store.complete === true)
                    grdVendorXref.getView().refresh();
                else
                    grdVendorXref.store.load();
                break;

            case 'pgeContract':
                var pgeContract = tabPanel.down('#pgeContract');
                var grdContractItem = pgeContract.down('#grdContractItem');
                if (grdContractItem.store.complete === true)
                    grdContractItem.getView().refresh();
                else
                    grdContractItem.store.load();

                var grdCertification = pgeContract.down('#grdCertification');
                if (grdCertification.store.complete === true)
                    grdCertification.getView().refresh();
                else
                    grdCertification.store.load();
                break;

            case 'pgeMFT':
                var pgeMFT = tabPanel.down('#pgeMFT');
                var grdMotorFuelTax = pgeMFT.down('#grdMotorFuelTax');
                if (grdMotorFuelTax.store.complete === true)
                    grdMotorFuelTax.getView().refresh();
                else
                    grdMotorFuelTax.store.load();
                break;

            case 'pgePricing':
                var pgePricing = tabPanel.down('#pgePricing');
                var grdPricing = pgePricing.down('#grdPricing');
                if (grdPricing.store.complete === true)
                    grdPricing.getView().refresh();
                else
                    grdPricing.store.load();

                var grdPricingLevel = pgePricing.down('#grdPricingLevel');
                if (grdPricingLevel.store.complete === true)
                    grdPricingLevel.getView().refresh();
                else
                    grdPricingLevel.store.load();

                var grdSpecialPricing = pgePricing.down('#grdSpecialPricing');
                if (grdSpecialPricing.store.complete === true)
                    grdSpecialPricing.getView().refresh();
                else
                    grdSpecialPricing.store.load();
                break;

            case 'pgeStock':
                var pgeStock = tabPanel.down('#pgeStock');
                var grdStock = pgeStock.down('#grdStock');
                if (grdStock.store.complete === true)
                {
                    grdStock.store.reload();
                    grdStock.getView().refresh();
                }
                else
                    grdStock.store.load();
                break;

            case 'pgeCommodity':
                var pgeCommodity = tabPanel.down('#pgeCommodity');
                var grdCommodityCost = pgeCommodity.down('#grdCommodityCost');
                if (grdCommodityCost.store.complete === true)
                    grdCommodityCost.getView().refresh();
                else
                    grdCommodityCost.store.load();
                break;

            case 'pgeAssembly':
                var pgeAssembly = tabPanel.down('#pgeAssembly');
                var grdAssembly = pgeAssembly.down('#grdAssembly');
                if (grdAssembly.store.complete === true)
                    grdAssembly.getView().refresh();
                else
                    grdAssembly.store.load();
                break;

            case 'pgeBundle':
                var pgeBundle = tabPanel.down('#pgeBundle');
                var grdBundle = pgeBundle.down('#grdBundle');
                if (grdBundle.store.complete === true)
                    grdBundle.getView().refresh();
                else
                    grdBundle.store.load();
                break;

            case 'pgeKit':
                var pgeKit = tabPanel.down('#pgeKit');
                var grdKit = pgeKit.down('#grdKit');
                if (grdKit.store.complete === true)
                    grdKit.getView().refresh();
                else
                    grdKit.store.load();
                break;

            case 'pgeFactory':
                var pgeFactory = tabPanel.down('#pgeFactory');
                var grdFactory = pgeFactory.down('#grdFactory');
                if (grdFactory.store.complete === true)
                    grdFactory.getView().refresh();
                else
                    grdFactory.store.load();

                var grdOwner = pgeFactory.down('#grdOwner');
                if (grdOwner.store.complete === true)
                    grdOwner.getView().refresh();
                else
                    grdOwner.store.load();

                if (grdFactory) {
                    grdFactory.getSelectionModel().select(0);
                }

                break;

        }
    },

    onInventoryTypeSelect: function(combo, record) {
        if (record.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) {
            if (record.get('strType') == 'Assembly/Blend') {
                current.set('strLotTracking', 'No');
            }

            else if (record.get('strType') == 'Bundle') {
                if (current.tblICItemUOMs()) {
                    Ext.Array.each(current.tblICItemUOMs().data.items, function (uom) {
                        if (!uom.dummy) {
                            uom.set('ysnAllowPurchase', false);
                        }
                    });
                }
            }
            current.set('strCategory', null);
            current.set('intCategoryId', null);
        }
    },

    onLotTrackingSelect: function(combo, records) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) {
            if (current.get('strType') == 'Assembly/Blend') {
                if (records[0].get('strLotTracking') !== 'No') {
                    combo.setValue('No');
                    iRely.Functions.showCustomDialog('warning', 'ok', '"Assembly/Blend" items should not be lot tracked. Select Inventory Type "Finished Goods" and use the Recipe screen.');
                }
            }
        }
    },

    onUOMUnitMeasureSelect: function (combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var win = grid.up('window');
        var plugin = grid.getPlugin('cepDetailUOM');
        var currentItem = win.viewModel.data.current;
        var current = plugin.getActiveRecord();
        var me = this;

        if (combo.column.itemId === 'colDetailUnitMeasure') {
            current.set('intUnitMeasureId', records[0].get('intUnitMeasureId'));
            if (currentItem.get('strType') === 'Bundle') {
                current.set('ysnAllowPurchase', false);
            }
            else {
                current.set('ysnAllowPurchase', true);
            }
            current.set('ysnAllowSale', true);
            current.set('tblICUnitMeasure', records[0]);

            var itemStore = grid.store;
            var stockUnit = itemStore.findRecord('ysnStockUnit', true);
            if (stockUnit) {
                var unitMeasureId = stockUnit.get('intUnitMeasureId');
                me.getConversionValue(current.get('intUnitMeasureId'), unitMeasureId, function(value) {
                    current.set('dblUnitQty', value);
                });
            }
        }
    },

    getConversionValue: function (unitMeasureId, stockUnitMeasureId, callback) {
        iRely.Msg.showWait('Converting units...');
        ic.utils.ajax({
            url: '../Inventory/api/UnitMeasure/Search',
            method: 'Get'  
        })
        .subscribe(
            function (successResponse) {
                var jsonData = Ext.decode(successResponse.responseText);
                var stockUnitConversions = _.findWhere(jsonData.data, { intUnitMeasureId: stockUnitMeasureId });
                if (stockUnitConversions) {
                    var stockConversion = _.findWhere(stockUnitConversions.vyuICGetUOMConversions,
                        { intUnitMeasureId: unitMeasureId, intStockUnitMeasureId: stockUnitMeasureId });
                    if (stockConversion) {
                        var dblConversionToStock = stockConversion.dblConversionToStock;
                        callback(dblConversionToStock);
                    }
                }
                iRely.Msg.close();
            },

            function (failureResponse) {
                 var jsonData = Ext.decode(failureResponse.responseText);
                 iRely.Msg.close();
                 iRely.Functions.showErrorDialog(jsonData.ExceptionMessage);
            }
        );
        // Ext.Ajax.request({
        //     timeout: 120000,
        //     url: '../Inventory/api/UnitMeasure/Search',
        //     method: 'get',
        //     success: function (response) {
        //         var jsonData = Ext.decode(response.responseText);
        //         var stockUnitConversions = _.findWhere(jsonData.data, { intUnitMeasureId: stockUnitMeasureId });
        //         if (stockUnitConversions) {
        //             var stockConversion = _.findWhere(stockUnitConversions.vyuICGetUOMConversions,
        //                 { intUnitMeasureId: unitMeasureId, intStockUnitMeasureId: stockUnitMeasureId });
        //             if (stockConversion) {
        //                 var dblConversionToStock = stockConversion.dblConversionToStock;
        //                 callback(dblConversionToStock);
        //             }
        //         }
        //         iRely.Msg.close();
        //     },
        //     failure: function (response) {
        //         var jsonData = Ext.decode(response.responseText);
        //         iRely.Msg.close();
        //         iRely.Functions.showErrorDialog(jsonData.ExceptionMessage);
        //     }
        // });
    },

    beforeUOMStockUnitCheckChange:function(obj, rowIndex, checked, eOpts ){
        if (obj.dataIndex === 'ysnStockUnit'){
            var grid = obj.up('grid');
            var win = obj.up('window');
            var current = win.viewModel.data.current;

            if (checked === false && current.get('intPatronageCategoryId') > 0)
                {
                   iRely.Functions.showErrorDialog("Stock Unit is required for Patronage Category.");
                   return false;
                }
        }
    },

    onUOMStockUnitCheckChange: function(obj, rowIndex, checked, eOpts ) {
        var me = this;
        if (obj.dataIndex === 'ysnStockUnit'){
            var grid = obj.up('grid');
            var win = obj.up('window');
            var current = grid.view.getRecord(rowIndex);
            var uomConversion = win.viewModel.storeInfo.uomConversion;
            ic.utils.ajax({
                url: '../Inventory/api/Item/CheckStockUnit',
                method: 'POST',
                params: {
                    ItemId: current.get('intItemId'),
                    ItemStockUnit: current.get('ysnStockUnit'),
                    ItemUOMId: current.get('intItemUOMId')
                }
            })
            .subscribe(
                function(successResponse) {
                    var jsonData = Ext.decode(successResponse.responseText);
                    if (!jsonData.success)
                    {
                       //iRely.Functions.showErrorDialog(jsonData.message.statusText);

                         var result = function (button) {
                            if (button === 'yes') {

                                    if (checked === true){
                                    var uoms = grid.store.data.items;
                                    if (uoms) {
                                        uoms.forEach(function(uom){
                                            if (uom === current){
                                                current.set('dblUnitQty', 1);
                                            }
                                            if (uom !== current){
                                                uom.set('ysnStockUnit', false);
                                                var unitMeasureId = current.get('intUnitMeasureId');
                                                me.getConversionValue(uom.get('intUnitMeasureId'), unitMeasureId, function (value) {

                                                    uom.set('dblUnitQty', value);
                                                });
                                            }
                                        });
                                    }
                                }
                                else {
                                    if (current){
                                        current.set('dblUnitQty', 1);
                                    }
                                }
                                ic.utils.ajax({
                                    url: '../Inventory/api/Item/ConvertItemToNewStockUnit',
                                    method: 'POST',
                                    params: {
                                        ItemId: current.get('intItemId'),
                                        ItemUOMId: current.get('intItemUOMId')
                                    }
                                })
                                .subscribe(
                                    function(successResponse) {
                                        var jsonData = Ext.decode(successResponse.responseText);
                                        if (!jsonData.success)
                                            {
                                                iRely.Functions.showErrorDialog(jsonData.message.statusText);

                                            }
                                        else
                                            {
                                                iRely.Functions.showCustomDialog('information', 'ok', 'Conversion to new stock unit has been completed.');
                                                var context = me.view.context;
                                                var vm = me.getViewModel();
                                                vm.data.current.dirty = false;
                                                context.screenMgr.toolbarMgr.provideFeedBack(iRely.Msg.SAVED);
                                            }
                                    },
                                    function(failureResponse) {
                                         var jsonData = Ext.decode(failureResponse.responseText);
                                        iRely.Functions.showErrorDialog('Connection Failed!');
                                    }
                                );

                            }

                             else
                                 {
                                     current.set('ysnStockUnit', false);
                                 }
                        };

                        if(current.get('ysnStockUnit') === false)
                            {
                                iRely.Functions.showErrorDialog("Item has already a transaction so Stock Unit is required.");
                                current.set('ysnStockUnit', true);
                            }
                        else
                            {
                                var msgBox = iRely.Functions;
                                msgBox.showCustomDialog(
                                msgBox.dialogType.WARNING,
                                msgBox.dialogButtonType.YESNOCANCEL,
                                "Item has transaction/s so changing stock unit will convert the following to new stock unit:<br> <br>Existing Stock <br>Cost & Prices <br> Existing Entries in Inventory Transaction Tables<br><br><br>Conversion to new stock unit will be automatically saved. <br><br>Do you want to continue?",
                                result
                               );
                            }
                    }

                else
                    {

                            if (checked === true){
                            var uoms = grid.store.data.items;
                            if (uoms) {
                                uoms.forEach(function(uom){
                                    if (uom === current){
                                        current.set('dblUnitQty', 1);
                                    }
                                    if (uom !== current){
                                        uom.set('ysnStockUnit', false);
                                        var unitMeasureId = current.get('intUnitMeasureId');
                                        me.getConversionValue(uom.get('intUnitMeasureId'), unitMeasureId, function (value) {
                                            uom.set('dblUnitQty', value);
                                        });
                                    }
                                });
                            }
                        }
                        else {
                            if (current){
                                current.set('dblUnitQty', 1);
                            }
                        }
                    }
                },
                function(failureResponse) {
                    var jsonData = Ext.decode(failureResponse.responseText);
                    iRely.Functions.showErrorDialog(jsonData.ExceptionMessage);
                }
            );
        }
    },

    // </editor-fold>

    // <editor-fold desc="Location Tab Methods and Event Handlers">

    subscribeLocationEvents: function (grid, scope) {
        var me = scope;
        var colLocationCostingMethod = grid.columns[4];
        if (colLocationCostingMethod) colLocationCostingMethod.renderer = me.CostingMethodRenderer;
    },

    getDefaultUOM: function(win) {
        return this.getDefaultUOMFromCommodity(win);
    },

    getDefaultUOMFromCommodity: function(win) {
        var vm = win.getViewModel();
        var cboCommodity = win.down('#cboCommodity');
        var intCommodityId = cboCommodity.getValue();

        if (!iRely.Functions.isEmpty(intCommodityId)) {
            var commodity = vm.storeInfo.commodityList.findRecord('intCommodityId', intCommodityId);
            if (commodity) {
                var uoms = commodity.data.tblICCommodityUnitMeasures;
                if(uoms && uoms.length > 0) {
                    var defUom = _.findWhere(uoms, { ysnDefault: true });
                    if(defUom) {
                        var itemUOMs = _.map(vm.data.current.tblICItemUOMs().data.items, function(rec) { return rec.data; });
                        var defaultUOM = _.findWhere(itemUOMs, { intUnitMeasureId: defUom.intUnitMeasureId });
                        if (defaultUOM) {
                            win.defaultUOM = defaultUOM;
                        }
                    }
                }
            }
        }
    },

    getDefaultUOMFroMCategory: function(win) {
        var vm = win.getViewModel();
        var cboCategory = win.down('#cboCategory');
        var intCategoryId = cboCategory.getValue();

        if (iRely.Functions.isEmpty(intCategoryId) === false){
            var category = vm.storeInfo.categoryList.findRecord('intCategoryId', intCategoryId);
            if (category) {
                var defaultCategoryUOM = category.getDefaultUOM();
                if (defaultCategoryUOM) {
                    var defaultUOM = Ext.Array.findBy(vm.data.current.tblICItemUOMs().data.items, function (row) {
                        if (defaultCategoryUOM.get('intUnitMeasureId') === row.get('intUnitMeasureId')) {
                            return true;
                        }
                    });
                    if (defaultUOM) {
                        win.defaultUOM = defaultUOM;
                    }
                }
            }
        }
    },

    onLocationDoubleClick: function(view, record, item, index, e, eOpts){
        var win = view.up('window');
        var me = win.controller;
        var vm = win.getViewModel();

        if (!record){
            iRely.Functions.showErrorDialog('Please select a location to edit.');
            return;
        }

        if (vm.data.current.phantom === true) {
            win.context.data.saveRecord({ successFn: function(batch, eOpts){
                me.openItemLocationScreen('edit', win, record);
                return;
            } });
        }
        else {
            win.context.data.validator.validateRecord({ window: win }, function(valid) {
                if (valid) {
                    me.openItemLocationScreen('edit', win, record);
                    return;
                }
            });
        }
    },

    onAddLocationClick: function(button, e, eOpts) {
        var win = button.up('window');
        var me = win.controller;
        var vm = win.getViewModel();

        me.getDefaultUOM(win);

        if (vm.data.current.phantom === true) {
            win.context.data.saveRecord({ successFn: function(batch, eOpts){
                me.openItemLocationScreen('new', win);
                return;
            } });
        }
        else {
            win.context.data.validator.validateRecord({ window: win }, function(valid) {
                if (valid) {
                    me.openItemLocationScreen('new', win);
                    return;
                }
            });
        }
    },

    onAddMultipleLocationClick: function(button, e, eOpts) {
        var win = button.up('window');
        var me = win.controller;
        var vm = win.getViewModel();
        var defaultFilters = '';

        Ext.Array.each(vm.data.current.tblICItemLocations().data.items, function(location) {
            defaultFilters += '&intLocationId<>' + location.get('intLocationId');
        });

        me.getDefaultUOM(win);

        var showAddScreen = function() {
            var search = i21.ModuleMgr.Search;
            search.scope = me;
            search.url = '../i21/api/CompanyLocation/Search';
            search.columns = [
                { dataIndex : 'intCompanyLocationId', text: 'Location Id', dataType: 'numeric', defaultSort : true, hidden : true, key : true},
                { dataIndex : 'strLocationName',text: 'Location Name', dataType: 'string', flex: 1 },
                { dataIndex : 'strLocationType',text: 'Location Type', dataType: 'string', flex: 1 }
            ];
            search.title = "Add Item Locations";
            search.showNew = false;
            search.on({
                scope: me,
                openselectedclick: function(button, e, result) {
                    var currentVM = this.getViewModel().data.current;
                    var win = this.getView();

                    Ext.each(result, function(location) {
                        var exists = Ext.Array.findBy(currentVM.tblICItemLocations().data.items, function (row) {
                            if (location.get('intCompanyLocationId') === row.get('intCompanyLocationId')) {
                                return true;
                            }
                        });
                        if (!exists) {
                            var defaultUOMId = null;
                            if (win.defaultUOM) {
                                defaultUOMId = win.defaultUOM.intItemUOMId;
                            }
                            var newRecord = {
                                intItemId: location.data.intItemId,
                                intLocationId: location.data.intCompanyLocationId,
                                intIssueUOMId: defaultUOMId,
                                intReceiveUOMId: defaultUOMId,
                                strLocationName: location.data.strLocationName,
                                intAllowNegativeInventory: 3,
                                intCostingMethod: 1,
                            };
                            currentVM.tblICItemLocations().add(newRecord);

                            var prices = currentVM.tblICItemPricings().data.items;
                            var exists = Ext.Array.findBy(prices, function (row) {
                                if (newRecord.intItemLocationId === row.get('intItemLocationId')) {
                                    return true;
                                }
                            });
                            if (!exists) {
                                var newPrice = Ext.create('Inventory.model.ItemPricing', {
                                    intItemId: newRecord.intItemId,
                                    intItemLocationId: newRecord.intItemLocationId,
                                    strLocationName: newRecord.strLocationName,
                                    dblAmountPercent: 0.00,
                                    dblSalePrice: 0.00,
                                    dblMSRPPrice: 0.00,
                                    strPricingMethod: 'None',
                                    dblLastCost: 0.00,
                                    dblStandardCost: 0.00,
                                    dblAverageCost: 0.00,
                                    dblEndMonthCost: 0.00,
                                    intAllowNegativeInventory: newRecord.intAllowNegativeInventory,
                                    intCostingMethod: newRecord.intCostingMethod,
                                    intSort: newRecord.intSort
                                });
                                currentVM.tblICItemPricings().add(newPrice);
                            }
                        }
                    });
                    search.close();
                    win.context.data.saveRecord();
                },
                openallclick: function() {
                    search.close();
                }
            });
            search.show();
        };

        // if (!win.context.data.hasChanges()) {
        //     showAddScreen();
        // }

        win.context.data.saveRecord({
            callbackFn: function(batch, options) {
                showAddScreen();
            }
        });
    },

    afterSave: function(win, me, batch, options) {
        win.view.context.data.reload();
    },

    onEditLocationClick: function(button, e, eOpts) {
        var win = button.up('window');
        var me = win.controller;
        var vm = win.getViewModel();
        var grd = button.up('grid');
        var selection = grd.getSelectionModel().getSelection();

        if (selection.length <= 0){
            iRely.Functions.showErrorDialog('Please select a location to edit.');
            return;
        }

        if (vm.data.current.phantom === true) {
            win.context.data.saveRecord({ successFn: function(batch, eOpts){
                me.openItemLocationScreen('edit', win, selection[0]);
            } });
        }
        else {
            win.context.data.validator.validateRecord({ window: win }, function(valid) {
                if (valid) {
                    me.openItemLocationScreen('edit', win, selection[0]);
                }
            });
        }
    },

    openItemLocationScreen: function (action, window, record) {
        var win = window;
        var screenName = 'Inventory.view.ItemLocation';

        var current = win.getViewModel().data.current;
        if (action === 'edit'){
            iRely.Functions.openScreen(screenName, {
                viewConfig: {
                    listeners: {
                        destroy: function() {
                            var grdLocation = win.down('#grdLocationStore');
                            var vm = win.getViewModel();
                            var itemId = vm.data.current.get('intItemId');
                            var filterItem = grdLocation.store.filters.items[0];

                            filterItem.setValue(itemId);
                            filterItem.config.value = itemId;
                            filterItem.initialConfig.value = itemId;
                            grdLocation.store.load({
                                scope: win,
                                callback: function(result) {
                                    if (result) {
                                        var me = this;
                                        Ext.Array.each(result, function (location) {
                                            var prices = me.getViewModel().data.current.tblICItemPricings().data.items;
                                            var exists = Ext.Array.findBy(prices, function (row) {
                                                if (location.get('intItemLocationId') === row.get('intItemLocationId')) {
                                                    return true;
                                                }
                                            });
                                            if (!exists) {
                                                var newPrice = Ext.create('Inventory.model.ItemPricing', {
                                                    intItemId : location.get('intItemId'),
                                                    intItemLocationId : location.get('intItemLocationId'),
                                                    strLocationName : location.get('strLocationName'),
                                                    dblAmountPercent : 0.00,
                                                    dblSalePrice : 0.00,
                                                    dblMSRPPrice : 0.00,
                                                    strPricingMethod : 'None',
                                                    dblLastCost : 0.00,
                                                    dblStandardCost : 0.00,
                                                    dblAverageCost : 0.00,
                                                    dblEndMonthCost : 0.00,
                                                    intSort : location.get('intSort')
                                                });
                                                me.getViewModel().data.current.tblICItemPricings().add(newPrice);
                                            }
                                        });
                                    }
                                }
                            });
                        }
                    }
                },
                itemId: current.get('intItemId'),
                locationId: record.get('intItemLocationId'),
                action: action
            });
        }
        else if (action === 'new') {
            iRely.Functions.openScreen(screenName, {
                viewConfig: {
                    listeners: {
                        destroy: function() {
                            var grdLocation = win.down('#grdLocationStore');
                            var vm = win.getViewModel();
                            var itemId = vm.data.current.get('intItemId');
                            var filterItem = grdLocation.store.filters.items[0];

                            filterItem.setValue(itemId);
                            filterItem.config.value = itemId;
                            filterItem.initialConfig.value = itemId;
                            grdLocation.store.load({
                                scope: win,
                                callback: function(result) {
                                    if (result) {
                                        var me = this;
                                        Ext.Array.each(result, function (location) {
                                            var prices = me.getViewModel().data.current.tblICItemPricings().data.items;
                                            var exists = Ext.Array.findBy(prices, function (row) {
                                                if (location.get('intItemLocationId') === row.get('intItemLocationId')) {
                                                    return true;
                                                }
                                            });
                                            if (!exists) {
                                                var newPrice = Ext.create('Inventory.model.ItemPricing', {
                                                    intItemId : location.get('intItemId'),
                                                    intItemLocationId : location.get('intItemLocationId'),
                                                    strLocationName : location.get('strLocationName'),
                                                    dblAmountPercent : 0.00,
                                                    dblSalePrice : 0.00,
                                                    dblMSRPPrice : 0.00,
                                                    strPricingMethod : 'None',
                                                    dblLastCost : 0.00,
                                                    dblStandardCost : 0.00,
                                                    dblAverageCost : 0.00,
                                                    dblEndMonthCost : 0.00,
                                                    intSort : location.get('intSort')
                                                });
                                                me.getViewModel().data.current.tblICItemPricings().add(newPrice);
                                            }
                                        });
                                    }
                                }
                            });
                        }
                    }
                },
                itemId: current.get('intItemId'),
                defaultUOM: win.defaultUOM,
                action: action
            });
        }
    },

    onCopyLocationSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var grid = combo.up('grid');
        var selection = grid.getSelectionModel().getSelection();
        var current = win.viewModel.data.current;
        
        ic.utils.ajax({
                timeout: 120000,
                url: '../Inventory/api/ItemLocation/Search',
                params: {
                    intItemLocationId: records[0].data.intItemLocationId
                },
                method: 'Get'  
            })
        .subscribe(
                function (successResponse) {
                    var json = JSON.parse(successResponse.responseText);
                    var copyLocation = json.data[0];
                    Ext.Array.each(selection, function (location) {
                        if (location.get('intItemLocationId') !== copyLocation.intItemLocationId) {
                            location.set('intVendorId', copyLocation.intVendorId);
                            location.set('strDescription', copyLocation.strDescription);
                            location.set('intCostingMethod', copyLocation.intCostingMethod);
                            location.set('strCostingMethod', copyLocation.strCostingMethod);
                            location.set('intAllowNegativeInventory', copyLocation.intAllowNegativeInventory);
                            //location.set('intSubLocationId', copyLocation.intSubLocationId);
                            //location.set('intStorageLocationId', copyLocation.intStorageLocationId);
                            location.set('intIssueUOMId', copyLocation.intIssueUOMId);
                            location.set('intReceiveUOMId', copyLocation.intReceiveUOMId);
                            location.set('intFamilyId', copyLocation.intFamilyId);
                            location.set('intClassId', copyLocation.intClassId);
                            location.set('intProductCodeId', copyLocation.intProductCodeId);
                            location.set('intFuelTankId', copyLocation.intFuelTankId);
                            location.set('strPassportFuelId1', copyLocation.strPassportFuelId2);
                            location.set('strPassportFuelId2', copyLocation.strPassportFuelId2);
                            location.set('strPassportFuelId3', copyLocation.strPassportFuelId3);
                            location.set('ysnTaxFlag1', copyLocation.ysnTaxFlag1);
                            location.set('ysnTaxFlag2', copyLocation.ysnTaxFlag2);
                            location.set('ysnTaxFlag3', copyLocation.ysnTaxFlag3);
                            location.set('ysnPromotionalItem', copyLocation.ysnPromotionalItem);
                            location.set('intMixMatchId', copyLocation.intMixMatchId);
                            location.set('ysnDepositRequired', copyLocation.ysnDepositRequired);
                            location.set('intDepositPLUId', copyLocation.intDepositPLUId);
                            location.set('intBottleDepositNo', copyLocation.intBottleDepositNo);
                            location.set('ysnQuantityRequired', copyLocation.ysnQuantityRequired);
                            location.set('ysnScaleItem', copyLocation.ysnScaleItem);
                            location.set('ysnFoodStampable', copyLocation.ysnFoodStampable);
                            location.set('ysnReturnable', copyLocation.ysnReturnable);
                            location.set('ysnPrePriced', copyLocation.ysnPrePriced);
                            location.set('ysnOpenPricePLU', copyLocation.ysnOpenPricePLU);
                            location.set('ysnLinkedItem', copyLocation.ysnLinkedItem);
                            location.set('strVendorCategory', copyLocation.strVendorCategory);
                            location.set('ysnCountBySINo', copyLocation.ysnCountBySINo);
                            location.set('strSerialNoBegin', copyLocation.strSerialNoBegin);
                            location.set('strSerialNoEnd', copyLocation.strSerialNoEnd);
                            location.set('ysnIdRequiredLiquor', copyLocation.ysnIdRequiredLiquor);
                            location.set('ysnIdRequiredCigarette', copyLocation.ysnIdRequiredCigarette);
                            location.set('intMinimumAge', copyLocation.intMinimumAge);
                            location.set('ysnApplyBlueLaw1', copyLocation.ysnApplyBlueLaw1);
                            location.set('ysnApplyBlueLaw2', copyLocation.ysnApplyBlueLaw2);
                            location.set('ysnCarWash', copyLocation.ysnCarWash);
                            location.set('intItemTypeCode', copyLocation.intItemTypeCode);
                            location.set('intItemTypeSubCode', copyLocation.intItemTypeSubCode);
                            location.set('ysnAutoCalculateFreight', copyLocation.ysnAutoCalculateFreight);
                            location.set('intFreightMethodId', copyLocation.intFreightMethodId);
                            location.set('dblFreightRate', copyLocation.dblFreightRate);
                            location.set('intShipViaId', copyLocation.intShipViaId);
                            location.set('intNegativeInventory', copyLocation.intNegativeInventory);
                            location.set('dblReorderPoint', copyLocation.dblReorderPoint);
                            location.set('dblMinOrder', copyLocation.dblMinOrder);
                            location.set('dblSuggestedQty', copyLocation.dblSuggestedQty);
                            location.set('dblLeadTime', copyLocation.dblLeadTime);
                            location.set('strCounted', copyLocation.strCounted);
                            location.set('intCountGroupId', copyLocation.intCountGroupId);
                            location.set('ysnCountedDaily', copyLocation.ysnCountedDaily);
                            location.set('strVendorId', copyLocation.strVendorId);
                            location.set('strCategory', copyLocation.strCategory);
                            location.set('strUnitMeasure', copyLocation.strUnitMeasure);
                        }
                    });

                    win.context.data.saveRecord();
				},
				function (failureResponse) {
                    var jsonData = Ext.decode(failureResponse.responseText);
                    iRely.Functions.showErrorDialog(jsonData.ExceptionMessage);
				}
        );
        // var filter = [
        //     {
        //         c: 'intItemLocationId',
        //         v: records[0].data.intItemLocationId,
        //         cj: 'and',
        //         g: 'g0'
        //     }
        // ];
        // Ext.Ajax.request({
        //     timeout: 120000,
        //     url: '../Inventory/api/ItemLocation/Search?page=1&start=0&limit=50&sort=[]&filter=' +
        //         JSON.stringify(filter),
        //     method: 'GET',
        //     success: function(response) {
        //         var json = JSON.parse(response.responseText);
        //         var copyLocation = json.data[0];
        //         Ext.Array.each(selection, function (location) {
        //             if (location.get('intItemLocationId') !== copyLocation.intItemLocationId) {
        //                 location.set('intVendorId', copyLocation.intVendorId);
        //                 location.set('strDescription', copyLocation.strDescription);
        //                 location.set('intCostingMethod', copyLocation.intCostingMethod);
        //                 location.set('strCostingMethod', copyLocation.strCostingMethod);
        //                 location.set('intAllowNegativeInventory', copyLocation.intAllowNegativeInventory);
        //                 //location.set('intSubLocationId', copyLocation.intSubLocationId);
        //                 //location.set('intStorageLocationId', copyLocation.intStorageLocationId);
        //                 location.set('intIssueUOMId', copyLocation.intIssueUOMId);
        //                 location.set('intReceiveUOMId', copyLocation.intReceiveUOMId);
        //                 location.set('intFamilyId', copyLocation.intFamilyId);
        //                 location.set('intClassId', copyLocation.intClassId);
        //                 location.set('intProductCodeId', copyLocation.intProductCodeId);
        //                 location.set('intFuelTankId', copyLocation.intFuelTankId);
        //                 location.set('strPassportFuelId1', copyLocation.strPassportFuelId2);
        //                 location.set('strPassportFuelId2', copyLocation.strPassportFuelId2);
        //                 location.set('strPassportFuelId3', copyLocation.strPassportFuelId3);
        //                 location.set('ysnTaxFlag1', copyLocation.ysnTaxFlag1);
        //                 location.set('ysnTaxFlag2', copyLocation.ysnTaxFlag2);
        //                 location.set('ysnTaxFlag3', copyLocation.ysnTaxFlag3);
        //                 location.set('ysnPromotionalItem', copyLocation.ysnPromotionalItem);
        //                 location.set('intMixMatchId', copyLocation.intMixMatchId);
        //                 location.set('ysnDepositRequired', copyLocation.ysnDepositRequired);
        //                 location.set('intDepositPLUId', copyLocation.intDepositPLUId);
        //                 location.set('intBottleDepositNo', copyLocation.intBottleDepositNo);
        //                 location.set('ysnQuantityRequired', copyLocation.ysnQuantityRequired);
        //                 location.set('ysnScaleItem', copyLocation.ysnScaleItem);
        //                 location.set('ysnFoodStampable', copyLocation.ysnFoodStampable);
        //                 location.set('ysnReturnable', copyLocation.ysnReturnable);
        //                 location.set('ysnPrePriced', copyLocation.ysnPrePriced);
        //                 location.set('ysnOpenPricePLU', copyLocation.ysnOpenPricePLU);
        //                 location.set('ysnLinkedItem', copyLocation.ysnLinkedItem);
        //                 location.set('strVendorCategory', copyLocation.strVendorCategory);
        //                 location.set('ysnCountBySINo', copyLocation.ysnCountBySINo);
        //                 location.set('strSerialNoBegin', copyLocation.strSerialNoBegin);
        //                 location.set('strSerialNoEnd', copyLocation.strSerialNoEnd);
        //                 location.set('ysnIdRequiredLiquor', copyLocation.ysnIdRequiredLiquor);
        //                 location.set('ysnIdRequiredCigarette', copyLocation.ysnIdRequiredCigarette);
        //                 location.set('intMinimumAge', copyLocation.intMinimumAge);
        //                 location.set('ysnApplyBlueLaw1', copyLocation.ysnApplyBlueLaw1);
        //                 location.set('ysnApplyBlueLaw2', copyLocation.ysnApplyBlueLaw2);
        //                 location.set('ysnCarWash', copyLocation.ysnCarWash);
        //                 location.set('intItemTypeCode', copyLocation.intItemTypeCode);
        //                 location.set('intItemTypeSubCode', copyLocation.intItemTypeSubCode);
        //                 location.set('ysnAutoCalculateFreight', copyLocation.ysnAutoCalculateFreight);
        //                 location.set('intFreightMethodId', copyLocation.intFreightMethodId);
        //                 location.set('dblFreightRate', copyLocation.dblFreightRate);
        //                 location.set('intShipViaId', copyLocation.intShipViaId);
        //                 location.set('intNegativeInventory', copyLocation.intNegativeInventory);
        //                 location.set('dblReorderPoint', copyLocation.dblReorderPoint);
        //                 location.set('dblMinOrder', copyLocation.dblMinOrder);
        //                 location.set('dblSuggestedQty', copyLocation.dblSuggestedQty);
        //                 location.set('dblLeadTime', copyLocation.dblLeadTime);
        //                 location.set('strCounted', copyLocation.strCounted);
        //                 location.set('intCountGroupId', copyLocation.intCountGroupId);
        //                 location.set('ysnCountedDaily', copyLocation.ysnCountedDaily);
        //                 location.set('strVendorId', copyLocation.strVendorId);
        //                 location.set('strCategory', copyLocation.strCategory);
        //                 location.set('strUnitMeasure', copyLocation.strUnitMeasure);
        //             }
        //         });

        //         win.context.data.saveRecord();
        //     }
        // });
    },

    CostingMethodRenderer: function (value, metadata, record) {
        var intMethod = record.get('intCostingMethod');
        var costingMethod = '';
        switch (intMethod) {
            case 1:
                costingMethod = 'AVG';
                break;
            case 2:
                costingMethod = 'FIFO';
                break;
            case 3:
                costingMethod = 'LIFO';
                break;
        }
        return costingMethod;
    },

    // </editor-fold>

    // <editor-fold desc="GL Accounts Tab Methods and Event Handlers">

    onGLAccountSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepAccount');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colGLAccountId') {
            current.set('intAccountId', records[0].get('intAccountId'));
            current.set('strDescription', records[0].get('strDescription'));
        }
        else if (combo.column.itemId === 'colGLAccountCategory') {
            current.set('intAccountCategoryId', records[0].get('intAccountCategoryId'));
            current.set('intAccountId', null);
            current.set('strAccountId', null);
            current.set('strDescription', null);
        }
    },

    onAddRequiredAccountClick: function(button, e, eOpts) {
        var win = button.up('window');
        var me = win.getController()
        var current = win.getViewModel().data.current;
        var accountCategoryList = win.getViewModel().storeInfo.accountCategoryList;

        switch (current.get('strType')) {
            case "Assembly/Blend":
            case "Inventory":
                me.addAccountCategory(current, 'AP Clearing', accountCategoryList);
                me.addAccountCategory(current, 'Inventory', accountCategoryList);
                me.addAccountCategory(current, 'Cost of Goods', accountCategoryList);
                me.addAccountCategory(current, 'Sales Account', accountCategoryList);
                me.addAccountCategory(current, 'Inventory In-Transit', accountCategoryList);
                me.addAccountCategory(current, 'Inventory Adjustment', accountCategoryList);
                //me.addAccountCategory(current, 'Auto-Variance', accountCategoryList);
                //me.addAccountCategory(current, 'Revalue Sold', accountCategoryList);
                //me.addAccountCategory(current, 'Write-Off Sold', accountCategoryList);
                break;

            case "Raw Material":
                me.addAccountCategory(current, 'AP Clearing', accountCategoryList);
                me.addAccountCategory(current, 'Inventory', accountCategoryList);
                me.addAccountCategory(current, 'Cost of Goods', accountCategoryList);
                me.addAccountCategory(current, 'Sales Account', accountCategoryList);
                me.addAccountCategory(current, 'Inventory In-Transit', accountCategoryList);
                me.addAccountCategory(current, 'Inventory Adjustment', accountCategoryList);
                me.addAccountCategory(current, 'Work In Progress', accountCategoryList);
                //me.addAccountCategory(current, 'Auto-Variance', accountCategoryList);
                //me.addAccountCategory(current, 'Revalue Sold', accountCategoryList);
                //me.addAccountCategory(current, 'Write-Off Sold', accountCategoryList);
                break;

            case "Finished Good":
                me.addAccountCategory(current, 'Inventory', accountCategoryList);
                me.addAccountCategory(current, 'Cost of Goods', accountCategoryList);
                me.addAccountCategory(current, 'Sales Account', accountCategoryList);
                me.addAccountCategory(current, 'Inventory In-Transit', accountCategoryList);
                me.addAccountCategory(current, 'Inventory Adjustment', accountCategoryList);
                me.addAccountCategory(current, 'Work In Progress', accountCategoryList);
                //me.addAccountCategory(current, 'Auto-Variance', accountCategoryList);
                //me.addAccountCategory(current, 'Revalue Sold', accountCategoryList);
                //me.addAccountCategory(current, 'Write-Off Sold', accountCategoryList);
                break;

            case "Other Charge":
                me.addAccountCategory(current, 'AP Clearing', accountCategoryList);
                me.addAccountCategory(current, 'Other Charge Income', accountCategoryList);
                me.addAccountCategory(current, 'Other Charge Expense', accountCategoryList);
                break;

            case "Non-Inventory":
            case "Service":
                me.addAccountCategory(current, 'General', accountCategoryList);
                break;

            case "Software":
                me.addAccountCategory(current, 'General', accountCategoryList);
                me.addAccountCategory(current, 'Maintenance Sales', accountCategoryList);
                break;

            case "Bundle":
            case "Kit":
                me.addAccountCategory(current, 'Sales Account', accountCategoryList);
                break;

            case "Comment":
                break;

            default:
                iRely.Functions.showErrorDialog('Please select an Inventory Type.');
                break;
        }

    },

    addAccountCategory: function(current, category, categoryList) {
        if (categoryList) {
            var exists = Ext.Array.findBy(current.tblICItemAccounts().data.items, function (row) {
                if (category === row.get('strAccountCategory')) {
                    return true;
                }
            });
            if (!exists) {
                var category = categoryList.findRecord('strAccountCategory', category);
                if(category) {
                    var newItemAccount = Ext.create('Inventory.model.ItemAccount', {
                        intItemId: current.get('intItemId'),
                        intAccountCategoryId: category.get('intAccountCategoryId'),
                        strAccountCategory: category.get('strAccountCategory')
                    });
                    current.tblICItemAccounts().add(newItemAccount);
                }
            }
        }
    },

    // </editor-fold>

    // <editor-fold desc="Point Of Sale Tab Methods and Event Handlers">

    onPOSCategorySelect: function(combo, records, eOpts) {
    if (records.length <= 0)
        return;

    var grid = combo.up('grid');
    var plugin = grid.getPlugin('cepPOSCategory');
    var current = plugin.getActiveRecord();

    if (combo.column.itemId === 'colPOSCategoryName')
    {
        current.set('intCategoryId', records[0].get('intCategoryId'));
    }
},

    // </editor-fold>

    // <editor-fold desc="Cross Reference Tab Methods and Event Handlers">

    onCustomerXrefSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepCustomerXref');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colCustomerXrefLocation')
        {
            current.set('intItemLocationId', records[0].get('intItemLocationId'));
        }
        else if (combo.column.itemId === 'colCustomerXrefCustomer') {
            current.set('intCustomerId', records[0].get('intEntityCustomerId'));
        }
    },

    onVendorXrefSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepVendorXref');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colVendorXrefLocation'){
            current.set('intItemLocationId', records[0].get('intItemLocationId'));
        }
        else if (combo.column.itemId === 'colVendorXrefVendor') {
            current.set('intVendorId', records[0].get('intEntityVendorId'));
        }
        else if (combo.column.itemId === 'colVendorXrefUnitMeasure') {
            current.set('intItemUnitMeasureId', records[0].get('intItemUOMId'));
        }
    },

    // </editor-fold>

    // <editor-fold desc="Contract Item Tab Methods and Event Handlers">

    onContractItemSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepContractItem');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colContractLocation'){
            current.set('intItemLocationId', records[0].get('intItemLocationId'));
        }
        else if (combo.column.itemId === 'colContractOrigin') {
            current.set('intCountryId', records[0].get('intCountryID'));
        }
    },

    onDocumentSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepDocument');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colDocument'){
            current.set('intDocumentId', records[0].get('intDocumentId'));
        }
    },

    onCertificationSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepCertification');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colCertification'){
            current.set('intCertificationId', records[0].get('intCertificationId'));
        }
    },

    // </editor-fold>

    // <editor-fold desc="Motor Fuel Tax Tab Methods and Event Handlers">

    onMotorFuelTaxSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepMotorFuelTax');
        var current = plugin.getActiveRecord();

        if (combo.itemId === 'cboTaxAuthorityCode'){
            current.set('strTaxAuthorityDescription', records[0].get('strDescription'));
        }

        else if (combo.itemId === 'cboProductCode') {
            current.set('strProductDescription', records[0].get('strDescription'));
            current.set('strProductCodeGroup', records[0].get('strProductCodeGroup'));
        }
    },

    // </editor-fold>

    // <editor-fold desc="Pricing Tab Methods and Event Handlers">

    onPricingLocationSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var grid = combo.up('grid');
        var grdPricing = win.down('#grdPricing');
        var grdUnitOfMeasure = win.down('#grdUnitOfMeasure');
        var plugin = grid.getPlugin('cepPricing');
        var current = plugin.getActiveRecord();

        if (combo.itemId === 'cboPricingLocation'){
            current.set('intItemLocationId', records[0].get('intItemLocationId'));
            current.set('intCompanyLocationId', records[0].get('intCompanyLocationId'));
        }
    },

    onPricingLevelSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var grid = combo.up('grid');
        var grdPricing = win.down('#grdPricing');
        var grdUnitOfMeasure = win.down('#grdUnitOfMeasure');
        var plugin = grid.getPlugin('cepPricingLevel');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colPricingLevelLocation'){
            current.set('intItemLocationId', records[0].get('intItemLocationId'));
            current.set('intLocationId', records[0].get('intLocationId'));
        }
        else if (combo.column.itemId === 'colPricingLevelUOM') {
            current.set('intItemUnitMeasureId', records[0].get('intItemUOMId'));
            current.set('strUPC', records[0].get('strUpcCode'));

            if (grdUnitOfMeasure.store){
                var record = grdUnitOfMeasure.store.findRecord('intItemUOMId', records[0].get('intItemUOMId'));
                if (record){
                    current.set('dblUnit', record.get('dblUnitQty'));
                }
            }
        }
        else if (combo.column.itemId === 'colPricingLevelCurrency'){
            current.set('intCurrencyId', records[0].get('intCurrencyID'));

            if (records[0].get('intCurrencyID') !== i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId')) {
                current.set('dblUnitPrice', 0);
            }
        }
    },

    onSpecialPricingBeforeQuery: function (obj) {
        if (obj.combo) {
            var store = obj.combo.store;
            var win = obj.combo.up('window');
            var grid = win.down('#grdSpecialPricing');
            if (store) {
                store.remoteFilter = true;
                store.remoteSort = true;
            }

            if (obj.combo.itemId === 'cboSpecialPricingDiscountBy') {
                var promotionType = grid.selection.data.strPromotionType;
                store.clearFilter();
                store.filterBy(function (rec, id) {
                    if (promotionType !== 'Terms Discount' && promotionType !== '') {
                        if (rec.get('strDescription') !== 'Terms Rate')
                            return true;
                        return false;
                    }
                    return true;
                });
            }
        }
    },
    
    onSpecialPricingSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var grdPricing = win.down('#grdPricing');
        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepSpecialPricing');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colSpecialPricingLocation'){
            current.set('intItemLocationId', records[0].get('intItemLocationId'));

            if (grdPricing.store){
                var record = grdPricing.store.findRecord('intItemLocationId', records[0].get('intItemLocationId'));
                if (record){
                    current.set('dblUnitAfterDiscount', record.get('dblSalePrice'));
                }
            }
            current.set('dtmBeginDate', i21.ModuleMgr.Inventory.getTodayDate());
        }
        else if (combo.column.itemId === 'colSpecialPricingUnit') {
            current.set('intItemUnitMeasureId', records[0].get('intItemUOMId'));
            current.set('strUPC', records[0].get('strUpcCode'));
            current.set('dblUnit', records[0].get('dblUnitQty'));

            if (grdPricing.store){
                var record = grdPricing.store.findRecord('intItemLocationId', current.get('intItemLocationId'));
                if (record){
                    current.set('dblUnitAfterDiscount', (records[0].get('dblUnitQty') * record.get('dblSalePrice')));
                }
            }
        }
        else if (combo.column.itemId === 'colSpecialPricingDiscountBy') {
            if (records.get('strDescription') === 'Percent') {
                var discount = current.get('dblUnitAfterDiscount') * current.get('dblDiscount') / 100;
                var discPrice = current.get('dblUnitAfterDiscount') - discount;
                current.set('dblDiscountedPrice', discPrice);
            }
            else if (records.get('strDescription') === 'Amount') {
                var discount = current.get('dblDiscount');
                var discPrice = current.get('dblUnitAfterDiscount') - discount;
                current.set('dblDiscountedPrice', discPrice);
            }
            else if (records.get('strDescription') === 'Terms Rate') {
                var discount = current.get('dblUnitAfterDiscount') * current.get('dblDiscount') / 100;
                var discPrice = current.get('dblUnitAfterDiscount') - discount;
                current.set('dblDiscountedPrice', discPrice);
            }
            else { current.set('dblDiscountedPrice', 0.00); }
        }

        else if (combo.column.itemId === 'colSpecialPricingCurrency'){
            current.set('intCurrencyId', records[0].get('intCurrencyID'));
        }
    },

    /* TODO: Create unit test for getPricingLevelUnitPrice */
    getPricingLevelUnitPrice: function (price) {
        var unitPrice = price.salePrice;
        var msrpPrice = price.msrpPrice;
        var standardCost = price.standardCost;
        var amt = price.amount;
        var qty = 1 //This will now default to 1 based on IC-2642.
        var retailPrice = 0;
        switch (price.pricingMethod) {
            case 'Discount Retail Price':
                unitPrice = unitPrice - (unitPrice * (amt / 100));
                retailPrice = unitPrice * qty
                break;
            case 'MSRP Discount':
                msrpPrice = msrpPrice - (msrpPrice * (amt / 100));
                retailPrice = msrpPrice * qty
                break;
            case 'Percent of Margin (MSRP)':
                var percent = amt / 100;
                unitPrice = ((msrpPrice - standardCost) * percent) + standardCost;
                retailPrice = unitPrice * qty;
                break;
            case 'Fixed Dollar Amount':
                unitPrice = (standardCost + amt);
                retailPrice = unitPrice * qty;
                break;
            case 'Markup Standard Cost':
                var markup = (standardCost * (amt / 100));
                unitPrice = (standardCost + markup);
                retailPrice = unitPrice * qty;
                break;
            case 'Percent of Margin':
                unitPrice = (standardCost / (1 - (amt / 100)));
                retailPrice = unitPrice * qty;
                break;
            case 'None':
                break;
            default:
                retailPrice = 0;
                break;
        }
        return retailPrice;
    },

    /* TODO:Create unit test for getSalePrice */
    getSalePrice: function (price, errorCallback) {
        var salePrice = 0;
        switch (price.pricingMethod) {
            case "None":
                salePrice = price.cost;
                break;
            case "Fixed Dollar Amount":
                salePrice = price.cost + price.amount;
                break;
            case "Markup Standard Cost":
                salePrice = (price.cost * (price.amount / 100)) + price.cost;
                break;
            case "Percent of Margin":
                salePrice = price.amount < 100 ? (price.cost / (1 - (price.amount / 100))) : errorCallback();
                break;
        }
        return salePrice;
    },

    updatePricing: function (pricing, data, validationCallback) {
        var me = this;
        var salePrice = me.getSalePrice({
            cost: data.standardCost,
            amount: data.amount,
            pricingMethod: data.pricingMethod
        }, validationCallback);

        if (iRely.Functions.isEmpty(data.pricingMethod) || data.pricingMethod === 'None') {
            pricing.set('dblAmountPercent', 0.00);
        }
        pricing.set('dblSalePrice', salePrice);
    },

    updatePricingLevel: function (item, pricing, data) {
        var me = this;
        _.each(item.tblICItemPricingLevels().data.items, function (p) {
            if (p.data.intItemLocationId === pricing.data.intItemLocationId 
                && p.data.intCurrencyId === i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId')) {
                var retailPrice = me.getPricingLevelUnitPrice({
                    pricingMethod: p.data.strPricingMethod,
                    salePrice: data.unitPrice,
                    msrpPrice: data.msrpPrice,
                    standardCost: data.standardCost,
                    amount: p.data.dblAmountRate,
                    qty: p.data.dblUnit
                });
                p.set('dblUnitPrice', retailPrice);
            }
        });
    },

    onPricingStandardCostChange: function (e, newValue, oldValue) {
        var vm = this.view.viewModel;
        var currentItem = vm.data.current;
        var cep = e.ownerCt.editingPlugin;
        var currentPricing = cep.activeRecord;
        var me = this;
        var win = cep.grid.up('window');
        var grdPricing = win.down('#grdPricing');

        var data = {
            unitPrice: currentPricing.data.dblSalePrice,
            msrpPrice: currentPricing.data.dblMSRPPrice,
            standardCost: newValue,
            pricingMethod: currentPricing.data.strPricingMethod,
            amount: currentPricing.data.dblAmountPercent
        };
        this.updatePricing(currentPricing, data, function () {
            win.context.data.validator.validateGrid(grdPricing);
        });
        this.updatePricingLevel(currentItem, currentPricing, data);
    },

    onEditPricingLevel: function (editor, context, eOpts) {
        var me = this;
        if (context.field === 'strPricingMethod' || context.field === 'dblAmountRate' || context.field === 'strCurrency') {
            if (context.record) {
                var win = context.grid.up('window');
                var grdPricing = win.down('#grdPricing');
                var pricingItems = grdPricing.store.data.items;
                var pricingMethod = context.record.get('strPricingMethod');
                var amount = context.record.get('dblAmountRate');

                if (context.field === 'strPricingMethod') {
                    pricingMethod = context.value;
                }
                else if (context.field === 'dblAmountRate') {
                    amount = context.value;
                }

                if (pricingItems) {
                    var locationId = context.record.get('intItemLocationId');
                    if (locationId > 0) {
                        var selectedLoc = Ext.Array.findBy(pricingItems, function (row) {
                            if (row.get('intItemLocationId') === locationId) {
                                return true;
                            }
                        });
                        if (selectedLoc) {
                            var unitPrice = selectedLoc.get('dblSalePrice');
                            var msrpPrice = selectedLoc.get('dblMSRPPrice');
                            var standardCost = selectedLoc.get('dblStandardCost');
                            var qty = context.record.get('dblUnit');
                            var retailPrice = me.getPricingLevelUnitPrice({
                                pricingMethod: pricingMethod,
                                salePrice: unitPrice,
                                msrpPrice: msrpPrice,
                                standardCost: standardCost,
                                amount: amount,
                                qty: qty
                            });
                            if (context.record.get('intCurrencyId') === i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId')) {
                                context.record.set('dblUnitPrice', retailPrice);
                            }
                            else {
                                if (context.field === 'strCurrency') {
                                    context.record.set('dblUnitPrice', 0);
                                }
                            }
                        }
                    }
                }
            }
        }

        if (iRely.Functions.isEmpty(context.record.get('strCurrency'))) {
            context.record.set('intCurrencyId', i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId'));
            context.record.set('strCurrency', i21.ModuleMgr.SystemManager.getCompanyPreference('strDefaultCurrency'));
        }
    },

     onEditSpecialPricing: function (editor, context, eOpts) { 
         
        if (iRely.Functions.isEmpty(context.record.get('strCurrency'))) {
            context.record.set('intCurrencyId', i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId'));
            context.record.set('strCurrency', i21.ModuleMgr.SystemManager.getCompanyPreference('strDefaultCurrency'));
        }
     },

    onEditPricing: function (editor, context, eOpts) {
        var me = this;
        if (context.field === 'strPricingMethod' || context.field === 'dblAmountPercent' || context.field === 'dblStandardCost') {
            if (context.record) {
                var win = context.grid.up('window');
                var grdPricing = win.down('#grdPricing');
                var pricingMethod = context.record.get('strPricingMethod');
                var amount = context.record.get('dblAmountPercent');
                var cost = context.record.get('dblStandardCost');

                if (context.field === 'strPricingMethod') {
                    pricingMethod = context.value;
                }
                else if (context.field === 'dblAmountPercent') {
                    amount = context.value;
                }
                else if (context.field === 'dblStandardCost') {
                    cost = context.value;
                }

                var data = {
                    standardCost: cost,
                    pricingMethod: pricingMethod,
                    amount: amount
                };
                this.updatePricing(context.record, data, function () {
                    win.context.data.validator.validateGrid(grdPricing);
                });
            }
        }
    },

    onPricingGridColumnBeforeRender: function(column) {
        "use strict";
        if (!column) return false;
        var me = this,
            win = column.up('window');

        // Show or hide the editor based on the selected Field type.
        column.getEditor = function(record) {
            var vm = win.viewModel;
            if (!record) return false;
            var columnId = column.itemId;

            switch (columnId) {
                case 'colPricingAmount' :
                    if (record.get('strPricingMethod') === 'None') {
                        return false;
                    }
                    else {
                        return Ext.create('Ext.grid.CellEditor', {
                            field: Ext.widget({
                                xtype: 'numberfield',
                                currencyField: true
                            })
                        });
                    }

                    break;
            }
        };
    },

    // </editor-fold>

    // <editor-fold desc="Stock Tab Methods and Event Handlers">

    onRenderStockUOM: function(value, metadata, record) {
        var grid = metadata.column.up('grid');
        var win = grid.up('window');
        var currentMaster = win.viewModel.data.current;

        if (record) {
            if(currentMaster) {
                if (currentMaster.tblICItemUOMs()) {
                    var itemUOMs = currentMaster.tblICItemUOMs().data.items;
                    var stockUnit = Ext.Array.findBy(itemUOMs, function(row) {
                        if (row.get('ysnStockUnit') === true) return true;
                    })
                    if (stockUnit) {
                        return stockUnit.get('strUnitMeasure');
                    }
                }
            }
        }
    },

    // </editor-fold>

    // <editor-fold desc="Bundle Tab Methods and Event Handlers">

    onBundleSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepBundle');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colBundleUOM'){
            current.set('dblUnit', records[0].get('dblUnitQty'));
        }
        else if (combo.column.itemId === 'colBundleItem'){
            current.set('strDescription', records[0].get('strDescription'));
        }

    },

    // </editor-fold>

    // <editor-fold desc="Assembly Tab Methods and Event Handlers">

    onAssemblySelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepAssembly');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colAssemblyComponent'){
            current.set('intAssemblyItemId', records[0].get('intItemId'));
            current.set('strItemDescription', records[0].get('strDescription'));
        }
        else if (combo.column.itemId === 'colAssemblyUOM') {
            current.set('intItemUnitMeasureId', records[0].get('intItemUOMId'));
            current.set('dblUnit', records[0].get('dblUnitQty'));
        }
    },

    // </editor-fold>

    // <editor-fold desc="Kit Details Tab Methods and Event Handlers">

    onKitSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepKitDetail');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colKitItem'){
            current.set('intItemId', records[0].get('intItemId'));
            current.set('strDescription', records[0].get('strDescription'));
        }
        else if (combo.column.itemId === 'colKitItemUOM') {
            current.set('intItemUnitMeasureId', records[0].get('intItemUOMId'));
        }
    },

    // </editor-fold>

    // <editor-fold desc="Factory & Lines Tab Methods and Event Handlers">

    onManufacturingCellSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var controller = win.getController();
        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepManufacturingCell');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colCellName'){
            current.set('intPreference', controller.getNewPreferenceNo(grid.store));
        }
    },

    getNewPreferenceNo: function(store) {
        "use strict";

        var max = 0;
        if (!store || !store.isStore) {
            return max;
        }

        var filterRecords = store.data;

        // Get the max value from the filtered records.
        if (filterRecords && filterRecords.length > 0) {
            // loop through the filtered record to get the max value for intFieldNo.
            filterRecords.each(function (record) {
                //noinspection JSUnresolvedVariable
                if (filterRecords.dummy !== true) {
                    var intFieldNo = record.get('intPreference');
                    if (max <= intFieldNo) {
                        max = intFieldNo + 1;
                    }
                }
            });
        }
        return max;
    },

    onManufacturingCellDefaultCheckChange: function (obj, rowIndex, checked, eOpts) {
        if (obj.dataIndex === 'ysnDefault'){
            var grid = obj.up('grid');
            var current = grid.view.getRecord(rowIndex);

            if (checked === true){
                var cells = grid.store.data.items;
                if (cells) {
                    cells.forEach(function(cell){
                        if (cell !== current){
                            cell.set('ysnDefault', false);
                        }
                    });
                }
            }
        }
    },

    // </editor-fold>

    onSpecialKeyTab: function(component, e, eOpts) {
        var win = component.up('window');
        if(win) {
            if (e.getKey() === Ext.event.Event.TAB) {
                var gridObj = win.query('#grdUnitOfMeasure')[0],
                    sel = gridObj.getStore().getAt(0);

                if(sel && gridObj){
                    gridObj.setSelection(sel);

                    var task = new Ext.util.DelayedTask(function(){
                        gridObj.plugins[0].startEditByPosition({
                            row: 0,
                            column: 1
                        });
                        var cboDetailUnitMeasure = gridObj.query('#cboDetailUnitMeasure')[0];
                        cboDetailUnitMeasure.focus();
                    });

                    task.delay(10);
                }
            }
        }
    },

    onSpecialPricingDiscountChange: function(obj, newValue, oldValue, eOpts){
        var grid = obj.up('grid');
        var plugin = grid.getPlugin('cepSpecialPricing');
        var record = plugin.getActiveRecord();

        if (obj.itemId === 'txtSpecialPricingDiscount') {
            if (record.get('strDiscountBy') === 'Percent') {
                var discount = record.get('dblUnitAfterDiscount') * newValue / 100;
                var discPrice = record.get('dblUnitAfterDiscount') - discount;
                record.set('dblDiscountedPrice', discPrice);
            }
            else if (record.get('strDiscountBy') === 'Amount') {
                var discount = newValue;
                var discPrice = record.get('dblUnitAfterDiscount') - discount;
                record.set('dblDiscountedPrice', discPrice);
            }
            else if (record.get('strDiscountBy') === 'Terms Rate') {
                var discount = record.get('dblUnitAfterDiscount') * newValue / 100;
                var discPrice = record.get('dblUnitAfterDiscount') - discount;
                record.set('dblDiscountedPrice', discPrice);
            }
            else { record.set('dblDiscountedPrice', 0.00); }
        }
        else if (obj.itemId === 'txtSpecialPricingUnitPrice') {
            if (record.get('strDiscountBy') === 'Percent') {
                var discount = newValue * record.get('dblDiscount') / 100;
                var discPrice = newValue - discount;
                record.set('dblDiscountedPrice', discPrice);
            }
            else if (record.get('strDiscountBy') === 'Amount') {
                var discount = record.get('dblDiscount');
                var discPrice = newValue - discount;
                record.set('dblDiscountedPrice', discPrice);
            }
            else if (record.get('strDiscountBy') === 'Terms Rate') {
                var discount = newValue * record.get('dblDiscount') / 100;
                var discPrice = newValue - discount;
                record.set('dblDiscountedPrice', discPrice);
            }
            else { record.set('dblDiscountedPrice', 0.00); }
        }
    },

   /* onUpcChange: function(obj, newValue, oldValue, eOpts) {
        var grid = obj.up('grid');
        var plugin = grid.getPlugin('cepDetailUOM');
        var record = plugin.getActiveRecord();

        if (obj.itemId === 'txtShortUPCCode') {
            if (!iRely.Functions.isEmpty(newValue))
            {
                return record.set('strLongUPCCode', i21.ModuleMgr.Inventory.getFullUPCString(newValue))
            }
        }
        else if (obj.itemId === 'txtFullUPCCode') {
            if (!iRely.Functions.isEmpty(newValue))
            {
                return record.set('strUpcCode', i21.ModuleMgr.Inventory.getShortUPCString(newValue))
            }
        }

    },*/

    onDuplicateClick: function(button) {
        var win = button.up('window');
        var context = win.context;
        var current = win.viewModel.data.current;

        if (current) {
            iRely.Msg.showWait('Duplicating item...');
            ic.utils.ajax({
                timeout: 120000,
                url: '../Inventory/api/Item/DuplicateItem',
                params: {
                    ItemId: current.get('intItemId')
                },
                method: 'Get'  
            })
            .finally(function() { iRely.Msg.close(); })
            .subscribe(
                function (successResponse) {
				    var jsonData = Ext.decode(successResponse.responseText);
                    context.configuration.store.addFilter([{ column: 'intItemId', value: jsonData.message.id }]);
                    context.configuration.paging.moveFirst();
				},
				function (failureResponse) {
                    var jsonData = Ext.decode(failureResponse.responseText);
                    iRely.Functions.showErrorDialog(jsonData.ExceptionMessage);
				}
            );
            // Ext.Ajax.request({
            //     timeout: 120000,
            //     url: '../Inventory/api/Item/DuplicateItem?ItemId=' + current.get('intItemId'),
            //     method: 'GET',
            //     success: function(response){
            //         var jsonData = Ext.decode(response.responseText);
            //         context.configuration.store.addFilter([{ column: 'intItemId', value: jsonData.id }]);
            //         context.configuration.paging.moveFirst();
            //     }
            // });
        }
    },

    onBuildAssemblyClick: function(button) {
        var win = button.up('window');
        var current = win.viewModel.data.current;

        if (current) {
            var screenName = 'Inventory.view.BuildAssemblyBlend';

            Ext.require([
                screenName,
                    screenName + 'ViewModel',
                    screenName + 'ViewController'
            ], function () {
                var screen = 'ic' + screenName.substring(screenName.indexOf('view.') + 5, screenName.length);
                var view = Ext.create(screenName, { controller: screen.toLowerCase(), viewModel: screen.toLowerCase() });
                var controller = view.getController();
                controller.show({
                    itemId: current.get('intItemId'),
                    action: 'new',
                    itemSetup: current.tblICItemAssemblies().data.items
                });
            });
        }
    },

    onLoadUOMClick: function(button) {
        // No longer implemented
    },

    onCommoditySelect: function(combo, record) {
        this.loadUOM(combo);
    },

    loadUOM: function(combo) {
        var win = combo.up('window');
        var current = win.viewModel.data.current;
        var grid = win.down('#grdUnitOfMeasure');

        if (current) {
            if (!iRely.Functions.isEmpty(current.get('intCommodityId')) && grid.getStore().data.length <= 1) {
                var cbo = win.down('#cboCommodity');
                var store = cbo.getStore();
                if (store) {
                    var commodity = store.findRecord(cbo.valueField, cbo.getValue());
                    if (commodity) {
                        var uoms = commodity.get('tblICCommodityUnitMeasures');
                        if (uoms) {
                            if (uoms.length > 0) {
                                current.tblICItemUOMs().removeAll();
                                uoms.forEach(function(uom){
                                    var newItemUOM = Ext.create('Inventory.model.ItemUOM', {
                                        intItemId : current.get('intItemId'),
                                        strUnitMeasure: uom.strUnitMeasure,
                                        intUnitMeasureId : uom.intUnitMeasureId,
                                        dblUnitQty : uom.dblUnitQty,
                                        ysnStockUnit : uom.ysnStockUnit,
                                        ysnAllowPurchase : true,
                                        ysnAllowSale : true,
                                        dblLength : 0.00,
                                        dblWidth : 0.00,
                                        dblHeight : 0.00,
                                        dblVolume : 0.00,
                                        dblMaxQty : 0.00,
                                        intSort : uom.intSort
                                    });
                                    current.tblICItemUOMs().add(newItemUOM);
                                });
                                grid.gridMgr.newRow.add();
                            }
                        }
                    }
                }
            }
        }
    },


    //<editor-fold desc="Search Drilldown Events">

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

    //</editor-fold>

    //<editor-fold desc="Combo Box Drilldown Events">

    onManufacturerDrilldown: function(combo) {
        iRely.Functions.openScreen('Inventory.view.Manufacturer', {viewConfig: { modal: true }});
    },

    onBrandDrilldown: function(combo) {
        iRely.Functions.openScreen('Inventory.view.Brand', {viewConfig: { modal: true }});
    },

    onCommodityDrilldown: function(combo) {
        if (iRely.Functions.isEmpty(combo.getValue())) {
            iRely.Functions.openScreen('Inventory.view.Commodity', { action: 'new', viewConfig: { modal: true }});
        }
        else {
            iRely.Functions.openScreen('Inventory.view.Commodity', combo.getValue());
        }
    },

    onCategoryDrilldown: function(combo) {
        if (iRely.Functions.isEmpty(combo.getValue())) {
            iRely.Functions.openScreen('Inventory.view.Category', { action: 'new', viewConfig: { modal: true }});
        }
        else {
            iRely.Functions.openScreen('Inventory.view.Category', combo.getValue());
        }
    },

    onMedicationTaxDrilldown: function(combo) {
        if (iRely.Functions.isEmpty(combo.getValue())) {
            iRely.Functions.openScreen('Inventory.view.InventoryTag', { action: 'new', viewConfig: { modal: true }});
        }
        else {
            iRely.Functions.openScreen('Inventory.view.InventoryTag', combo.getValue());
        }
    },

    onIngredientTagDrilldown: function(combo) {
        if (iRely.Functions.isEmpty(combo.getValue())) {
            iRely.Functions.openScreen('Inventory.view.InventoryTag', { action: 'new', viewConfig: { modal: true }});
        }
        else {
            iRely.Functions.openScreen('Inventory.view.InventoryTag', combo.getValue());
        }
    },

    onFuelCategoryDrilldown: function(combo) {
        iRely.Functions.openScreen('Inventory.view.FuelCategory', {viewConfig: { modal: true }});
    },

    onPatronageDrilldown: function(combo) {
        iRely.Functions.openScreen('Patronage.view.PatronageCategory', {viewConfig: { modal: true }});
    },

    onPatronageDirectDrilldown: function(combo) {
        iRely.Functions.openScreen('Patronage.view.PatronageCategory', {viewConfig: { modal: true }});
    },

    //</editor-fold>

    //<editor-fold desc="Header Drilldown Events">

    onUOMHeaderClick: function(menu, column) {
        //var grid = column.initOwnerCt.grid;
        var grid = column.$initParent.grid;

        i21.ModuleMgr.Inventory.showScreenFromHeaderDrilldown('Inventory.view.InventoryUOM', grid, 'intUnitMeasureId');
    },

    onCategoryHeaderClick: function(menu, column) {
        //var grid = column.initOwnerCt.grid;
        var grid = column.$initParent.grid;

        i21.ModuleMgr.Inventory.showScreenFromHeaderDrilldown('Inventory.view.Category', grid, 'intCategoryId');
    },

    onCountryHeaderClick: function(menu, column) {
        //var grid = column.initOwnerCt.grid;
        var grid = column.$initParent.grid;

        i21.ModuleMgr.Inventory.showScreenFromHeaderDrilldown('i21.view.Country', grid, 'intCountryID');
    },

    onDocumentHeaderClick: function(menu, column) {
        //var grid = column.initOwnerCt.grid;
        var grid = column.$initParent.grid;

        i21.ModuleMgr.Inventory.showScreenFromHeaderDrilldown('Inventory.view.ContractDocument', grid, 'intDocumentId');
    },

    onCertificationHeaderClick: function(menu, column) {
        //var grid = column.initOwnerCt.grid;
        var grid = column.$initParent.grid;

        i21.ModuleMgr.Inventory.showScreenFromHeaderDrilldown('Inventory.view.CertificationProgram', grid, 'intCertificationId');
    },

    onManufacturingCellHeaderClick: function(menu, column) {
        //var grid = column.initOwnerCt.grid;
        var grid = column.$initParent.grid;

        i21.ModuleMgr.Inventory.showScreenFromHeaderDrilldown('Manufacturing.view.ManufacturingCell', grid, 'intManufacturingCellId');
    },

    onCustomerHeaderClick: function(menu, column) {
        //var grid = column.initOwnerCt.grid;
        var grid = column.$initParent.grid;

        i21.ModuleMgr.Inventory.showScreenFromHeaderDrilldown('EntityManagement.view.Entity:searchEntityCustomer', grid, 'intOwnerId');
    },

    onPatronageBeforeSelect: function(combo, record) {
        if (record.length <= 0)
            return;

		var stockUnitExist = false;
        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) {
                if (current.tblICItemUOMs()) {
                    Ext.Array.each(current.tblICItemUOMs().data.items, function (itemStock) {
                        if (!itemStock.dummy) {
                            if(itemStock.get('ysnStockUnit') == '1')
								stockUnitExist = true;
                        }
                    });
                }

        }

		if (stockUnitExist == false)
		{
			iRely.Functions.showErrorDialog("Stock Unit is required for Patronage Category.");
            return false;
		}
    },

    onUPCEnterTab: function(field, e, eOpts) {
        var win = field.up('window');
        var grd = field.up('grid');
        var plugin = grd.getPlugin('cepDetailUOM');
        var record = plugin.getActiveRecord();

        if(win) {
            if (e.getKey() == e.ENTER || e.getKey() == e.TAB) {
               var task = new Ext.util.DelayedTask(function(){
                     if(field.itemId === 'txtShortUPCCode') {
                         record.set('strLongUPCCode', i21.ModuleMgr.Inventory.getFullUPCString(record.get('strUpcCode')));
                     }
                     else if(field.itemId === 'txtFullUPCCode') {
                        record.set('strUpcCode', i21.ModuleMgr.Inventory.getShortUPCString(record.get('strLongUPCCode')));
                        if(record.get('strUpcCode') !== null) {
                            record.set('strLongUPCCode', i21.ModuleMgr.Inventory.getFullUPCString(record.get('strUpcCode')));
                        }
                     }
                });

                task.delay(10);
            }
        }
    },

    //</editor-fold>
    onLocationCellClick: function(view, cell, cellIndex, record, row, rowIndex, e) {
        var linkClicked = (e.target.tagName == 'A');
        var clickedDataIndex =
            view.panel.headerCt.getHeaderAtIndex(cellIndex).dataIndex;

        if (linkClicked && clickedDataIndex == 'strLocationName') {
            var win = view.up('window');
            var me = win.controller;
            var vm = win.getViewModel();

            if (!record){
                iRely.Functions.showErrorDialog('Please select a location to edit.');
                return;
            }

            if (vm.data.current.phantom === true) {
                win.context.data.saveRecord({ successFn: function(batch, eOpts){
                    me.openItemLocationScreen('edit', win, record);
                    return;
                } });
            }
            else {
                win.context.data.validator.validateRecord({ window: win }, function(valid) {
                    if (valid) {
                        me.openItemLocationScreen('edit', win, record);
                        return;
                    }
                });
            }
        }
    },

    onOwnerSelect: function(combo, records) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var grid = combo.up('grid');
        var grdOwner = win.down('#grdOwner');
        var plugin = grid.getPlugin('cepOwner');
        var current = plugin.getActiveRecord();

        if (combo.itemId === 'cboOwner'){
            current.set('strName', records[0].get('strName'));
        }
    },
    
    onContractItemSelectionChange: function (selModel, selected, eOpts) {
        if (selModel) {
            if (selModel.view == null || selModel.view == 'undefined') {
                if (selModel.views == 'undefined' || selModel.views == null || selModel.views.length == 0)
                    return;
            }
            var win = selModel.view.grid.up('window');
            var vm = win.viewModel;

            if (selected.length > 0) {
                var current = selected[0];
                   
                if(!current.phantom && !current.dirty) {
                    win.down("#grdDocumentAssociation").setLoading("Loading documents...");
                    current.tblICItemContractDocuments().load({
                        callback: function(records, operation, success) {
                            win.down("#grdDocumentAssociation").setLoading(false);
                        }
                    });
                }
            }
        }
    },

    // onLocationSelectionChange: function(selModel, selected, oOpts) {
    //     if (selModel) {
    //         if (selModel.view === null || selModel.view == 'undefined') {
    //             if (selModel.views == 'undefined' || selModel.views === null || selModel.views.length == 0)
    //                 return;
    //         }
    //         var win = selModel.view.grid.up('window');
    //         var vm = win.viewModel;
    //         var grid = win.down('#grdItemSubLocations');

    //         if (selected.length > 0) {
    //             var current = selected[0];
                
    //             if(!current.phantom && !current.dirty) {
                    
    //             }
    //         }
    //     }
    // },

    init: function(application) {
        this.control({
            "#cboType": {
                select: this.onInventoryTypeSelect
            },
            "#cboDetailUnitMeasure": {
                select: this.onUOMUnitMeasureSelect
            },
            "#cboGLAccountId": {
                select: this.onGLAccountSelect
            },
            "#cboAccountCategory": {
                select: this.onGLAccountSelect
            },
            "#cboCopyLocation": {
                select: this.onCopyLocationSelect
            },
            "#cboPOSCategoryId": {
                select: this.onPOSCategorySelect
            },
            "#cboCustXrefLocation": {
                select: this.onCustomerXrefSelect
            },
            "#cboCustXrefCustomer": {
                select: this.onCustomerXrefSelect
            },
            "#cboVendorXrefLocation": {
                select: this.onVendorXrefSelect
            },
            "#cboVendorXrefVendor": {
                select: this.onVendorXrefSelect
            },
            "#cboVendorXrefUOM": {
                select: this.onVendorXrefSelect
            },
            "#cboContractLocation": {
                select: this.onContractItemSelect
            },
            "#cboContractOrigin": {
                select: this.onContractItemSelect
            },
            "#cboDocumentId": {
                select: this.onDocumentSelect
            },
            "#cboCertificationId": {
                select: this.onCertificationSelect
            },
            "#cboPricingLocation": {
                select: this.onPricingLocationSelect
            },
            "#cboPricingLevelLocation": {
                select: this.onPricingLevelSelect
            },
            "#cboPricingLevelUOM": {
                select: this.onPricingLevelSelect
            },
            "#cboPricingLevelMethod": {
                select: this.onPricingLevelSelect
            },
            "#cboPricingLevelCommissionOn": {
                select: this.onPricingLevelSelect
            },
             "#cboPricingLevelCurrency": {
                select: this.onPricingLevelSelect
            },
            "#cboSpecialPricingLocation": {
                select: this.onSpecialPricingSelect
            },
            "#cboSpecialPricingPromotionType": {
                select: this.onSpecialPricingSelect
            },
            "#cboSpecialPricingUOM": {
                select: this.onSpecialPricingSelect
            },
            "#cboSpecialPricingDiscountBy": {
                select: this.onSpecialPricingSelect,
                beforequery: this.onSpecialPricingBeforeQuery
            },
            "#cboSpecialPricingCurrency": {
                select: this.onSpecialPricingSelect
            },
            "#cboBundleUOM": {
                select: this.onBundleSelect
            },
            "#cboAssemblyItem": {
                select: this.onAssemblySelect
            },
            "#cboAssemblyUOM": {
                select: this.onAssemblySelect
            },
            "#cboKitDetailItem": {
                select: this.onKitSelect
            },
            "#cboKitDetailUOM": {
                select: this.onKitSelect
            },
            "#cboManufacturingCell": {
                select: this.onManufacturingCellSelect
            },
            "#tabItem": {
                tabchange: this.onItemTabChange
            },
            "#tabSetup": {
                tabchange: this.onItemTabChange
            },
            "#colStockUnit": {
                beforecheckchange: this.beforeUOMStockUnitCheckChange,
                checkchange: this.onUOMStockUnitCheckChange
            },
            "#colCellNameDefault": {
                beforecheckchange: this.onManufacturingCellDefaultCheckChange
            },
            "#grdLocationStore": {
                itemdblclick: this.onLocationDoubleClick,
                cellclick: this.onLocationCellClick,
                //selectionchange: this.onLocationSelectionChange
            },
            "#cboTracking": {
                specialKey: this.onSpecialKeyTab
            },
            "#txtSpecialPricingDiscount": {
                change: this.onSpecialPricingDiscountChange
            },
            "#txtSpecialPricingUnitPrice": {
                change: this.onSpecialPricingDiscountChange
            },
            "#txtStandardCost": {
                change: this.onPricingStandardCostChange
            },
            "#txtShortUPCCode": {
                specialKey: this.onUPCEnterTab
            },
            "#txtFullUPCCode": {
                specialKey: this.onUPCEnterTab
            },
            "#btnDuplicate": {
                click: this.onDuplicateClick
            },
            "#btnBuildAssembly": {
                click: this.onBuildAssemblyClick
            },
            "#btnLoadUOM": {
                click: this.onLoadUOMClick
            },
            "#colPricingAmount": {
                beforerender: this.onPricingGridColumnBeforeRender
            },
            "#cboLotTracking": {
                select: this.onLotTrackingSelect
            },
            "#btnAddLocation": {
                click: this.onAddLocationClick
            },
            "#btnAddMultipleLocation": {
                click: this.onAddMultipleLocationClick
            },
            "#btnEditLocation": {
                click: this.onEditLocationClick
            },
            "#btnAddRequiredAccounts": {
                click: this.onAddRequiredAccountClick
            },
            "#cboTaxAuthorityCode": {
                select: this.onMotorFuelTaxSelect
            },
            "#cboProductCode": {
                select: this.onMotorFuelTaxSelect
            },
            "#cboBundleItem": {
                select: this.onBundleSelect
            },
            "#cboManufacturer": {
                drilldown: this.onManufacturerDrilldown
            },
            "#cboBrand": {
                drilldown: this.onBrandDrilldown
            },
            "#cboCategory": {
                drilldown: this.onCategoryDrilldown
            },
            "#cboCommodity": {
                drilldown: this.onCommodityDrilldown,
                select: this.onCommoditySelect
            },
            "#cboMedicationTag": {
                drilldown: this.onMedicationTaxDrilldown
            },
            "#cboIngredientTag": {
                drilldown: this.onIngredientTagDrilldown
            },
            "#cboFuelCategory": {
                drilldown: this.onFuelCategoryDrilldown
            },
            "#cboPatronage": {
                drilldown: this.onPatronageDrilldown,
                beforeselect: this.onPatronageBeforeSelect
            },
            "#cboPatronageDirect": {
                drilldown: this.onPatronageDirectDrilldown
            },
            "#cboOwner": {
                select: this.onOwnerSelect
            },
            "#grdContractItem": {
                selectionchange: this.onContractItemSelectionChange
            }
        });

    }
});
