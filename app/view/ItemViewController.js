Ext.define('Inventory.view.ItemViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icitem',

    config: {
        searchConfig: {
            title: 'Search Item',
            type: 'Inventory.Item',
            api: {
                read: '../Inventory/api/Item/SearchItems'
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
                colDetailUpcCode: 'strUpcCode',
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
                colLocationCategory: 'strCategory',
                colLocationVendor: 'strVendorId',
                colLocationCostingMethod: 'intCostingMethod'
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
            cboTaxClass: {
                value: '{current.intTaxClassId}',
                store: '{taxClass}'
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

            //colManufacturingUOM: 'intUnitMeasureId',

            //-------//
            //UPC Tab//
            //-------//
            grdUPC: {
                colUPCUnitMeasure: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{upcUom}'
                    }
                },
                colUPCUnitQty: 'dblUnitQty',
                colUPCCode: 'strUPCCode'
            },

            //-------------------//
            //Cross Reference Tab//
            //-------------------//
            grdCustomerXref: {
                colCustomerXrefLocation: {
                    dataIndex: 'strLocationName',
                    editor: {
                        store: '{custXrefLocation}'
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
                        store: '{vendorXrefLocation}'
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
                        store: '{contractLocation}'
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
                colPricingLocation: 'strLocationName',
                colPricingUOM: 'strUnitMeasure',
                colPricingUPC: 'strUPC',
                colPricingLastCost: 'dblLastCost',
                colPricingStandardCost: 'dblStandardCost',
                colPricingAverageCost: 'dblAverageCost',
                colPricingEOMCost: 'dblEndMonthCost',
                colPricingMethod: 'strPricingMethod',
                colPricingAmount: 'dblAmountPercent',
                colPricingSalePrice: 'dblSalePrice',
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
                colSpecialPricingAccumQty: 'dblAccumulatedQty',
                colSpecialPricingAccumAmount: 'dblAccumulatedAmount'
            },

            //---------//
            //Stock Tab//
            //---------//
            grdStock: {
                colStockLocation: {
                    dataIndex: 'strLocationName',
                    editor: {
                        store: '{stockLocation}'
                    }
                },
                colStockSubLocation: 'strWarehouse',
                colStockUOM: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{stockUOM}'
                    }
                },
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

            //------------//
            //Assembly Tab//
            //------------//
            grdAssembly: {
                colAssemblyComponent: {
                    dataIndex: 'strItemNo',
                    editor: {
                        store: '{assemblyItem}'
                    }
                },
                colAssemblyQuantity: 'dblQuantity',
                colAssemblyDescription: 'strDescription',
                colAssemblyUOM: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{assemblyUOM}'
                    }
                },
                colAssemblyUnit: 'dblUnit',
                colAssemblyCost: 'dblCost'
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
                        store: '{noteLocation}'
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
            grdUPC = win.down('#grdUPC'),
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

            grdAssembly = win.down('#grdAssembly'),
            grdBundle = win.down('#grdBundle'),
            grdKit = win.down('#grdKit'),
            grdKitDetails = win.down('#grdKitDetails'),

            grdNotes = win.down('#grdNotes');

        win.context = Ext.create('iRely.mvvm.Engine', {
            window : win,
            store  : store,
            createRecord : me.createRecord,
            validateRecord: me.validateRecord,
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
                    key: 'tblICItemUPCs',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdUPC,
                        deleteButton : win.down('#btnDeleteUPC')
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
                        deleteButton : grdPricing.down('#btnDeletePricing'),
                        position: 'none'
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

        var btnAddPricing = grdPricing.down('#btnAddPricing');
        btnAddPricing.on('click', me.onAddPricingClick);
        var btnEditPricing = grdPricing.down('#btnEditPricing');
        btnEditPricing.on('click', me.onEditPricingClick);

        var cepPricingLevel = grdPricingLevel.getPlugin('cepPricingLevel');
        if (cepPricingLevel){
            cepPricingLevel.on({
                validateedit: me.onEditPricingLevel,
                scope: me
            });
        }

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
        var me = this;
        if (config.viewModel.data.current.dirty && config.viewModel.data.current.phantom) {
            var buttonAction = function(button) {
                if (button === 'yes') {
                    me.validateRecord(config, function(result) {
                        if (result) { action(true); }
                    });
                }
            };
            var current = config.viewModel.data.current;
            var accounts = current.tblICItemAccounts().data.items;

            if (i21.ModuleMgr.Inventory.checkEmptyStore(accounts) && current.get('intCategoryId') !== null){
                iRely.Functions.showCustomDialog('warning', 'yesno', 'GL Accounts are not setup for this Item. System will take the GL Accounts from the Category during Posting if you choose to continue.', buttonAction);
            }
            else if (i21.ModuleMgr.Inventory.checkEmptyStore(accounts) && current.get('intCategoryId') === null){
                iRely.Functions.showCustomDialog('warning', 'yesno', 'GL Accounts has to be setup for the item. Continue without setting up your GL Accounts?', buttonAction);
            }
            else {
                this.validateRecord(config, function(result) {
                    if (result) { action(true); }
                });
            }
        }
        else {
            this.validateRecord(config, function(result) {
                if (result) { action(true); }
            });
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

                var win = tabPanel.up('window');
                var controller = win.getController();
                if (controller.isLoadedLocation !== true)
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

            case 'pgeUPC':
                var pgeUPC = tabPanel.down('#pgeUPC');
                var grdUPC = pgeUPC.down('#grdUPC');
                if (grdUPC.store.complete === true)
                    grdUPC.getView().refresh();
                else
                    grdUPC.store.load();
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

    onInventoryTypeChange: function(combo, newValue, oldValue, eOpts) {
        var win = combo.up('window');
        var current = win.viewModel.data.current;
        var pgeDetails = win.down('#pgeDetails');
        var pgeSetup = win.down('#pgeSetup');
        var pgePricing = win.down('#pgePricing');
        var pgeStock = win.down('#pgeStock');
        var pgeCommodity = win.down('#pgeCommodity');
        var pgeAssembly = win.down('#pgeAssembly');
        var pgeBundle = win.down('#pgeBundle');
        var pgeKit = win.down('#pgeKit');
        var pgeFactory = win.down('#pgeFactory');
        var pgeNotes = win.down('#pgeNotes');
        var pgeAttachments = win.down('#pgeAttachments');

        var pgeSales = pgeSetup.down('#pgeSales');
        var pgePOS = pgeSetup.down('#pgePOS');
        var pgeManufacturing = pgeSetup.down('#pgeManufacturing');
        var pgeUPC = pgeSetup.down('#pgeUPC');
        var pgeContract = pgeSetup.down('#pgeContract');

        switch (newValue) {
            case 'Assembly':
            case 'Assembly/Blend':
            case 'Assembly/Formula/Blend':
                pgeDetails.tab.setHidden(false);
                pgeSetup.tab.setHidden(false);
                pgePricing.tab.setHidden(false);
                pgeStock.tab.setHidden(false);
                pgeCommodity.tab.setHidden(true);
                pgeAssembly.tab.setHidden(false);
                pgeBundle.tab.setHidden(true);
                pgeKit.tab.setHidden(true);
                pgeFactory.tab.setHidden(false);
                pgeNotes.tab.setHidden(false);
                pgeAttachments.tab.setHidden(false);
                pgeSales.tab.setHidden(false);
                pgePOS.tab.setHidden(false);
                pgeManufacturing.tab.setHidden(false);
//                pgeUPC.tab.setHidden(false);
                pgeContract.tab.setHidden(true);
                break;
            case 'Bundle':
                pgeDetails.tab.setHidden(false);
                pgeSetup.tab.setHidden(false);
                pgePricing.tab.setHidden(false);
                pgeStock.tab.setHidden(true);
                pgeCommodity.tab.setHidden(true);
                pgeAssembly.tab.setHidden(true);
                pgeBundle.tab.setHidden(false);
                pgeKit.tab.setHidden(true);
                pgeFactory.tab.setHidden(true);
                pgeNotes.tab.setHidden(false);
                pgeAttachments.tab.setHidden(false);
                pgeSales.tab.setHidden(false);
                pgePOS.tab.setHidden(false);
                pgeManufacturing.tab.setHidden(true);
//                pgeUPC.tab.setHidden(false);
                pgeContract.tab.setHidden(true);
                break;
            case 'Inventory Item':
            case 'Inventory':
                pgeDetails.tab.setHidden(false);
                pgeSetup.tab.setHidden(false);
                pgePricing.tab.setHidden(false);
                pgeStock.tab.setHidden(false);
                pgeCommodity.tab.setHidden(true);
                pgeAssembly.tab.setHidden(true);
                pgeBundle.tab.setHidden(true);
                pgeKit.tab.setHidden(true);
                pgeFactory.tab.setHidden(true);
                pgeNotes.tab.setHidden(false);
                pgeAttachments.tab.setHidden(false);
                pgeSales.tab.setHidden(false);
                pgePOS.tab.setHidden(false);
                pgeManufacturing.tab.setHidden(true);
//                pgeUPC.tab.setHidden(false);
                pgeContract.tab.setHidden(true);
                break;
            case 'Kit':
                pgeDetails.tab.setHidden(false);
                pgeSetup.tab.setHidden(false);
                pgePricing.tab.setHidden(false);
                pgeStock.tab.setHidden(true);
                pgeCommodity.tab.setHidden(true);
                pgeAssembly.tab.setHidden(true);
                pgeBundle.tab.setHidden(true);
                pgeKit.tab.setHidden(false);
                pgeFactory.tab.setHidden(true);
                pgeNotes.tab.setHidden(false);
                pgeAttachments.tab.setHidden(false);
                pgeSales.tab.setHidden(false);
                pgePOS.tab.setHidden(false);
                pgeManufacturing.tab.setHidden(true);
//                pgeUPC.tab.setHidden(false);
                pgeContract.tab.setHidden(true);
                break;
            case 'Manufacturing Item':
            case 'Manufacturing':
                pgeDetails.tab.setHidden(false);
                pgeSetup.tab.setHidden(false);
                pgePricing.tab.setHidden(false);
                pgeStock.tab.setHidden(false);
                pgeCommodity.tab.setHidden(true);
                pgeAssembly.tab.setHidden(true);
                pgeBundle.tab.setHidden(true);
                pgeKit.tab.setHidden(true);
                pgeFactory.tab.setHidden(false);
                pgeNotes.tab.setHidden(false);
                pgeAttachments.tab.setHidden(false);
                pgeSales.tab.setHidden(false);
                pgePOS.tab.setHidden(true);
                pgeManufacturing.tab.setHidden(false);
//                pgeUPC.tab.setHidden(true);
                pgeContract.tab.setHidden(true);
                break;

            case 'Non-Inventory':
                pgeDetails.tab.setHidden(false);
                pgeSetup.tab.setHidden(false);
                pgePricing.tab.setHidden(false);
                pgeStock.tab.setHidden(true);
                pgeCommodity.tab.setHidden(true);
                pgeAssembly.tab.setHidden(true);
                pgeBundle.tab.setHidden(true);
                pgeKit.tab.setHidden(true);
                pgeFactory.tab.setHidden(true);
                pgeNotes.tab.setHidden(false);
                pgeAttachments.tab.setHidden(false);
                pgeSales.tab.setHidden(true);
                pgePOS.tab.setHidden(true);
                pgeManufacturing.tab.setHidden(true);
//                pgeUPC.tab.setHidden(true);
                pgeContract.tab.setHidden(true);
                break;
            case 'Other Charge':
                pgeDetails.tab.setHidden(false);
                pgeSetup.tab.setHidden(false);
                pgePricing.tab.setHidden(false);
                pgeStock.tab.setHidden(true);
                pgeCommodity.tab.setHidden(true);
                pgeAssembly.tab.setHidden(true);
                pgeBundle.tab.setHidden(true);
                pgeKit.tab.setHidden(true);
                pgeFactory.tab.setHidden(true);
                pgeNotes.tab.setHidden(false);
                pgeAttachments.tab.setHidden(false);
                pgeSales.tab.setHidden(true);
                pgePOS.tab.setHidden(true);
                pgeManufacturing.tab.setHidden(true);
//                pgeUPC.tab.setHidden(true);
                pgeContract.tab.setHidden(true);
                break;
            case 'Service':
                pgeDetails.tab.setHidden(false);
                pgeSetup.tab.setHidden(false);
                pgePricing.tab.setHidden(false);
                pgeStock.tab.setHidden(true);
                pgeCommodity.tab.setHidden(true);
                pgeAssembly.tab.setHidden(true);
                pgeBundle.tab.setHidden(true);
                pgeKit.tab.setHidden(true);
                pgeFactory.tab.setHidden(true);
                pgeNotes.tab.setHidden(false);
                pgeAttachments.tab.setHidden(false);
                pgeSales.tab.setHidden(true);
                pgePOS.tab.setHidden(true);
                pgeManufacturing.tab.setHidden(true);
//                pgeUPC.tab.setHidden(true);
                pgeContract.tab.setHidden(true);
                break;
            case 'Commodity':
                pgeDetails.tab.setHidden(false);
                pgeSetup.tab.setHidden(false);
                pgePricing.tab.setHidden(false);
                pgeStock.tab.setHidden(false);
                pgeCommodity.tab.setHidden(false);
                pgeAssembly.tab.setHidden(true);
                pgeBundle.tab.setHidden(true);
                pgeKit.tab.setHidden(true);
                pgeFactory.tab.setHidden(true);
                pgeNotes.tab.setHidden(false);
                pgeAttachments.tab.setHidden(false);
                pgeSales.tab.setHidden(true);
                pgePOS.tab.setHidden(true);
                pgeManufacturing.tab.setHidden(true);
//                pgeUPC.tab.setHidden(true);
                pgeContract.tab.setHidden(true);
                break;

            case 'Raw Material':
                pgeDetails.tab.setHidden(false);
                pgeSetup.tab.setHidden(false);
                pgePricing.tab.setHidden(false);
                pgeStock.tab.setHidden(false);
                pgeCommodity.tab.setHidden(true);
                pgeAssembly.tab.setHidden(true);
                pgeBundle.tab.setHidden(true);
                pgeKit.tab.setHidden(true);
                pgeFactory.tab.setHidden(false);
                pgeNotes.tab.setHidden(false);
                pgeAttachments.tab.setHidden(false);
                pgeSales.tab.setHidden(false);
                pgePOS.tab.setHidden(true);
                pgeManufacturing.tab.setHidden(false);
//                pgeUPC.tab.setHidden(true);
                pgeContract.tab.setHidden(true);
                break;
        }

    },

    onUOMUnitMeasureSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepDetailUOM');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colDetailUnitMeasure') {
            current.set('intUnitMeasureId', records[0].get('intUnitMeasureId'));
            current.set('intDecimalDisplay', records[0].get('intDecimalDisplay'));
            current.set('intDecimalCalculation', records[0].get('intDecimalCalculation'));
            current.set('tblICUnitMeasure', records[0]);

            var uoms = grid.store.data.items;
            var exists = Ext.Array.findBy(uoms, function (row) {
                if (row.get('ysnStockUnit') === true) {
                    return true;
                }
            });
            if (exists) {
                var currUOM = exists.get('tblICUnitMeasure');
                if (currUOM) {
                    var conversions = currUOM.vyuICGetUOMConversions;
                    if (!conversions) {
                        conversions = currUOM.data.vyuICGetUOMConversions;
                    }
                    var selectedUOM = Ext.Array.findBy(conversions, function (row) {
                        if (row.intUnitMeasureId === records[0].get('intUnitMeasureId')) {
                            return true;
                        }
                    });
                    if (selectedUOM) {
                        current.set('dblUnitQty', selectedUOM.dblConversionToStock);
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

    onUOMBeforeCheckChange: function (obj, rowIndex, checked, eOpts) {
        if (obj.dataIndex === 'ysnAllowPurchase' || obj.dataIndex === 'ysnAllowSale'){
            var grid = obj.up('grid');
            var selModel = grid.getSelectionModel();

            if (selModel.hasSelection()){
                var current = selModel.getSelection()[0];
                if (current.data.ysnStockUnit !== true){
                    return false;
                }
            }
            else {
                return false;
            }
        }
    },

    onUOMStockUnitCheckChange: function (obj, rowIndex, checked, eOpts) {
        if (obj.dataIndex === 'ysnStockUnit'){
            var grid = obj.up('grid');

            var current = grid.view.getRecord(rowIndex);

            if (checked === true){
                var uoms = grid.store.data.items;
                var currUOM = current.get('tblICUnitMeasure');
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
                        uom.set('ysnAllowPurchase', false);
                        uom.set('ysnAllowSale', false);
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
            else {
                if (current){
                    current.set('ysnAllowPurchase', false);
                    current.set('ysnAllowSale', false);
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
            iRely.Funtions.showErrorDialog('Please select a location to edit.');
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
            iRely.Funtions.showErrorDialog('Please select a location to edit.');
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

    // <editor-fold desc="UPC Tab Methods and Event Handlers">

    onUpcUOMSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepUPC');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colUPCUnitMeasure')
        {
            current.set('intItemUnitMeasureId', records[0].get('intItemUOMId'));
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

    onPricingDoubleClick: function(view, record, item, index, e, eOpts){
        var win = view.up('window');
        var me = win.controller;
        var vm = win.getViewModel();
        var pricingRecord = record;

        var defaultLocation = 0;
        if (app.DefaultLocation > 0){
            var itemLocation = Ext.Array.findBy(win.viewModel.data.current.tblICItemLocations().data.items, function(record) {
                if (record.get('intItemLocationId') === app.DefaultLocation){
                    return true;
                }
                else { return false; }
            });
            if (itemLocation) defaultLocation = itemLocation.get('intItemLocationId');
        }

        if (!record){
            iRely.Funtions.showErrorDialog('Please select a price to edit.');
            return;
        }

        if (vm.data.current.phantom === true) {
            win.context.data.saveRecord({ successFn: function(batch, eOpts){
                me.openItemPricingScreen('edit', win, pricingRecord, win.viewModel.data.current.tblICItemPricings().data, defaultLocation);
            } });
        }
        else {
            win.context.data.validator.validateRecord({ window: win }, function(valid) {
                if (valid) {
                    me.openItemPricingScreen('edit', win, pricingRecord, win.viewModel.data.current.tblICItemPricings().data, defaultLocation);
                }
            });
        }
    },

    onAddPricingClick: function(button, e, eOpts) {
        var win = button.up('window');
        var me = win.controller;
        var vm = win.getViewModel();

        var defaultLocation = 0;
        if (app.DefaultLocation > 0){
            var record = Ext.Array.findBy(win.viewModel.data.current.tblICItemLocations().data.items, function(record) {
                if (record.get('intItemLocationId') === app.DefaultLocation){
                    return true;
                }
                else { return false; }
            });
            if (record) defaultLocation = record.get('intItemLocationId');
        }

        if (vm.data.current.phantom === true) {
            win.context.data.saveRecord({ successFn: function(batch, eOpts){
                var record = win.viewModel.data.current.tblICItemUOMs().data.items[0];
                me.openItemPricingScreen('new', win, record, win.viewModel.data.current.tblICItemPricings().data, defaultLocation);
            } });
        }
        else {
            win.context.data.validator.validateRecord({ window: win }, function(valid) {
                if (valid) {
                    var record = win.viewModel.data.current.tblICItemUOMs().data.items[0];
                    me.openItemPricingScreen('new', win, record, win.viewModel.data.current.tblICItemPricings().data, defaultLocation);
                }
            });
        }
    },

    onEditPricingClick: function(button, e, eOpts) {
        var win = button.up('window');
        var me = win.controller;
        var vm = win.getViewModel();
        var grd = button.up('grid');
        var selection = grd.getSelectionModel().getSelection();

        if (selection.length <= 0){
            iRely.Funtions.showErrorDialog('Please select a price to edit.');
            return;
        }

        var defaultLocation = 0;
        if (app.DefaultLocation > 0){
            var record = Ext.Array.findBy(win.viewModel.data.current.tblICItemLocations().data.items, function(record) {
                if (record.get('intItemLocationId') === app.DefaultLocation){
                    return true;
                }
                else { return false; }
            });
            if (record) defaultLocation = record.get('intItemLocationId');
        }

        if (vm.data.current.phantom === true) {
            win.context.data.saveRecord({ successFn: function(batch, eOpts){
                me.openItemPricingScreen('edit', win, selection[0], win.viewModel.data.current.tblICItemPricings().data, defaultLocation);
            } });
        }
        else {
            win.context.data.validator.validateRecord({ window: win }, function(valid) {
                if (valid) {
                    me.openItemPricingScreen('edit', win, selection[0], win.viewModel.data.current.tblICItemPricings().data, defaultLocation);
                }
            });
        }
    },

    openItemPricingScreen: function (action, window, record, table, defaultLocation) {
        var win = window;
        var me = win.controller;
        var screenName = 'Inventory.view.ItemPricing';

        Ext.require([
            screenName,
                screenName + 'ViewModel',
                screenName + 'ViewController'
        ], function() {
            var screen = 'ic' + screenName.substring(screenName.indexOf('view.') + 5, screenName.length);
            var view = Ext.create(screenName, { controller: screen.toLowerCase(), viewModel: screen.toLowerCase() });
            view.on('destroy', me.onDestroyItemPricingScreen, me, { window: win });

            var controller = view.getController();
            var current = win.getViewModel().data.current;
            if (action === 'edit'){
                controller.show({ itemId: current.get('intItemId'), priceId: record.get('intItemPricingId'), table: table, defaultLocation: defaultLocation, action: action });
            }
            else if (action === 'new') {
                if (record){
                    controller.show({ itemId: current.get('intItemId'), uomId: record.get('intItemUOMId'), table: table, defaultLocation: defaultLocation, action: action });
                }
                else {
                    controller.show({ itemId: current.get('intItemId'), table: table, defaultLocation: defaultLocation, action: action });
                }
            }
        });
    },

    onDestroyItemPricingScreen: function(win, eOpts) {
        var me = eOpts.window.getController();
        var win = eOpts.window;
        var grdPricing = win.down('#grdPricing');
        var vm = win.getViewModel();
        var itemId = vm.data.current.get('intItemId');
        var filterItem = grdPricing.store.filters.items[0];

        filterItem.setValue(itemId);
        filterItem.config.value = itemId;
        filterItem.initialConfig.value = itemId;
        grdPricing.store.load();
    },

    onEditPricingLevel: function (editor, context, eOpts) {
        if (context.field === 'strPricingMethod' || context.field === 'dblAmountRate') {
            if (context.record) {
                var win = context.grid.up('window');
                var grdPricing = win.down('#grdPricing');
                var pricingItems = grdPricing.store.data.items;
                var pricingMethod = context.record.get('strPricingMethod');
                var amount = context.record.get('dblCommissionRate');

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
                            var dblSalePrice = selectedLoc.get('dblSalePrice') * (context.record.get('dblUnit'));
                            var amountRate = 0;
                            switch (pricingMethod) {
                                case 'Fixed Dollar Amount':
                                case 'Markup Standard Cost':
                                case 'Discount Sales Price':
                                case 'MSRP Discount':
                                    amountRate = amount;
                                    break;
                                case 'Percent of Margin':
                                case 'Percent of Margin (MSRP)':
                                    var percent = amount / 100;
                                    amountRate = dblSalePrice * percent;
                                    break;
                                case 'None':
                                default:
                                    amountRate = 0;
                                    break;
                            }
                            context.record.set('dblAmountRate', amountRate);
                            context.record.set('dblUnitPrice', dblSalePrice - amountRate);
                        }
                    }
                }
            }
        }
    },

    // </editor-fold>

    // <editor-fold desc="Stock Tab Methods and Event Handlers">

    onStockSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepStock');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colStockLocation'){
            current.set('intItemLocationId', records[0].get('intItemLocationId'));
        }
        else if (combo.column.itemId === 'colStockUOM') {
            current.set('intItemUnitMeasureId', records[0].get('intItemUOMId'));
        }
    },

    // </editor-fold>

    // <editor-fold desc="Commodity Tab Methods and Event Handlers">

    onCommoditySelect: function (combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var commodity = records[0];
        var intCommodityId = commodity.get('intCommodityId');

        var pnlCommodity = combo.up('panel');
        var cboOrigin = pnlCommodity.down('#cboOrigin');
        var cboProductType = pnlCommodity.down('#cboProductType');
        var cboRegion = pnlCommodity.down('#cboRegion');
        var cboSeason = pnlCommodity.down('#cboSeason');
        var cboClass = pnlCommodity.down('#cboClass');
        var cboProductLine = pnlCommodity.down('#cboProductLine');

        var filter = [{ dataIndex: 'intCommodityId', value: intCommodityId, condition: 'eq' }];

        cboOrigin.defaultFilters = filter;
        cboProductType.defaultFilters = filter;
        cboRegion.defaultFilters = filter;
        cboSeason.defaultFilters = filter;
        cboClass.defaultFilters = filter;
        cboProductLine.defaultFilters = filter;
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
        }
        else if (combo.column.itemId === 'colAssemblyUOM') {
            current.set('intItemUnitMeasureId', records[0].get('intItemUOMId'));
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

    onCategorySelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var controller = win.getController();
        var vm = win.viewModel;
        var current = vm.data.current;

        controller.isLoadedLocation = false;
        Ext.Array.each(current.tblICItemLocations().data.items, function (location) {
            if (location.get('intCategoryId') !== records[0].get('intCategoryId')) {
                location.set('intCategoryId', records[0].get('intCategoryId'));
                location.set('strCategory', records[0].get('strCategoryCode'));
                controller.isLoadedLocation = true;
            }
        });
    },

    init: function(application) {
        this.control({
            "#cboType": {
                change: this.onInventoryTypeChange
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
            "#cboUpcUOM": {
                select: this.onUpcUOMSelect
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
            "#cboStockLocation": {
                select: this.onStockSelect
            },
            "#cboStockUOM": {
                select: this.onStockSelect
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
            "#colAllowSale": {
                beforecheckchange: this.onUOMBeforeCheckChange
            },
            "#colAllowPurchase": {
                beforecheckchange: this.onUOMBeforeCheckChange
            },
            "#grdPricing": {
                itemdblclick: this.onPricingDoubleClick
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
                select: this.onCategorySelect
            }
        });
    }
});
