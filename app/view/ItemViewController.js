Ext.define('Inventory.view.ItemViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icitem',

    config: {
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
                {dataIndex: 'strManufacturer', text: 'Manufacturer', flex: 1, dataType: 'string', minWidth: 150},
                {dataIndex: 'strBrand', text: 'Brand', flex: 1, dataType: 'string', minWidth: 150},
                {dataIndex: 'strModelNo', text: 'Model No', flex: 1, dataType: 'string', minWidth: 150}
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
            txtModelNo: '{current.strModelNo}',
            cboType: {
                value: '{current.strType}',
                store: '{itemTypes}'
            },
            cboManufacturer: {
                value: '{current.intManufacturerId}',
                store: '{manufacturer}'
            },
            cboBrand: {
                value: '{current.intBrandId}',
                store: '{brand}'
            },
            cboStatus: {
                value: '{current.strStatus}',
                store: '{itemStatuses}'
            },
            cboCategory: {
                value: '{current.intCategoryId}',
                store: '{itemCategory}',
                readOnly: '{checkCommodityType}'
            },
            cboCommodity: {
                value: '{current.intCommodityId}',
                store: '{commodity}',
                readOnly: '{checkNotCommodityType}'
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
            cfgContractHide: {
                hidden: '{pgeContractHide}'
            },
            cfgXref: {
                hidden: '{pgeXrefHide}'
            },

            grdUnitOfMeasure: {
                colDetailUnitMeasure: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{uomUnitMeasure}'
                    }
                },
                colDetailUnitQty: {
                    dataIndex: 'dblUnitQty'
                },
                colDetailWeight: {
                    dataIndex: 'dblWeight'
                },
                colDetailWeightUOM: {
                    dataIndex: 'strWeightUOM',
                    editor: {
                        store: '{weightUOM}',
                        defaultFilters: [{
                            column: 'strUnitType',
                            value: 'Weight',
                            conjunction: 'and'
                        }]
                    }
                },
                colDetailShortUPC: 'strUpcCode',
                colDetailUpcCode: 'strFullUPC',
                colStockUnit: 'ysnStockUnit',
                colAllowSale: 'ysnAllowSale',
                colAllowPurchase: 'ysnAllowPurchase',
                colConvertToStock: 'dblConvertToStock',
                colConvertFromStock: 'dblConvertFromStock',
                colDetailLength: 'dblLength',
                colDetailWidth: 'dblWidth',
                colDetailHeight: 'dblHeight',
                colDetailDimensionUOM: {
                    dataIndex: 'strDimensionUOM',
                    editor: {
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
                        store: '{volumeUOM}',
                        defaultFilters: [{
                            column: 'strUnitType',
                            value: 'Volume',
                            conjunction: 'and'
                        }]
                    }
                },
                colDetailMaxQty: 'dblMaxQty'
            },

            //----------//
            //Setup Tab//
            //----------//

            //------------------//
            //Location Store Tab//
            //------------------//
            grdLocationStore: {
                colLocationLocation: 'strLocationName',
                colLocationPOSDescription: 'strDescription',
                colLocationVendor: 'strVendorId',
                colLocationCostingMethod: 'strCostingMethod'
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
                        }]
                    }
                },
                colGLAccountId: {
                    dataIndex: 'strAccountId',
                    editor: {
                        store: '{glAccountId}',
                        defaultFilters: [{
                            column: 'intAccountCategoryId',
                            value: '{grdGlAccounts.selection.intAccountCategoryId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colDescription: 'strDescription'
            },

            //---------//
            //Sales Tab//
            //---------//
            cboPatronage: {
                value: '{current.intPatronageCategoryId}',
                store: '{patronage}'
            },
            cboFuelTaxClass: {
                value: '{current.intFuelTaxClassId}',
                store: '{taxClass}'
            },
            cboTaxGroup: {
                value: '{current.intTaxGroupId}',
                store: '{taxGroup}'
            },
            chkStockedItem: '{current.ysnStockedItem}',
            chkDyedFuel: '{current.ysnDyedFuel}',
            cboBarcodePrint: {
                value: '{current.strBarcodePrint}',
                store: '{barcodePrints}'
            },
            chkMsdsRequired: '{current.ysnMSDSRequired}',
            txtEpaNumber: '{current.strEPANumber}',
            chkInboundTax: '{current.ysnInboundTax}',
            chkOutboundTax: '{current.ysnOutboundTax}',
            chkRestrictedChemical: '{current.ysnRestrictedChemical}',
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
            txtPercentDenaturant: '{current.dblDenaturantPercent}',
            chkTonnageTax: '{current.ysnTonnageTax}',
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
                store: '{mfgWeightUom}'
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
                colContractFranchise: 'dblFranchisePercent'
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
                            value: '{grdPricingLevel.selection.intCompanyLocationId}'
                        }]
                    }
                },
                colPricingLevelUOM: {
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
                colPricingLevelUnits: 'dblUnit',
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
                colPricingLevelCommissionRate: 'dblCommissionRate'
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
                colSpecialPricingQty: 'dblUnit',
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
                colSpecialPricingAccumAmount: 'dblAccumulatedAmount'
            },

            //---------//
            //Stock Tab//
            //---------//
            grdStock: {
                colStockLocation: 'strLocationName',
                colStockSubLocation: 'strWarehouse',
                colStockUOM: 'strUnitMeasure',
                colStockOnHand: 'dblUnitOnHand',
                colStockCommitted: 'dblOrderCommitted',
                colStockOnOrder: 'dblOnOrder',
                colStockBackOrder: 'dblBackOrder'
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
                store: '{productTypeAttribute}'
            },
            cboRegion: {
                value: '{current.intRegionId}',
                store: '{regionAttribute}'
            },
            cboSeason: {
                value: '{current.intSeasonId}',
                store: '{seasonAttribute}'
            },
            cboClass: {
                value: '{current.intClassVarietyId}',
                store: '{classAttribute}'
            },
            cboProductLine: {
                value: '{current.intProductLineId}',
                store: '{productLineAttribute}'
            },
            cboMarketValuation: {
                value: '{current.strMarketValuation}',
                store: '{marketValuations}'
            },

            grdCommodityCost: {
                colCommodityLocation: {
                    dataIndex: 'strLocationName',
                    editor: {
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
                        defaultFilters: [{
                            column: 'strLotTracking',
                            value: 'No'
                        }]
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
                        store: '{bundleItem}',
                        defaultFilters: [{
                            column: 'strType',
                            value: 'Inventory Item',
                            conjunction: 'or'
                        },{
                            column: 'strType',
                            value: 'Inventory'
                        }]
                    }
                },
                colBundleQuantity: 'dblQuantity',
                colBundleDescription: 'strDescription',
                colBundleUOM: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{bundleUOM}'
                    }
                },
                colBundleUnit: 'dblUnit',
                colBundlePrice: 'dblPrice'
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
                        store: '{factory}'
                    }
                },
                colFactoryDefault: 'ysnDefault'
            },

            grdManufacturingCellAssociation: {
                colCellName: {
                    dataIndex: 'strCellName',
                    editor: {
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
                        store: '{owner}'
                    }
                },
                colOwnerDefault: 'ysnActive'
            },

            //---------//
            //Notes Tab//
            //---------//
            grdNotes: {
                colNoteLocation: {
                    dataIndex: 'strLocationName',
                    editor: {
                        store: '{noteLocation}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{current.intItemId}'
                        }]
                    }
                },
                colNoteCommentType: {
                    dataIndex: 'strCommentType',
                    editor: {
                        store: '{commentTypes}'
                    }
                },
                colNoteComment: 'strComments'
            }

        }
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

            grdPricing = win.down('#grdPricing'),
            grdPricingLevel = win.down('#grdPricingLevel'),
            grdSpecialPricing = win.down('#grdSpecialPricing'),

            grdCommodityCost = win.down('#grdCommodityCost'),

            grdAssembly = win.down('#grdAssembly'),
            grdBundle = win.down('#grdBundle'),
            grdKit = win.down('#grdKit'),
            grdKitDetails = win.down('#grdKitDetails'),

            grdNotes = win.down('#grdNotes');

        win.context = Ext.create('iRely.mvvm.Engine', {
            window : win,
            store  : store,
            createRecord : me.createRecord,
            validateRecord : me.validateRecord,
            onSaveClick: me.onSaveClick,
            binding: me.config.binding,
            fieldTitle: 'strItemNo',
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
                    })
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
                    key: 'tblICItemNotes',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdNotes,
                        deleteButton : grdNotes.down('#btnDeleteNotes')
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
                validateedit: me.onEditPricingLevel,
                scope: me
            });
        }

        var cepPricing = grdPricing.getPlugin('cepPricing');
        if (cepPricing){
            cepPricing.on({
                validateedit: me.onEditPricing,
                scope: me
            });
        }

        var colStockUOM = grdStock.columns[1];
        colStockUOM.renderer = this.onRenderStockUOM;

        return win.context;
    },

    createRecord: function(config, action) {
        var me = this;
        var record = Ext.create('Inventory.model.Item');
        record.set('strStatus', 'Active');
        record.set('strType', 'Inventory');
        record.set('strLotTracking', 'No');
        record.set('strInventoryTracking', 'Item Level');
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
        var win = config.window;
        this.validateRecord(config, function (result) {
            if (result) {
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

    onSaveClick: function(button, e, options) {
        var win = button.up('window');
        var me = this;

        if (win.viewModel.data.current.dirty && win.viewModel.data.current.phantom) {
            var buttonAction = function(button) {
                if (button === 'yes') {
                    me.onSaveClick(button, e, options);
                }
            };
            var current = win.viewModel.data.current;
            var accounts = current.tblICItemAccounts().data.items;

            if (i21.ModuleMgr.Inventory.checkEmptyStore(accounts) && current.get('intCategoryId') !== null){
                iRely.Functions.showCustomDialog('warning', 'yesno', 'GL Accounts are not setup for this Item. System will take the GL Accounts from the Category during Posting if you choose to continue.', buttonAction);
            }
            else if (i21.ModuleMgr.Inventory.checkEmptyStore(accounts) && current.get('intCategoryId') === null){
                iRely.Functions.showCustomDialog('warning', 'yesno', 'GL Accounts has to be setup for the item. Continue without setting up your GL Accounts?', buttonAction);
            }
            else {
                me.onSaveClick(button, e, options);
            }
        }
        else {
            me.onSaveClick(button, e, options);
        }
    },

    // <editor-fold desc="Details Tab Methods and Event Handlers">

    onItemTabChange: function(tabPanel, newCard, oldCard, eOpts) {
        switch(newCard.itemId){
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
                    grdStock.getView().refresh();
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

            case 'pgeNotes':
                var pgeNotes = tabPanel.down('#pgeNotes');
                var grdNotes = pgeNotes.down('#grdNotes');
                if (grdNotes.store.complete === true)
                    grdNotes.getView().refresh();
                else
                    grdNotes.store.load();
                break;
        }
    },

    onInventoryTypeSelect: function(combo, records) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) {
            if (records[0].get('strType') == 'Assembly/Blend') {
                current.set('strLotTracking', 'No');
            }
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

    onUOMUnitMeasureSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var win = grid.up('window');
        var plugin = grid.getPlugin('cepDetailUOM');
        var current = plugin.getActiveRecord();
        var uomConversion = win.viewModel.storeInfo.uomConversion;

        if (combo.column.itemId === 'colDetailUnitMeasure') {
            current.set('intUnitMeasureId', records[0].get('intUnitMeasureId'));
            current.set('ysnAllowPurchase', true);
            current.set('ysnAllowSale', true);
            current.set('tblICUnitMeasure', records[0]);

            var uoms = grid.store.data.items;
            var exists = Ext.Array.findBy(uoms, function (row) {
                if (row.get('ysnStockUnit') === true) {
                    return true;
                }
            });
            if (exists) {
                if (uomConversion) {
                    var index = uomConversion.data.findIndexBy(function (row) {
                        if (row.get('intUnitMeasureId') === exists.get('intUnitMeasureId')) {
                            return true;
                        }
                    });
                    if (index >= 0) {
                        var stockUOM = uomConversion.getAt(index);
                        var conversions = stockUOM.data.vyuICGetUOMConversions;
                        if (conversions) {
                            var selectedUOM = Ext.Array.findBy(conversions, function (row) {
                                if (row.intUnitMeasureId === current.get('intUnitMeasureId')) {
                                    return true;
                                }
                            });
                            if (selectedUOM) {
                                current.set('dblUnitQty', selectedUOM.dblConversionToStock);
                            }
                        }
                    }
                }
            }
        }
        else if (combo.column.itemId === 'colDetailWeightUOM')
        {
            current.set('intWeightUOMId', records[0].get('intUnitMeasureId'));
        }
        else if (combo.column.itemId === 'colDetailDimensionUOM')
        {
            current.set('intDimensionUOMId', records[0].get('intUnitMeasureId'));
        }
        else if (combo.column.itemId === 'colDetailVolumeUOM')
        {
            current.set('intVolumeUOMId', records[0].get('intUnitMeasureId'));
        }
    },

    onUOMStockUnitCheckChange: function (obj, rowIndex, checked, eOpts) {
        if (obj.dataIndex === 'ysnStockUnit'){
            var grid = obj.up('grid');
            var current = grid.view.getRecord(rowIndex);

            if (checked === true){
                var uoms = grid.store.data.items;
                var currUOM = current.get('tblICUnitMeasure');
                if (currUOM) {
                    var conversions = currUOM.vyuICGetUOMConversions;
                    if (!conversions) {
                        conversions = currUOM.data.vyuICGetUOMConversions;
                    }
                    uoms.forEach(function(uom){
                        if (uom === current){
                            current.set('dblUnitQty', 1);
                        }
                        if (uom !== current){
                            uom.set('ysnStockUnit', false);
                        }
                        if (conversions){
                            var exists = Ext.Array.findBy(conversions, function(row) {
                                if (row.intUnitMeasureId === uom.get('intUnitMeasureId')) {
                                    return true;
                                }
                            });
                            if (exists) {
                                uom.set('dblUnitQty', exists.dblConversionToStock);
                            }
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

    // </editor-fold>

    // <editor-fold desc="Location Tab Methods and Event Handlers">

    subscribeLocationEvents: function (grid, scope) {
        var me = scope;
        var btnAddLocation = grid.down('#btnAddLocation');
        if (btnAddLocation) btnAddLocation.on('click', me.onAddLocationClick);
        var btnEditLocation = grid.down('#btnEditLocation');
        if (btnEditLocation) btnEditLocation.on('click', me.onEditLocationClick);

        var colLocationCostingMethod = grid.columns[4];
        if (colLocationCostingMethod) colLocationCostingMethod.renderer = me.CostingMethodRenderer;
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
            } });
        }
        else {
            win.context.data.validator.validateRecord({ window: win }, function(valid) {
                if (valid) {
                    me.openItemLocationScreen('edit', win, record);
                }
            });
        }
    },

    onAddLocationClick: function(button, e, eOpts) {
        var win = button.up('window');
        var me = win.controller;
        var vm = win.getViewModel();

        if (vm.data.current.phantom === true) {
            win.context.data.saveRecord({ successFn: function(batch, eOpts){
                me.openItemLocationScreen('new', win);
            } });
        }
        else {
            win.context.data.validator.validateRecord({ window: win }, function(valid) {
                if (valid) {
                    me.openItemLocationScreen('new', win);
                }
            });
        }
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
        var me = win.controller;
        var screenName = 'Inventory.view.ItemLocation';

        Ext.require([
            screenName,
                screenName + 'ViewModel',
                screenName + 'ViewController'
        ], function() {
            var screen = 'ic' + screenName.substring(screenName.indexOf('view.') + 5, screenName.length);
            var view = Ext.create(screenName, { controller: screen.toLowerCase(), viewModel: screen.toLowerCase() });
            view.on('destroy', me.onDestroyItemLocationScreen, me, { window: win });

            var controller = view.getController();
            var current = win.getViewModel().data.current;
            if (action === 'edit'){
                controller.show({ itemId: current.get('intItemId'), locationId: record.get('intItemLocationId'), action: action });
            }
            else if (action === 'new') {
                controller.show({ itemId: current.get('intItemId'), action: action });
            }
        });
    },

    onDestroyItemLocationScreen: function(win, eOpts) {
        var me = eOpts.window.getController();
        var win = eOpts.window;
        var grdLocation = win.down('#grdLocationStore');
        var vm = win.getViewModel();
        var itemId = vm.data.current.get('intItemId');
        var filterItem = grdLocation.store.filters.items[0];

        filterItem.setValue(itemId);
        filterItem.config.value = itemId;
        filterItem.initialConfig.value = itemId;
        grdLocation.store.load();
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
            current.set('intCustomerId', records[0].get('intCustomerId'));
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
            current.set('intVendorId', records[0].get('intVendorId'));
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
            current.set('intCompanyLocationId', records[0].get('intCompanyLocationId'));
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
        }
        else if (combo.column.itemId === 'colSpecialPricingDiscountBy') {
            if (records[0].get('strDescription') === 'Percent') {
                var discount = current.get('dblUnitAfterDiscount') * current.get('dblDiscount') / 100;
                var discPrice = current.get('dblUnitAfterDiscount') - discount;
                current.set('dblDiscountedPrice', discPrice);
            }
            else if (records[0].get('strDescription') === 'Amount') {
                var discount = current.get('dblDiscount');
                var discPrice = current.get('dblUnitAfterDiscount') - discount;
                current.set('dblDiscountedPrice', discPrice);
            }
            else { current.set('dblDiscountedPrice', 0.00); }
        }
    },

    onEditPricingLevel: function (editor, context, eOpts) {
        if (context.field === 'strPricingMethod' || context.field === 'dblAmountRate') {
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
                            var retailPrice = 0;
                            switch (pricingMethod) {
                                case 'Discount Retail Price':
                                    unitPrice = unitPrice - (unitPrice * (amount / 100));
                                    retailPrice = unitPrice * qty
                                    break;
                                case 'MSRP Discount':
                                    msrpPrice = msrpPrice - (msrpPrice * (amount / 100));
                                    retailPrice = msrpPrice * qty
                                    break;
                                case 'Percent of Margin (MSRP)':
                                    var percent = amount / 100;
                                    unitPrice = ((msrpPrice - standardCost) * percent) + standardCost;
                                    retailPrice = unitPrice * qty;
                                    break;
                                case 'Fixed Dollar Amount':
                                    unitPrice = (standardCost + amount);
                                    retailPrice = unitPrice * qty;
                                    break;
                                case 'Markup Standard Cost':
                                    var markup = (standardCost * (amount / 100));
                                    unitPrice = (standardCost + markup);
                                    retailPrice = unitPrice * qty;
                                    break;
                                case 'Percent of Margin':
                                    unitPrice = (standardCost / (1 - (amount / 100)));
                                    retailPrice = unitPrice * qty;
                                    break;
                                case 'None':
                                default:
                                    retailPrice = 0;
                                    break;
                            }
                            context.record.set('dblUnitPrice', retailPrice);
                        }
                    }
                }
            }
        }
    },

    onEditPricing: function(editor, context, eOpts) {
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

                if (iRely.Functions.isEmpty(pricingMethod) || pricingMethod === 'None'){
                    context.record.set('dblSalePrice', cost);
                    context.record.set('dblAmountPercent', 0.00);
                }
                else if (iRely.Functions.isEmpty(pricingMethod) || pricingMethod === 'Fixed Dollar Amount'){
                    context.record.set('dblSalePrice', (cost + amount));
                }
                else if (iRely.Functions.isEmpty(pricingMethod) || pricingMethod === 'Markup Standard Cost'){
                    var markup = (cost * (amount / 100));
                    context.record.set('dblSalePrice', (cost + markup));
                }
                else if (iRely.Functions.isEmpty(pricingMethod) || pricingMethod === 'Percent of Margin'){
                    var markup = (cost / (1 - (amount / 100)));
                    context.record.set('dblSalePrice', markup);
                }
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
                                xtype: 'numberfield'
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

    // <editor-fold desc="Commodity Tab Methods and Event Handlers">

    onCommoditySelect: function (combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var commodity = records[0];
        var intCommodityId = commodity.get('intCommodityId');

        var win = combo.up('window');
        var pgeCommodity = win.down('#pgeCommodity');
        var cboOrigin = pgeCommodity.down('#cboOrigin');
        var cboProductType = pgeCommodity.down('#cboProductType');
        var cboRegion = pgeCommodity.down('#cboRegion');
        var cboSeason = pgeCommodity.down('#cboSeason');
        var cboClass = pgeCommodity.down('#cboClass');
        var cboProductLine = pgeCommodity.down('#cboProductLine');

        var filter = [{ dataIndex: 'intCommodityId', value: intCommodityId, condition: 'eq' }];

        cboOrigin.defaultFilters = filter;
        cboProductType.defaultFilters = filter;
        cboRegion.defaultFilters = filter;
        cboSeason.defaultFilters = filter;
        cboClass.defaultFilters = filter;
        cboProductLine.defaultFilters = filter;

        var current = win.viewModel.data.current;
        if (current){
            var uoms = records[0].get('tblICCommodityUnitMeasures');
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
                    var grid = win.down('#grdUnitOfMeasure');
                    grid.gridMgr.newRow.add();
                }
            }
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

    // <editor-fold desc="Bundle Details Tab Methods and Event Handlers">

    onBundleSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepBundle');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colBundleItem'){
            current.set('intBundleItemId', records[0].get('intItemId'));
        }
        else if (combo.column.itemId === 'colBundleUOM') {
            current.set('intItemUnitMeasureId', records[0].get('intItemUOMId'));
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

    onFactorySelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepFactory');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colFactoryName'){
            current.set('intFactoryId', records[0].get('intCompanyLocationId'));
        }
    },

    onManufacturingCellSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var controller = win.getController();
        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepManufacturingCell');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colCellName'){
            current.set('intManufacturingCellId', records[0].get('intManufacturingCellId'));
            current.set('intPreference', controller.getNewPreferenceNo(grid.store));
        }
    },

    onOwnerSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepOwner');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colOwner'){
            current.set('intOwnerId', records[0].get('intCustomerId'));
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


    // </editor-fold>

    // <editor-fold desc="Note Tab Methods and Event Handlers">

    onNoteSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepNote');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colNoteLocation'){
            current.set('intItemLocationId', records[0].get('intItemLocationId'));
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
            else { record.set('dblDiscountedPrice', 0.00); }
        }
    },

    onItemCategorySelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current){
            var uoms = records[0].tblICCategoryUOMs().data.items;
            if (uoms) {
                if (uoms.length > 0) {
                    current.tblICItemUOMs().removeAll();
                    uoms.forEach(function(uom){
                        var newItemUOM = Ext.create('Inventory.model.ItemUOM', {
                            intItemId : current.get('intItemId'),
                            strUnitMeasure: uom.get('strUnitMeasure'),
                            intUnitMeasureId : uom.get('intUnitMeasureId'),
                            dblUnitQty : uom.get('dblUnitQty'),
                            dblWeight : uom.get('dblWeight'),
                            strWeightUOM: uom.get('strWeightUOM'),
                            intWeightUOMId : uom.get('intWeightUOMId'),
                            strUpcCode : uom.get('strUpcCode'),
                            ysnStockUnit : uom.get('ysnStockUnit'),
                            ysnAllowPurchase : uom.get('ysnAllowPurchase'),
                            ysnAllowSale : uom.get('ysnAllowSale'),
                            dblLength : uom.get('dblLength'),
                            dblWidth : uom.get('dblWidth'),
                            dblHeight : uom.get('dblHeight'),
                            strDimensionUOM: uom.get('strDimensionUOM'),
                            intDimensionUOMId : uom.get('intDimensionUOMId'),
                            dblVolume : uom.get('dblVolume'),
                            strVolumeUOM: uom.get('strVolumeUOM'),
                            intVolumeUOMId : uom.get('intVolumeUOMId'),
                            dblMaxQty : uom.get('dblMaxQty'),
                            intSort : uom.get('intSort')
                        });
                        current.tblICItemUOMs().add(newItemUOM);
                    });
                    var grid = win.down('#grdUnitOfMeasure');
                    grid.gridMgr.newRow.add();
                }
            }
        }
    },

    onItemCommodityLocationSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepCommodityCost');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colCommodityLocation'){
            current.set('intItemLocationId', records[0].get('intItemLocationId'));
        }
    },

    onDuplicateClick: function(button) {
        var win = button.up('window');
        var context = win.context;
        var current = win.viewModel.data.current;

        if (current) {
            Ext.Ajax.request({
                timeout: 120000,
                url: '../Inventory/api/Item/DuplicateItem?ItemId=' + current.get('intItemId'),
                method: 'GET',
                success: function(response){
                    var jsonData = Ext.decode(response.responseText);
                    context.configuration.store.addFilter([{ column: 'intItemId', value: jsonData.id }]);
                    context.configuration.paging.moveFirst();
                }
            });
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
                select: this.onSpecialPricingSelect
            },
            "#cboCommodity": {
                select: this.onCommoditySelect
            },
            "#cboAssemblyItem": {
                select: this.onAssemblySelect
            },
            "#cboAssemblyUOM": {
                select: this.onAssemblySelect
            },
            "#cboBundleItem": {
                select: this.onBundleSelect
            },
            "#cboBundleUOM": {
                select: this.onBundleSelect
            },
            "#cboKitDetailItem": {
                select: this.onKitSelect
            },
            "#cboKitDetailUOM": {
                select: this.onKitSelect
            },
            "#cboNoteLocation": {
                select: this.onNoteSelect
            },
            "#cboFactory": {
                select: this.onFactorySelect
            },
            "#cboManufacturingCell": {
                select: this.onManufacturingCellSelect
            },
            "#cboOwner": {
                select: this.onOwnerSelect
            },
            "#tabItem": {
                tabchange: this.onItemTabChange
            },
            "#tabSetup": {
                tabchange: this.onItemTabChange
            },
            "#colStockUnit": {
                beforecheckchange: this.onUOMStockUnitCheckChange
            },
            "#grdLocationStore": {
                itemdblclick: this.onLocationDoubleClick
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
            "#cboCategory": {
                select: this.onItemCategorySelect
            },
            "#cboCommodityLocation": {
                select: this.onItemCommodityLocationSelect
            },
            "#btnDuplicate": {
                click: this.onDuplicateClick
            },
            "#btnBuildAssembly": {
                click: this.onBuildAssemblyClick
            },
            "#colPricingAmount": {
                beforerender: this.onPricingGridColumnBeforeRender
            },
            "#cboLotTracking" : {
                select: this.onLotTrackingSelect
            }
        });
    }
});
