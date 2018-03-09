Ext.define('Inventory.view.ItemViewController', {
    extend: 'Inventory.view.InventoryBaseViewController',
    alias: 'controller.icitem',

    config: {
        helpURL: '/display/DOC/Items',
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
            txtDescription: {
                value: '{current.strDescription}',   
                fieldLabel: '{setDescriptionMark}'
            },
            txtModelNo: {
                value: '{current.strModelNo}',
                hidden: '{HideDisableForComment}',
                readOnly: '{readOnlyForOtherCharge}'
            },
            cboType: {
                value: '{current.strType}',
                store: '{itemTypes}',
                readOnly: '{readOnlyForDiscountType}'
            },
            cboBundleType: {
                value: '{current.strBundleType}',
                store: '{bundleTypes}'
            },
            txtShortName: {
                value: '{current.strShortName}',
                hidden: '{HideDisableForComment}'
            },
            cboManufacturer: {
                value: '{current.strManufacturer}',
                origValueField: 'intManufacturerId',
                store: '{manufacturer}',
                readOnly: '{readOnlyForOtherCharge}',
                hidden: '{HideDisableForComment}'
            },
            cboBrand: {
                value: '{current.strBrand}',
                origValueField: 'intBrandId',
                store: '{brand}',
                readOnly: '{readOnlyForOtherCharge}',
                hidden: '{HideDisableForComment}'
            },
            cboStatus: {
                value: '{current.strStatus}',
                store: '{itemStatuses}',
                readOnly: '{readOnlyForDiscountType}',
                hidden: '{HideDisableForComment}'
            },
            cboCategory: {
                value: '{current.strCategory}',                
                origValueField: 'intCategoryId',
                store: '{itemCategory}',
                defaultFilters: [{
                    column: 'strInventoryType',
                    value: '{current.strType}',
                    conjunction: 'and'
                }],
                hidden: '{HideDisableForComment}'
            },
            cboCommodity: {
                readOnly: '{readOnlyCommodity}',
                hidden: '{HideDisableForComment}',
                origValueField: 'intCommodityId',
                value: '{current.strCommodityCode}',
                store: '{commodity}'
            },
            cboLotTracking: {
                value: '{current.strLotTracking}',
                store: '{lotTracking}',
                readOnly: '{checkStockTracking}',
                hidden: '{HideDisableForComment}'
            },
            cboTracking: {
                value: '{current.strInventoryTracking}',
                store: '{invTracking}',
                readOnly: '{checkLotTracking}',
                hidden: '{HideDisableForComment}'
            },
            chkUseWeighScales: {
                value: '{current.ysnUseWeighScales}',
                readOnly: '{readOnlyForOtherCharge}',
                hidden: '{HideDisableForComment}'
            },
            chkLotWeightsRequired: {
                value: '{current.ysnLotWeightsRequired}',
                readOnly: '{readOnlyForOtherCharge}',
                hidden: '{!isLotTracked}'
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
            // cfgBundle: {
            //     hidden: '{pgeBundleHide}'
            // },
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
                // colDetailWeightUOM: {
                //     dataIndex: 'strWeightUOM',
                //     editor: {
                //         origValueField: 'intUnitMeasureId',
                //         origUpdateField: 'intWeightUOMId',
                //         store: '{weightUOM}',
                //         defaultFilters: [{
                //             column: 'strUnitType',
                //             value: 'Weight',
                //             conjunction: 'and'
                //         }]
                //     }
                // },
                colDetailShortUPC: {
                    dataIndex: 'strUpcCode',
                    hidden: '{readOnlyForOtherCharge}'
                },
                colDetailUpcCode: {
                    dataIndex: 'strLongUPCCode',
                    hidden: '{readOnlyForOtherCharge}'
                },
                colBaseUnit: {
                    dataIndex: 'ysnStockUnit',
                    hidden: '{readOnlyForOtherCharge}'
                },
                colStockUOM: {
                    dataIndex: 'ysnStockUOM',                    
                    hidden: true // TODO: Hide it for now. Show it again in 18.3
                    //hidden: '{readOnlyForOtherCharge}'                    
                },                
                colAllowSale: 'ysnAllowSale',
                colAllowPurchase: {
                    //disabled: '{readOnlyOnBundleItems}',
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
                colDetailMaxQty: {
                    dataIndex: 'dblMaxQty',
                    hidden: '{readOnlyForOtherCharge}'
                }
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
                value: '{current.strFuelCategory}',
                origValueField: 'intRinFuelCategoryId',
                origUpdateField: 'intRINFuelTypeId',
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
                value: '{current.strMedicationTag}',
                origValueField: 'intTagId',
                origUpdateField: 'intMedicationTag',
                store: '{inventoryTags}',
                defaultFilters: [
                    {
                        column: 'strType',
                        value: 'Medication Tag'
                    }
                ]
            },
            cboIngredientTag: {
                value: '{current.strIngredientTag}',
                origValueField: 'intTagId',
                origUpdateField: 'intIngredientTag',
                store: '{inventoryTags}',
                defaultFilters: [
                    {
                        column: 'strType',
                        value: 'Ingredient Tag'
                    }
                ]
            },
            cboHazmat: {
                value: '{current.strHazmatTag}',
                origValueField: 'intTagId',
                origUpdateField: 'intHazmatTag',
                store: '{inventoryTags}',
                defaultFilters: [
                    {
                        column: 'strType',
                        value: 'Hazmat Message'
                    }
                ]
            },
            cboEnergyTrac: {
                value: '{current.strItemMessage}',
                origValueField: 'intTagId',
                origUpdateField: 'intItemMessage',
                store: '{inventoryTags}',
                defaultFilters: [
                    {
                        column: 'strType',
                        value: 'Item Message'
                    }
                ]
            },
            txtVolumeRebateGroup: '{current.strVolumeRebateGroup}',
            grdItemLicense: {
                colItemLicenseCode: {
                    dataIndex: 'strCode',
                    editor: {
                        origValueField: 'intLicenseTypeId'
                    }
                },
                colItemLicenseTypeDescription: 'strCodeDescription'
            },
            cboPhysicalItem: {
                value: '{current.strPhysicalItem}',
                origUpdateField: 'intPhysicalItem',
                origValueField: 'intItemId',
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
                value: '{current.strSecondaryStatus}',
                store: '{lotStatus}',
                origValueField: 'intLotStatusId'
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
                //value: '{current.intDimensionUOMId}',
                value: '{current.strDimensionUOM}',
                store: '{mfgDimensionUom}',
                defaultFilters: [
                    {
                        column: 'intItemId',
                        value: '{current.intItemId}',
                        conjunction: 'and'
                    },
                    {
                        column: 'strUnitType',
                        value: 'Packed',
                        conjunction: 'and'
                    }                    
                ],                
            },
            cboWeightUOM: {
                //value: '{current.intWeightUOMId}',
                value: '{current.strWeightUOM}',
                store: '{mfgWeightUom}',
                defaultFilters: [
                    {
                        column: 'intItemId',
                        value: '{current.intItemId}',
                        conjunction: 'and'
                    },
                    {
                        column: 'strUnitType',
                        value: 'Weight',
                        conjunction: 'and'
                    }
                ],
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
                        }],
                        origValueField: 'intItemLocationId'
                    }
                },
                colCustomerXrefCustomer: {
                    dataIndex: 'strCustomerName',
                    editor: {
                        store: '{custXrefCustomer}',
                        origValueField: 'intEntityId',
                        origUpdateField: 'intCustomerId'
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
                        }],
                        origValueField: 'intItemLocationId'
                    }
                },
                colVendorXrefVendor: {
                    dataIndex: 'strVendorName',
                    editor: {
                        store: '{vendorXrefVendor}',
                        origValueField: 'intEntityId',
                        origUpdateField: 'intVendorId'
                    }
                },
                colVendorXrefProduct: 'strVendorProduct',
                colVendorXrefDescription: 'strProductDescription',
                colVendorXrefConversionFactor: 'dblConversionFactor',
                colVendorXrefUnitMeasure: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{vendorXrefUom}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{current.intItemId}'
                        }],
                        origValueField: 'intItemUOMId',
                        origUpdateField: 'intItemUnitMeasureId'
                    }
                }
            },

            //--------//
            //Cost Tab//
            //--------//
            chkInventoryCost: '{current.ysnInventoryCost}',
            chkAccrue: {
                value: '{current.ysnAccrue}',
                hidden: true
            },
            chkMTM: '{current.ysnMTM}',
            // cboM2M: {
            //     value: '{current.intM2MComputationId}',
            //     store: '{m2mComputations}',
            //     hidden: true
            // },
            chkPrice: '{current.ysnPrice}',
            chkIsBasket: {
                value: '{current.ysnIsBasket}',
                //hidden: '{hideOnBundleItems}'
                hidden: true
            },
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

            uomCostUnitQty: {
                readOnly: '{checkPerUnitCostMethod}',
                readOnlyMode: 'uom',
                value: '{current.costUnitQty}',
                activeRecord: '{current}',
                mutateByProperties: true
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
                value: '{current.strPatronageCategory}',
                origValueField: 'intPatronageCategoryId',
                store: '{patronage}'
            },
            cboPatronageDirect: {
                value: '{current.strPatronageDirect}',
                origValueField: 'intPatronageCategoryId',
                origUpdateField: 'intPatronageCategoryDirectId',
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
                colContractItemNo: 'strContractItemNo',
                colItemContractStatus: {
                    dataIndex: 'strStatus',
                    editor: {
                        readOnly: '{readOnlyContractItemStatus}',
                        store: '{contractstatus}'
                    }
                }
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
                colPricingAmount: {
                    dataIndex: 'dblAmountPercent'
                },
                colPricingRetailPrice: {
                    dataIndex: 'dblSalePrice'
                },
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
                    //hidden: true,
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
                colPricingLevelEffectiveDate: 'dtmEffectiveDate',
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
                    //hidden: true,
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
                colStockInTransitDirect: 'dblInTransitDirect',
                colStockBackOrder: {
                    dataIndex: 'dblCalculatedBackOrder', // formerly, this is: colStockBackOrder: 'dblBackOrder',
                    hidden: true
                },
                colStockCommitted: 'dblOrderCommitted',
                colStockOnStorage: 'dblUnitStorage',
                colStockConsignedPurchase: 'dblConsignedPurchase',
                colStockConsignedSale: {
                    dataIndex: 'dblConsignedSale',
                    hidden: true
                },
                colStockReserved: 'dblUnitReserved',
                colStockAvailable: 'dblAvailable'
            },

            //-------------//
            //Commodity Tab//
            //-------------//
            txtGaShrinkFactor: '{current.dblGAShrinkFactor}',
            cboOrigin: {
                value: '{current.strOrigin}',
                origUpdateField: 'intOriginId',
                origValueField: 'intCommodityAttributeId',
                store: '{originAttribute}',
                defaultFilters: [{
                    column: 'intCommodityId',
                    value: '{current.intCommodityId}'
                }]
            },
            cboProductType: {
                value: '{current.strProductType}',
                origValueField: 'intCommodityAttributeId',
                origUpdateField: 'intProductTypeId',
                store: '{productTypeAttribute}',
                defaultFilters: [{
                    column: 'intCommodityId',
                    value: '{current.intCommodityId}'
                }]
            },
            cboRegion: {
                value: '{current.strRegion}',
                origUpdateField: 'intRegionId',
                origValueField: 'intCommodityAttributeId',
                store: '{regionAttribute}',
                defaultFilters: [{
                    column: 'intCommodityId',
                    value: '{current.intCommodityId}'
                }]
            },
            cboSeason: {
                value: '{current.strSeason}',
                origValueField: 'intCommodityAttributeId',
                origUpdateField: 'intSeasonId',
                store: '{seasonAttribute}',
                defaultFilters: [{
                    column: 'intCommodityId',
                    value: '{current.intCommodityId}'
                }]
            },
            cboClass: {
                value: '{current.strClass}',
                origValueField: 'intCommodityAttributeId',
                origUpdateField: 'intClassVarietyId',
                store: '{classAttribute}',
                defaultFilters: [{
                    column: 'intCommodityId',
                    value: '{current.intCommodityId}'
                }]
            },
            cboProductLine: {
                value: '{current.strProductLine}',
                origValueField: 'intCommodityProductLineId',
                origUpdateField: 'intProductLineId',
                store: '{productLineAttribute}',
                defaultFilters: [{
                    column: 'intCommodityId',
                    value: '{current.intCommodityId}'
                }]
            },
            cboGrade: {
                value: '{current.strGrade}',
                store: '{gradeAttribute}',
                origValueField: 'intCommodityAttributeId',
                origUpdateField: 'intGradeId',
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

            // //------------//
            // //Assembly Tab//
            // //------------//
            // grdAssembly: {
            //     colAssemblyComponent: {
            //         dataIndex: 'strItemNo',
            //         editor: {
            //             store: '{assemblyItem}',
            //             defaultFilters: [
            //                 {
            //                     column: 'strLotTracking',
            //                     value: 'No',
            //                     conjunction: 'and'
            //                 }
            //             ]
            //         }
            //     },
            //     colAssemblyQuantity: 'dblQuantity',
            //     colAssemblyDescription: 'strItemDescription',
            //     colAssemblyUOM: {
            //         dataIndex: 'strUnitMeasure',
            //         editor: {
            //             store: '{assemblyUOM}',
            //             defaultFilters: [{
            //                 column: 'intItemId',
            //                 value: '{grdAssembly.selection.intAssemblyItemId}'
            //             }]
            //         }
            //     },
            //     colAssemblyUnit: 'dblUnit'
            // },

            //------------------//
            // Add On Tab       //
            //------------------//
            grdAddOn: {
                colAddOnItem: {
                    dataIndex: 'strAddOnItemNo',
                    editor: {
                        origValueField: 'strItemNo',
                        origUpdateField: 'strAddOnItemNo',
                        store: '{bundleItem}',
                        defaultFilters: '{addOnItemFilter}'
                    }
                },
                colAddOnDescription: 'strDescription',
                colAddOnQuantity: {
                    dataIndex: 'dblQuantity'
                },
                colAddOnUOM: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{bundleUOM}',
                        origValueField: 'intItemUOMId',
                        origUpdateField: 'intItemUOMId',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdAddOn.selection.intAddOnItemId}',
                            conjunction: 'or'
                        }]
                    }
                }
            },

            //------------------//
            // Substitute       //
            //------------------//
            grdSubstitute: {
                colSubstituteItem: {
                    dataIndex: 'strSubstituteItemNo',
                    editor: {
                        origValueField: 'strItemNo',
                        origUpdateField: 'strSubstituteItemNo',
                        store: '{bundleItem}',
                        defaultFilters: [
                            {
                                column: 'strType',
                                value: 'Inventory',
                                conjunction: 'and'
                            },
                            {
                                column: 'intItemId',
                                value: '{current.intItemId}',
                                condition: 'noteq',
                                conjunction: 'and'
                            }                        
                        ]
                    }
                },
                colSubstituteDescription: 'strDescription',
                colSubstituteQuantity: 'dblQuantity',
                colSubstituteMarkUpOrDown: 'dblMarkUpOrDown',
                colSubstituteUOM: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{bundleUOM}',
                        origValueField: 'intItemUOMId',
                        origUpdateField: 'intItemUOMId',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdSubstitute.selection.intSubstituteItemId}',
                            conjunction: 'or'
                        }]
                    }
                },
                colSubstituteBeginDate: 'dtmBeginDate',
                colSubstituteEndDate: 'dtmEndDate'
            },            

            // //---------------//
            // //Kit Details Tab//
            // //---------------//
            // grdKit: {
            //     colKitComponent: 'strComponent',
            //     colKitInputType: {
            //         dataIndex: 'strInputType',
            //         editor: {
            //             store: '{inputTypes}'
            //         }
            //     }
            // },

            // grdKitDetails: {
            //     colKitItem: {
            //         dataIndex: 'strItemNo',
            //         editor: {
            //             store: '{kitItem}',
            //             defaultFilters: [{
            //                 column: 'strType',
            //                 value: 'Inventory'
            //             }]
            //         }
            //     },
            //     colKitItemDescription: 'strDescription',
            //     colKitItemQuantity: 'dblQuantity',
            //     colKitItemUOM: {
            //         dataIndex: 'strUnitMeasure',
            //         editor: {
            //             store: '{kitUOM}'
            //         }
            //     },
            //     colKitItemPrice: 'dblPrice',
            //     colKitItemSelected: 'ysnSelected'
            // },

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
                        store: '{factoryManufacturingCell}',
                        defaultFilters: [
                            {
                                column: 'strLocationName',
                                value: '{grdFactory.selection.strLocationName}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colCellNameDefault: 'ysnDefault',
                colCellPreference: 'intPreference'
            },

            grdOwner: {
                colOwner: {
                    dataIndex: 'strCustomerNumber',
                    editor: {
                        origValueField: 'intEntityId',
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
            win = me.getView(),
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
            grdAddOn = win.down('#grdAddOn'),
            grdSubstitute = win.down('#grdSubstitute'),
            grdKit = win.down('#grdKit'),
            grdKitDetails = win.down('#grdKitDetails'),
            grdItemLicense = win.down('#grdItemLicense');

        win.context = Ext.create('iRely.Engine', {
            window : win,
            store  : store,
            createRecord : me.createRecord,
            validateRecord : me.validateRecord,
            deleteMsg: me.deleteMessage,
            binding: me.config.binding,
            fieldTitle: 'strItemNo',
            enableAudit: true,
            enableCustomTab: true,


            enableActivity: true,
            createTransaction: Ext.bind(me.createTransaction, me),
            
            
            //onSaveClick: me.saveAndPokeGrid(win, grdUOM),
            // attachment: Ext.create('iRely.attachment.Manager', {
            //     type: 'Inventory.Item',
            //     window: win
            // }),
            include: 'vyuICGetCompactItem',
            details: [
                {
                    key: 'tblICItemUOMs',
                    lazy: true, 
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdUOM,
                        deleteButton : grdUOM.down('#btnDeleteUom')
                    })
                },
                {
                    key: 'tblICItemLocations',
                    lazy: true, 
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdLocationStore,
                        deleteButton : grdLocationStore.down('#btnDeleteLocation'),
                        position: 'none'
                    }),
                    details: [
                        {
                            key: 'tblICItemSubLocations',
                            component: Ext.create('iRely.grid.Manager', {
                                grid: grdItemSubLocations,
                                deleteButton : grdItemSubLocations.down('#btnDeleteItemSubLocation')
                            })
                        }
                    ]
                },
                {
                    key: 'tblICItemVendorXrefs',
                    lazy: true, 
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdVendorXref,
                        deleteButton : grdVendorXref.down('#btnDeleteVendorXref')
                    })
                },
                {
                    key: 'tblICItemCustomerXrefs',
                    lazy: true, 
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdCustomerXref,
                        deleteButton : grdCustomerXref.down('#btnDeleteCustomerXref')
                    })
                },
                {
                    key: 'tblICItemContracts',
                    lazy: true, 
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdContractItem,
                        deleteButton : grdContractItem.down('#btnDeleteContractItem')
                    }),
                    details: [
                        {
                            key: 'tblICItemContractDocuments',
                            component: Ext.create('iRely.grid.Manager', {
                                grid: grdDocumentAssociation,
                                deleteButton : grdDocumentAssociation.down('#btnDeleteDocumentAssociation')
                            })
                        }
                    ]
                },
                {
                    key: 'tblICItemMotorFuelTaxes',
                    lazy: true, 
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdMotorFuelTax,
                        deleteButton: grdMotorFuelTax.down('#btnDeleteMFT')
                    })
                },
                {
                    key: 'tblICItemCertifications',
                    lazy: true, 
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdCertification,
                        deleteButton : grdCertification.down('#btnDeleteCertification')
                    })
                },
                {
                    key: 'tblICItemPOSCategories',
                    lazy: true, 
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdCategory,
                        deleteButton : win.down('#btnDeleteCategories')
                    })
                },
                {
                    key: 'tblICItemPOSSLAs',
                    lazy: true, 
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdServiceLevelAgreement'),
                        deleteButton : win.down('#btnDeleteSLA')
                    })
                },
                {
                    key: 'tblICItemAccounts',
                    lazy: true, 
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdGlAccounts,
                        deleteButton : grdGlAccounts.down('#btnDeleteGlAccounts')
                    })
                },
                {
                    key: 'tblICItemStocks',
                    lazy: true, 
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdStock,
                        position: 'none'
                    })
                },
                {
                    key: 'tblICItemCommodityCosts',
                    lazy: true, 
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdCommodityCost,
                        deleteButton : grdCommodityCost.down('#btnDeleteCommodityCost')
                    })
                },
                {
                    key: 'tblICItemPricings',
                    lazy: true, 
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdPricing,
                        deleteButton : grdPricing.down('#btnDeletePricing'),
                        position: 'none'
                    })
                },
                {
                    key: 'tblICItemPricingLevels',
                    lazy: true, 
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdPricingLevel,
                        deleteButton : grdPricingLevel.down('#btnDeletePricingLevel')
                    })
                },
                {
                    key: 'tblICItemSpecialPricings',
                    lazy: true, 
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdSpecialPricing,
                        deleteButton : grdSpecialPricing.down('#btnDeleteSpecialPricing')
                    })
                },
                {
                    key: 'tblICItemAddOns',
                    lazy: true, 
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdAddOn,
                        deleteButton : grdAddOn.down('#btnDeleteAddOn'),
                        createRecord: me.onAddOnItemCreateRecord
                    })
                },
                {
                    key: 'tblICItemSubstitutes',
                    lazy: true, 
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdSubstitute,
                        deleteButton : grdSubstitute.down('#btnDeleteSubsitute'),
                        createRecord: me.onSubstituteItemCreateRecord
                    })
                },                
                {
                    key: 'tblICItemOwners',
                    lazy: true, 
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdOwner,
                        deleteButton : grdOwner.down('#btnDeleteOwner')
                    })
                },
                {
                    key: 'tblICItemFactories',
                    lazy: true, 
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdFactory,
                        deleteButton : grdFactory.down('#btnDeleteFactory')
                    }),
                    details: [
                        {
                            key: 'tblICItemFactoryManufacturingCells',
                            component: Ext.create('iRely.grid.Manager', {
                                grid: grdManufacturingCellAssociation,
                                deleteButton : grdManufacturingCellAssociation.down('#btnDeleteManufacturingCellAssociation')
                            })
                        }
                    ]
                },
                {
                    key: 'tblICItemLicenses',
                    lazy: true, 
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdItemLicense,
                        deleteButton: grdItemLicense.down('#btnRemoveLicense'),
                        position: 'end'
                    })
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
        var colStockInTransitDirect = grdStock.columns[6];
        colStockInTransitDirect.summaryRenderer = this.StockSummaryRenderer        
        var colStockBackOrder = grdStock.columns[7];
        colStockBackOrder.summaryRenderer = this.StockSummaryRenderer
        var colStockCommitted = grdStock.columns[8];
        colStockCommitted.summaryRenderer = this.StockSummaryRenderer
        var colStockOnStorage = grdStock.columns[9];
        colStockOnStorage.summaryRenderer = this.StockSummaryRenderer
        var colStockConsignedPurchase = grdStock.columns[10];
        colStockConsignedPurchase.summaryRenderer = this.StockSummaryRenderer
        var colStockConsignedSale = grdStock.columns[11];
        colStockConsignedSale.summaryRenderer = this.StockSummaryRenderer
        var colStockReserved = grdStock.columns[12];
        colStockReserved.summaryRenderer = this.StockSummaryRenderer
        var colStockAvailable = grdStock.columns[13];
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

    onBundleItemCreateRecord: function(config, action) {
        var record = Ext.create('Inventory.model.ItemBundle');
        record.set('dblQuantity', 1.00);
        action(record);
    },

    onAddOnItemCreateRecord: function(config, action) {
        var record = Ext.create('Inventory.model.ItemAddOn');
        action(record);
    },

    onSubstituteItemCreateRecord: function(config, action) {
        var record = Ext.create('Inventory.model.ItemSubstitute');
        record.set('dblQuantity', 1.00);
        record.set('dblMarkUpOrDown', 1.00);
        action(record);
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

    show: function(config) {
        "use strict";

        var me = this,
            win = this.getView();

        if (config && config.param.searchTab === 'Bundle') {
            iRely.Functions.openScreen('Inventory.view.Bundle', config);
        }            
        else if (config) {
            win.show();
            var context = win.context ? win.context.initialize() : me.setupContext();

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

        // scope of 'this' here is the iRely.data.Validator. 
        this.validateRecord(config, function (result){
            if (!result) return;

            var itemType = current.get('strType'); 

            // Validate the Unit of Measure. 
            // Make sure Unit Qty value of 1 is only used once.  
            var uomStore = config.viewModel.data.current.tblICItemUOMs();   
            var pricingLevelStore = config.viewModel.data.current.tblICItemPricingLevels();
            var stockKeepingTypes = ['Inventory', 'Finished Good', 'Raw Material'];     
            if(uomStore) {
                if (stockKeepingTypes.includes(itemType))
                {
                    // Validate Unique Unit Qty == 1
                    var duplicateCount = 0;
                    for (var i = 0; i < uomStore.data.items.length; i++) {
                        var u = uomStore.data.items[i];
                        duplicateCount += (!u.dummy && u.data.dblUnitQty == 1) ? 1 : 0; 
                        if (duplicateCount > 1) break; 
                    }

                    if (duplicateCount > 1){
                        iRely.Msg.showError('Please check the Unit of Measure. Only one Unit with Unit Qty equals to one is allowed.', Ext.MessageBox.OK, win);
                        action(false);
                        return;
                    }

                    // Show duplicates of Unit Qty where Unit Qty <> 1.                     
                    for (var i = 0; i < uomStore.data.items.length; i++) {
                        duplicateCount = 1; // In each iteration, initialize the duplicate counter as 1. 
                        var u = uomStore.data.items[i];
                        for (var ii = i + 1; (!u.dummy && ii < uomStore.data.items.length); ii++){
                            var uu = uomStore.data.items[ii];
                            duplicateCount += (!uu.dummy && u.data.dblUnitQty == uu.data.dblUnitQty) ? 1 : 0; 
                            if (duplicateCount > 1) {
                                var msgAction = function (button) {
                                    if (button === 'no') {
                                        action(false);
                                    }
                                    else {
                                        action(true);
                                    }
                                };
                                var msg = 'Is it intended for ' + u.get('strUnitMeasure') + " and " + uu.get('strUnitMeasure') + ' to be the same Unit Qty?'
                                iRely.Functions.showCustomDialog('question', 'yesno', msg, msgAction);
                                return;
                            }
                        }
                    }
                }
            }
            
            if(pricingLevelStore.count() > 0) {
                //Validate effective date duplicates
                for (var i = 0; i < pricingLevelStore.count(); i++){
                    var p = pricingLevelStore.data.items[i],
                        duplicateCount = 1;
                    for(var ii = i + 1; (!p.dummy && ii < pricingLevelStore.count()); ii++){
                        var pp = pricingLevelStore.data.items[ii];
                        duplicateCount += (!pp.dummy && Ext.Date.isEqual(p.data.dtmEffectiveDate, pp.data.dtmEffectiveDate)) ? 1: 0;
                        if(duplicateCount > 1) {
                            iRely.Msg.showError('Pricing levels cannot have the same effective date.', Ext.MessageBox.OK, win);
                            action(false);
                            return;
                        }
                    }
                }
            }
            action(true);                    
        });        
    },

    // <editor-fold desc="Details Tab Methods and Event Handlers">

    onItemTabChange: function(tabPanel, newCard, oldCard, eOpts) {
        switch (newCard.itemId) {
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
                            uom.set('ysnAllowPurchase', !record.get('ysnIsBasket'));
                        }
                    });
                }

                if(!current.get('ysnIsBasket')) {
                    current.set('intCommodityId', null);
                    current.set('strCommodityCode', null);
                }
            }

            else if (record.get('strType') == 'Comment'){
                current.set('strCategory', 'Comment');
            }

            if (current.get('strType') !== record.get('strType')) {
                current.set('strCategory', null);
                current.set('intCategoryId', null);
            }
            
            current.get('HideDisableForComment');
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
                current.set('ysnAllowPurchase', !records[0].get('ysnIsBasket'));
            }
            else {
                current.set('ysnAllowPurchase', true);
            }
            current.set('ysnAllowSale', true);
            current.set('tblICUnitMeasure', records[0]);

            var itemStore = grid.store;
            var stockUnit = itemStore.findRecord('ysnStockUnit', true);
            if (stockUnit) {
                // Convert the selected uom to stock unit. 
                var unitMeasureId = stockUnit.get('intUnitMeasureId');
                me.getConversionValue(
                    current.get('intUnitMeasureId'), 
                    unitMeasureId, 
                    function(value) {
                    current.set('dblUnitQty', value);
                });
            }
        }
    },

    getConversionValue: function (fromUnitMeasureId, toUnitMeasureId, callback) {
        if (!Ext.isNumeric(fromUnitMeasureId))
            return;

        if (!Ext.isNumeric(toUnitMeasureId))
            return;

        iRely.Msg.showWait('Converting units...');
        Inventory.Utils.ajax({
            url: './Inventory/api/Item/GetUnitConversion',
            method: 'Post',
            params: {
                intFromUnitMeasureId: fromUnitMeasureId,
                intToUnitMeasureId: toUnitMeasureId
            }
        })
        .subscribe(
            function (successResponse) {
                var jsonData = Ext.decode(successResponse.responseText);
                var result = jsonData && jsonData.message ? jsonData.message.data : 0.00; 
                if (Ext.isNumeric(result) && callback) {
                    callback(result);
                }
                iRely.Msg.close();
            },

            function (failureResponse) {
                 var jsonData = Ext.decode(failureResponse.responseText);
                 iRely.Msg.close();
                 iRely.Functions.showErrorDialog(jsonData.message.statusText);
            }
        );
    },        

    beforeUOMStockUnitCheckChange:function(obj, rowIndex, checked, eOpts ){
        if (obj.dataIndex === 'ysnStockUnit'){
            var grid = obj.up('grid');
            var win = obj.up('window');
            var current = win.viewModel.data.current;

            if (checked === false && current.get('intPatronageCategoryId') > 0)
                {
                   iRely.Functions.showErrorDialog("Base Unit is required for Patronage Category.");
                   return false;
                }
        }
    },

    onUOMStockUnitCheckChange: function(checkbox, rowIndex, checked, eOpts ) {
        var me = this;
        var grid = checkbox.up('grid');
        if (!grid || !grid.view || !grid.store || !grid.store.data) return; 

        var win = checkbox.up('window');
        if (!win || !win.viewModel || !win.viewModel.storeInfo) return; 

        // var row = checkbox.getView().getRow(rowIndex),
        //     record = checkbox.getView().getRecord(row),
        //     realRowIndex = checkbox.getView().ownerCt.getStore().indexOf(record);
        //var current = grid.view.getRecord(realRowIndex);

        var current = grid.view.getRecord(rowIndex);        
        current = current ? current : null; 

        var uomConversion = win.viewModel.storeInfo.uomConversion;
        uomConversion = uomConversion ? uomConversion : null; 

        var uoms = grid.store.data.items;
        uoms = uoms ? uoms : null; 

        if (checkbox.dataIndex === 'ysnStockUnit'){
            Inventory.Utils.ajax({
                url: './Inventory/api/Item/CheckStockUnit',
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
                         var result = function (button) {
                            if (button === 'yes') {                                
                                Inventory.Utils.ajax({
                                    url: './Inventory/api/Item/ConvertItemToNewStockUnit',
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
                                                grid.store.load({
                                                    callback: function (records, options, success) {
                                                        if (success){
                                                            var context = me.view.context;
                                                            var vm = me.getViewModel();
                                                            vm.data.current.dirty = false;
                                                            context.screenMgr.toolbarMgr.provideFeedBack(iRely.Msg.SAVED);    
                                                        }
                                                    }   
                                                });
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
                            iRely.Functions.showErrorDialog("Item has already a transaction so Base Unit is required.");
                            current.set('ysnStockUnit', true);
                        }
                        else
                        {
                            var msgBox = iRely.Functions;
                            msgBox.showCustomDialog(
                                msgBox.dialogType.WARNING,
                                msgBox.dialogButtonType.YESNO,
                                "Item has transaction/s so changing the base unit will convert the following to new stock unit:<br> <br>Existing Stock <br>Cost & Prices <br> Existing Entries in Inventory Transaction Tables<br><br><br>Conversion to new stock unit will be automatically saved. <br><br>Do you want to continue?",
                                result
                            );
                        }
                    }

                    else
                    {
                        if (current){
                            current.set('dblUnitQty', 1);
                            current.set('ysnStockUnit', true);  

                            if (checked === true){
                                var uoms = grid.store.data.items;

                                if (uoms) {
                                    uoms.forEach(function(uom){                                        
                                        if (uom !== current){
                                            uom.set('ysnStockUnit', false);
                                            var unitMeasureId = current.get('intUnitMeasureId');

                                            me.getConversionValue(
                                                unitMeasureId, 
                                                uom.get('intUnitMeasureId'), // Converstion to the new stock uom. 
                                                function (value) {
                                                    uom.set('dblUnitQty', value);
                                                }
                                            );
                                        }                                        
                                    });
                                }
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

        else if (checkbox.dataIndex === 'ysnStockUOM'){
            if (checked === true && uoms) {
                uoms.forEach(function (uom) {
                    if (uom !== current) {
                        uom.set('ysnStockUOM', false);
                    }
                });
            }            
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
        var current = win.viewModel.data.current;
        var intCommodityId = current ? current.get('intCommodityId') : null;

        if (intCommodityId) {
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
            // win.context.data.saveRecord({ successFn: function(batch, eOpts){
            //     me.openItemLocationScreen('edit', win, record);
            //     return;
            // } });

            me.saveRecord(
                win, 
                function(batch, eOpts){
                    me.openItemLocationScreen('edit', win, record);
                    return;
                }            
            );

        }
        else {
            win.context.data.validator.validateRecord(win.context.data.configuration, function(valid) {
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
            // win.context.data.saveRecord({ successFn: function(batch, eOpts){
            //     me.openItemLocationScreen('new', win);
            //     return;
            // } });

            me.saveRecord(
                win, 
                function(batch, eOpts){
                    me.openItemLocationScreen('new', win);
                    return;
                }            
            );

        }
        else {
            win.context.data.validator.validateRecord(win.context.data.configuration, function(valid) {
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
            iRely.Functions.openScreen('GlobalComponentEngine.view.FloatingSearch',{
                searchSettings: {
                    type: 'Inventory.view.Item',
                    url: './i21/api/companylocation/search',
                    title: 'Add Item Locations',
                    controller: me,
                    scope: me,
                    showNew: false,
                    openButtonText: 'Add',
                    columns: [
                            { dataIndex : 'intCompanyLocationId', text: 'Location Id', dataType: 'numeric', defaultSort : true, hidden : true, key : true},
                            { dataIndex : 'strLocationName',text: 'Location Name', dataType: 'string', flex: 1 },
                            { dataIndex : 'strLocationType',text: 'Location Type', dataType: 'string', flex: 1 }
                    ],
                    buttons: [
                        {
                            text: 'Select All',
                            iconCls: 'select-all',
                            customControlPosition: 'start',
                            clickHandler: 'onSelectAllClick'
                        },
                        {
                            text: 'Unselect All',
                            customControlPosition: 'start',
                            clickHandler: 'onUnselectAllClick'
                        }
                    ]
                },
                viewConfig: {
                    listeners: {
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
                        }
                    }
                }
            });
        };

        me.saveRecord(
            win, 
            function(batch, eOpts){
                // After save
            },
            function(valid, message) {
                if(valid) {
                    showAddScreen();
                }
            }
        );        
    },

    onSelectAllClick: function(button, e) {
        var grid = button.up('grid');
        var range = grid.getStore().getCount();
        grid.getSelectionModel().selectRange(0, range);
    },

    onUnselectAllClick: function(button, e) {
        var grid = button.up('grid');
        grid.getSelectionModel().deselectAll();
    },

    beforeSave: function(win){
        if (!win) return; 
        var current = win.viewModel.data.current;

        var stockUnitExist = true; 
        if(current){                        
            if (current.tblICItemUOMs()) {
                if (
                    current.get('strType') != 'Other Charge'
                    && current.get('strType') != 'Non-Inventory'
                    && current.get('strType') != 'Service'
                    && current.get('strType') != 'Software'
                    && current.get('strType') != 'Comment'
                )
                {
                    Ext.Array.each(current.tblICItemUOMs().data.items, function (itemStock) {                    
                        if (!itemStock.dummy) {
                            stockUnitExist = false;
                            if(itemStock.get('ysnStockUnit')){
                                stockUnitExist = true;
                                return false; 
                            }                            
                        }
                    });
                    if (stockUnitExist == false){
                        iRely.Functions.showErrorDialog("Unit of Measure setup needs to have a Stock Unit.");
                        return false;
                    }            
                }                
            }        
        }
    },

    // Comment this code because it causing the Status indicator to show as "Ready". It should show as "Saved". See IC-4436. 
    // afterSave: function(me, win, batch, options) {
    //     win.context.data.reload();
    // },

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
            // win.context.data.saveRecord({ successFn: function(batch, eOpts){
            //     me.openItemLocationScreen('edit', win, selection[0]);
            // } });
            me.saveRecord(
                win, 
                function(batch, eOpts){
                    me.openItemLocationScreen('edit', win, selection[0]);
                }            
            );               
        }
        else {
            win.context.data.validator.validateRecord(win.context.data.configuration, function(valid) {
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
        var stockUOM = _.findWhere(current.tblICItemUOMs().data.items, function(x){ return x.get(ysnStockUnit) && !x.dummy});
        if(!win.defaultUOM && stockUOM)
            stockUOM = {
                intItemUOMId: stockUOM.get('intItemUOMId')
            };

        if (action === 'edit'){
            iRely.Functions.openScreen(screenName, {
                viewConfig: {
                    listeners: {
                        close: function() {
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
                                        me.getViewModel().data.current.tblICItemPricings().load({
                                            callback: function() {
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
                        close: function() {
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
                defaultUOM: win.defaultUOM ? win.defaultUOM : stockUOM,
                action: action
            });
        }
    },

    onCopyLocationSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var me = this; 
        var win = combo.up('window');
        var grid = combo.up('grid');
        var selection = grid.getSelectionModel().getSelection();
        var current = win.viewModel.data.current;
        var filters = [{
            column: 'intItemLocationId',
            value: records[0].get('intItemLocationId'),
            condition: 'eq',
            conjunction: 'And'
        }];

        Inventory.Utils.ajax({
                timeout: 120000,
                url: './Inventory/api/ItemLocation/Search',
                params: {
                    filter: iRely.Functions.encodeFilters(filters)
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

                    //win.context.data.saveRecord();
                    me.saveRecord(win);                      
				},
				function (failureResponse) {
                    var jsonData = Ext.decode(failureResponse.responseText);
                    iRely.Functions.showErrorDialog(jsonData.ExceptionMessage);
				}
        );
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
        var lastCost = price.lastCost;
        var avgCost = price.avgCost;
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
            case 'Markup Last Cost':
                var markup = (lastCost * (amt / 100));
                unitPrice = (lastCost + markup);
                retailPrice = unitPrice * qty;
                break;
            case 'Markup Avg Cost':
                var markup = (avgCost * (amt / 100));
                unitPrice = (avgCost + markup);
                retailPrice = unitPrice * qty;
                break;
            default:
                retailPrice = 0;
                break;
        }
        //return retailPrice;
        return Inventory.Utils.Math.round(retailPrice, 6);
    },

    /* TODO:Create unit test for getSalePrice */
    getSalePrice: function (price, errorCallback) {
        var salePrice = 0;
        switch (price.pricingMethod) {
            case "None":
                salePrice = 0.00;
                break;
            case "Fixed Dollar Amount":
                salePrice = price.standardCost + price.amount;
                break;
            case "Markup Standard Cost":
                salePrice = (price.standardCost * (price.amount / 100)) + price.standardCost;
                break;
            case "Percent of Margin":
                salePrice = price.amount < 100 ? (price.standardCost / (1 - (price.amount / 100))) : errorCallback();
                break;
            case "Markup Last Cost":
                salePrice = (price.lastCost * (price.amount / 100)) + price.lastCost;
                break;
            case "Markup Avg Cost":
                salePrice = (price.avgCost * (price.amount / 100)) + price.avgCost;
                break;
            }
        //return salePrice;
        return Inventory.Utils.Math.round(salePrice, 6);
    },

    updatePricing: function (pricing, data, validationCallback) {
        var me = this;
        var salePrice = me.getSalePrice({
            standardCost: data.standardCost,
            lastCost: data.lastCost,
            avgCost: data.avgCost,
            amount: data.amount,
            pricingMethod: data.pricingMethod
        }, validationCallback);

        if (!(iRely.Functions.isEmpty(data.pricingMethod) || data.pricingMethod === 'None')) {
            pricing.set('dblSalePrice', salePrice);
        }
    },

    updatePricingLevel: function (item, pricing, data) {
        var me = this;
        _.each(item.tblICItemPricingLevels().data.items, function (p) {
            if (p.data.intItemLocationId === pricing.data.intItemLocationId 
                && p.data.intCurrencyId === i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId')
            ) {
                var retailPrice = me.getPricingLevelUnitPrice({
                    pricingMethod: p.data.strPricingMethod,
                    salePrice: data.unitPrice,
                    msrpPrice: data.msrpPrice,
                    standardCost: data.standardCost,
                    lastCost: data.lastCost,
                    avgCost: data.avgCost,
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
            lastCost: currentPricing.data.dblLastCost,
            avgCost: currentPricing.data.dblAverageCost,
            pricingMethod: currentPricing.data.strPricingMethod,
            amount: currentPricing.data.dblAmountPercent
        };
        this.updatePricing(currentPricing, data, function () {
            win.context.data.validator.validateGrid(grdPricing);
        });
        this.updatePricingLevel(currentItem, currentPricing, data);
    },

    onPricingLastCostChange: function (e, newValue, oldValue) {
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
            standardCost: currentPricing.data.dblStandardCost,
            lastCost: newValue,
            avgCost: currentPricing.data.dblAverageCost,
            pricingMethod: currentPricing.data.strPricingMethod,
            amount: currentPricing.data.dblAmountPercent
        };
        this.updatePricing(currentPricing, data, function () {
            win.context.data.validator.validateGrid(grdPricing);
        });
        this.updatePricingLevel(currentItem, currentPricing, data);
    },

    onPricingAverageCostChange: function (e, newValue, oldValue) {
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
            standardCost: currentPricing.data.dblStandardCost,
            lastCost: currentPricing.data.dblLastcost,
            avgCost: newValue,
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
                            var lastCost = selectedLoc.get('dblLastCost');
                            var avgCost = selectedLoc.get('dblAverageCost');
                            var qty = context.record.get('dblUnit');
                            var retailPrice = me.getPricingLevelUnitPrice({
                                pricingMethod: pricingMethod,
                                salePrice: unitPrice,
                                msrpPrice: msrpPrice,
                                standardCost: standardCost,
                                lastCost: lastCost,
                                avgCost: avgCost,
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
                var standardCost = context.record.get('dblStandardCost');
                var lastCost = context.record.get('dblLastCost');
                var avgCost = context.record.get('dblAverageCost');

                if (context.field === 'strPricingMethod') {
                    pricingMethod = context.value;
                }
                else if (context.field === 'dblAmountPercent') {
                    amount = context.value;
                }
                else if (context.field === 'dblStandardCost') {
                    standardCost = context.value;
                }

                var data = {
                    standardCost: standardCost,
                    lastCost: lastCost,
                    avgCost: avgCost,
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
            Inventory.Utils.ajax({
                timeout: 120000,
                url: './Inventory/api/Item/DuplicateItem',
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
            //     url: './Inventory/api/Item/DuplicateItem?ItemId=' + current.get('intItemId'),
            //     method: 'GET',
            //     success: function(response){
            //         var jsonData = Ext.decode(response.responseText);
            //         context.configuration.store.addFilter([{ column: 'intItemId', value: jsonData.id }]);
            //         context.configuration.paging.moveFirst();
            //     }
            // });
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
                                        ysnStockUOM: uom.ysnStockUOM, 
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

    

    //</editor-fold>

    //<editor-fold desc="Combo Box Drilldown Events">

    onManufacturerDrilldown: function(combo) {
        iRely.Functions.openScreen('Inventory.view.Manufacturer', {viewConfig: { modal: true }});
    },

    onBrandDrilldown: function(combo) {
        iRely.Functions.openScreen('Inventory.view.Brand', {viewConfig: { modal: true }});
    },

    onCommodityDrilldown: function(combo) {
        if (!combo) return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;
        var commodityId = current ? current.get('intCommodityId') : null; 

        if (!commodityId) {
            iRely.Functions.openScreen('Inventory.view.Commodity', { action: 'new', viewConfig: { modal: true }});
        }
        else {
            iRely.Functions.openScreen('Inventory.view.Commodity', commodityId);
        }
    },

    onCategoryDrilldown: function(combo) {
        if (!combo) return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;
        var categoryId = current ? current.get('intCategoryId') : null; 

        if (!categoryId) {
            iRely.Functions.openScreen('Inventory.view.Category', { action: 'new', viewConfig: { modal: true }});
        }
        else {
            iRely.Functions.openScreen('Inventory.view.Category', categoryId);
        }
    },

    onMedicationTagDrilldown: function(combo) {
        this.showInventoryTag('intMedicationTag', "Medication Tag");
    },

    onIngredientTagDrilldown: function(combo) {
        this.showInventoryTag('intIngredientTag', "Ingredient Tag");
    },

    onHazmatMessageTagDrilldown: function(combo) {
        this.showInventoryTag('intHazmatTag', "Hazmat Message");
    },

    showInventoryTag: function(fieldName, type) {
        var id = this.getViewModel().get('current.' + fieldName);
        if(iRely.Functions.isEmpty(id))
            iRely.Functions.openScreen('Inventory.view.InventoryTag', { action: 'new', filters: [{ strType: type }], viewConfig: { modal: true }});
        else
            iRely.Functions.openScreen('Inventory.view.InventoryTag', id);
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

    onUPCShortKeyDown: function(txtfield, e, eOpts){
        if(e.keyCode >= 65 && e.keyCode <= 90){
            e.preventDefault();
            return;
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

            if (vm.data.current.dirty === true) {
                win.context.data.saveRecord({ successFn: function(batch, eOpts){
                    me.openItemLocationScreen('edit', win, record);
                    return;
                } });

                // me.saveRecord(
                //     win, 
                //     function(batch, eOpts){
                //         me.openItemLocationScreen('edit', win, record);
                //     }
                // );                
            }
            else {
                win.context.data.validator.validateRecord(win.context.data.configuration, function(valid) {
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

        var record = records[0];
        var win = combo.up('window');
        var grid = combo.up('grid');
        var grdOwner = win.down('#grdOwner');
        var plugin = grid.getPlugin('cepOwner');
        var current = plugin.getActiveRecord();

        if (combo.itemId === 'cboOwner' && record){
            current.set('strName', record.get('strName'));
            current.set('intOwnerId', record.get('intEntityId'));
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

    onCostUOMSelect: function(combo, records) {
        if (!combo || !records || records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current){
            current.set('intCostUOMId', records[0].get('intItemUOMId'));
        }
    },    

    onStatusSelect: function(combo, records, eOpts) {
        var win = combo.up('window');
        var viewModel = win.getViewModel();
        var status = viewModel.get('current').get('strStatus');

        if(status === 'Discontinued') {
            var grid = win.down("#grdContractItem");
            Ext.each(grid.store.data.items, function(record) {
                record.set('strStatus', 'Discontinued');
            });
        }
    },

    onIsBasketChange: function(checkbox, newValue, oldValue) {
        if(newValue === oldValue) return;

        var win = checkbox.up('window');
        var viewModel = win.getViewModel();   
        var current = viewModel.get('current');
        
        if(current && newValue === false && current.get('strType') == 'Bundle') {
            var uoms = current.tblICItemUOMs();
            if (uoms) {
                Ext.Array.each(uoms.data.items, function (uom) {
                    if (!uom.dummy) {
                        uom.set('ysnAllowPurchase', false);    
                    }
                });
            }     
        }

        if(current) {
            if(!newValue) {
                current.set('intCommodityId', null);
                current.set('strCommodityCode', null);
			}
		}
	},
	
    onAllowPurchaseChange: function(column, index, newValue, record) {
        if(!newValue) {
            var current = this.getViewModel().get('current');
            var locs = _.filter(current.tblICItemLocations().data.items, function(x) { return x.get('intReceiveUOMId') === record.get('intItemUOMId');});
            if(locs && locs.length > 0) {
                iRely.Functions.showErrorDialog('You cannot uncheck "Allow Purchase" because this UOM is being used as a default Purchase UOM in the item location "'.concat(locs[0].get('strLocationName')).concat('".'));
                return false;
            }
        }
    },

    onAllowSaleChange: function(column, index, newValue, record) {
        if(!newValue) {
            var current = this.getViewModel().get('current');
            var locs = _.filter(current.tblICItemLocations().data.items, function(x) { return x.get('intIssueUOMId') === record.get('intItemUOMId');});
            if(locs && locs.length > 0) {
                iRely.Functions.showErrorDialog('You cannot uncheck "Allow Sale" because this UOM is being used as a default Sale UOM in the item location "'.concat(locs[0].get('strLocationName')).concat('".'));
                return false;
            }
        }
    },

    onManufacturingUOMSelect: function(combo, records, eOpts) {
        if (!combo && !records && records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win ? win.viewModel.data.current : null;

        if (!current)
            return; 
        
        if (combo.itemId === 'cboDimensionUOM'){
            current.set('intDimensionUOMId', records[0].get('intUnitMeasureId'));
            current.set('strDimensionUOM', records[0].get('strUnitMeasure'));
        }
        else if (combo.itemId === 'cboWeightUOM') {
            current.set('intWeightUOMId', records[0].get('intUnitMeasureId'));
            current.set('strWeightUOM', records[0].get('strUnitMeasure'));
        }
    },    

    onItemLicenseCodeSelect: function (combo, record) {
        "use strict";
        var me = this,
            win = me.getView(),
            grid = win.down('#grdItemLicense'),
            selectedRecord = record[0],
            current = grid.getSelectionModel().selected.items[0];

        current.set('strCodeDescription', selectedRecord.get('strDescription'));
    },

    onOwnerDefaultCheckChange: function(obj, rowIndex, checked, eOpts ) {
        var me = this;
        if (obj.dataIndex === 'ysnDefault'){
            var grid = obj.up('grid');
            var win = obj.up('window');
            var current = grid.view.getRecord(rowIndex);

            if (checked === true){
                var itemOwners = grid.store.data.items;
                if (itemOwners) {
                    itemOwners.forEach(function(itemOwner){
                        if (itemOwner !== current){
                            itemOwner.set('ysnDefault', false);
                        }
                    });
                }            
            }
        }
    },

    onAddOnItemHeaderClick: function (menu, column) {
        var grid = column.$initParent.grid;

        i21.ModuleMgr.Inventory.showScreenFromHeaderDrilldown('Inventory.view.Item', grid, 'intAddOnItemId');
    },

    onSubstituteItemHeaderClick: function (menu, column) {
        var grid = column.$initParent.grid;

        i21.ModuleMgr.Inventory.showScreenFromHeaderDrilldown('Inventory.view.Item', grid, 'intSubstituteItemId');
    },

    onAddOnSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepAddOn');
        var current = plugin.getActiveRecord();
        
        if (combo.column.itemId === 'colAddOnItem'){
            current.set('strDescription', records[0].get('strDescription'));
            current.set('intAddOnItemId', records[0].get('intItemId'));
            current.set('strAddOnItemNo', records[0].get('strItemNo'));
            current.set('intItemUOMId', records[0].get('intCostUOMId'));
            current.set('strUnitMeasure', records[0].get('strCostUOM'));
        }

        else if (combo.column.itemId === 'colAddOnUOM'){
            current.set('strUnitMeasure', records[0].get('strUnitMeasure'));
            current.set('intItemUOMId', records[0].get('intItemUOMId'));
        }

    },    

    onSubstituteSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepSubstitute');
        var current = plugin.getActiveRecord();
        
        if (combo.column.itemId === 'colSubstituteItem'){
            current.set('strDescription', records[0].get('strDescription'));
            current.set('intSubstituteItemId', records[0].get('intItemId'));
            current.set('strSubstituteItemNo', records[0].get('strItemNo'));
            current.set('intItemUOMId', records[0].get('intCostUOMId'));
            current.set('strUnitMeasure', records[0].get('strCostUOM'));
        }

        else if (combo.column.itemId === 'colSubstituteUOM'){
            current.set('strUnitMeasure', records[0].get('strUnitMeasure'));
            current.set('intItemUOMId', records[0].get('intItemUOMId'));
        }
    },

    onFactorySelect: function (combo, records, eOpts) {
        var me = this;

        if (records.length <= 0)
            return;

        var win = combo.up('window');
        if (!win) return; 

        var grid = combo.up('grid');
        if (!grid) return; 

        var plugin = grid.getPlugin('cepFactory');
        if (!plugin) return; 

        var current = plugin.getActiveRecord();
        if (!current) return; 

        var record = records[0];
        if (!record) return; 

        if (combo.itemId === 'cboFactory') {
            // Do not remove the manufacturing cells if it is the same factory name. 
            if (current.get('strLocationName') == record.get('strLocationName'))
                return; 

            if (current.tblICItemFactoryManufacturingCells()) {
                var mfgCells = current.tblICItemFactoryManufacturingCells().data.items; 
                for (var i = mfgCells.length - 1; i >= 0; i--){
                    if (!mfgCells[i].dummy){
                        current.tblICItemFactoryManufacturingCells().removeAt(i);
                    }
                }                
            }

        }
    },    

    onCostUnitQtyValueChange: function(newValue, oldValue, activeRecord, control, uomRecord) {
        var me = this;
        me.setData('costUnitQty', newValue);  
    },

    init: function(application) {
        this.control({
            "#uomCostUnitQty": {
                valuechange: this.onCostUnitQtyValueChange
            },
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
            "#colBaseUnit": {
                beforecheckchange: this.beforeUOMStockUnitCheckChange,
                checkchange: this.onUOMStockUnitCheckChange
            },
            // "#colStockUOM": {
            //     checkchange: this.onUOMStockUnitCheckChange
            // },            
            "#colOwnerDefault": {
                checkchange: this.onOwnerDefaultCheckChange
            },
            "#colCellNameDefault": {
                beforecheckchange: this.onManufacturingCellDefaultCheckChange
            },
            "#grdLocationStore": {
                itemdblclick: this.onLocationDoubleClick,
                cellclick: this.onLocationCellClick,
                //selectionchange: this.onLocationSelectionChange
            },
            "#colAllowPurchase": {
                beforecheckchange: this.onAllowPurchaseChange
            },
            "#colAllowSale": {
                beforecheckchange: this.onAllowSaleChange
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
            "#txtLastCost": {
                change: this.onPricingLastCostChange
            },            
            "#txtAverageCost": {
                change: this.onPricingAverageCostChange
            },            
            "#txtShortUPCCode": {
                specialKey: this.onUPCEnterTab,
                keydown: this.onUPCShortKeyDown
            },
            "#txtFullUPCCode": {
                specialKey: this.onUPCEnterTab
            },
            "#btnDuplicate": {
                click: this.onDuplicateClick
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
                drilldown: this.onMedicationTagDrilldown
            },
            "#cboIngredientTag": {
                drilldown: this.onIngredientTagDrilldown
            },
            "#cboHazmat": {
                drilldown: this.onHazmatMessageTagDrilldown
            },
            "#cboFuelCategory": {
                drilldown: this.onFuelCategoryDrilldown
            },
            "#cboItemLicenseCode": {
                select: this.onItemLicenseCodeSelect
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
            },
            // "#cboCostUOM": {
            //     select: this.onCostUOMSelect
            // },
            "#cboStatus": {
                select: this.onStatusSelect
            },
            "#chkIsBasket": {
                change: this.onIsBasketChange    
            },
            "#cboDimensionUOM": {
                select: this.onManufacturingUOMSelect
            },
            "#cboWeightUOM": {
                select: this.onManufacturingUOMSelect
            }, 
            "#cboAddOnItem": {
                select: this.onAddOnSelect
            },
            "#cboAddOnUOM": {
                select: this.onAddOnSelect
            },
            "#cboSubstituteItem": {
                select: this.onSubstituteSelect
            },
            "#cboBundleUOM": {
                select: this.onSubstituteSelect
            }, 
            "#cboFactory": {
                select: this.onFactorySelect
            }
        });

    }
});