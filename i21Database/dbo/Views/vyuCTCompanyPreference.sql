CREATE VIEW [dbo].[vyuCTCompanyPreference]
	
AS 

	SELECT	CP.intCompanyPreferenceId
			,CP.ysnAssignSaleContract
			,CP.ysnAssignPurchaseContract
			,CP.ysnRequireDPContract
			,CP.ysnApplyScaleToBasis
			,CP.intPriceCalculationTypeId
			,CP.intConcurrencyId
			,CP.strLotCalculationType
			,CP.ysnPartialPricing
			,CP.ysnPolarization
			,CP.strPricingQuantity
			,CP.intCleanCostCurrencyId
			,CP.intCleanCostUOMId
			,CP.strDefaultContractReport
			,CP.strDefaultContractReportFuture
			,CP.ysnShowReportLangaugeSelection
			,CP.strDefaultAmendmentReport
			,CP.strDefaultPricingConfirmation
			,CP.ysnDemandViewForBlend
			,CP.intEarlyDaysPurchase
			,CP.intEarlyDaysSales
			,CP.strDemandItemType
			,CP.ysnBagMarkMandatory
			,CP.strESA
			,CP.ysnAutoCreateDP
			,CP.intDefSalespersonId
			,CP.dtmDefEndDate
			,CP.strSignature
			,CP.strDefPackingDescription
			,CP.intDefContractStatusId
			,CP.ysnBasisComponentPurchase
			,CP.ysnBasisComponentSales
			,CP.strAmendmentFields
			,CP.ysnOutGoingContractFeed
			,CP.ysnAlwaysMultiPrice
			,CP.ysnMultiPriceOnBasis
			,CP.intDefContainerTypeId
			,CP.ysnFeedOnApproval
			,CP.ysnDisableEntity
			,CP.strDefEndDateType
			,CP.ysnContractSlspnOnEmail
			,CP.strDefStartDateType
			,CP.ysnAutoEvaluateMonth
			,CP.ysnAllowChangePricing
			,CP.ysnHideVendorWOAccNo
			,CP.ysnReadOnlyStatusOnCancel
			,CP.ysnBrokerage
			,CP.ysnDefaultBrokerage
			,CP.ysnEnablePriceContractApproval
			,CP.ysnAllowLocationChange
			,CP.ysnAllowOverSchedule
			,CP.intVoucherItemId
			,CP.intInvoiceItemId
			,CP.ysnEnableMultiProducer
			,CP.intDefStorageSchedule
			,CP.ysnAmdWoAppvl
			,CP.ysnLimitCTByLocation
			,CP.ysnAllowLoadBasedContract
			,CP.ysnRequireProducerQty
			,CP.ysnDisableContractSearchScreenCancelButton
			,CP.ysnSendFeedOnPrice
			,CP.strBulkChangeFields
			,CP.ysnSendFeedOnSlice
			,CP.ysnDisableLocationValidation
			,CP.ysnReduceScheduleByLogisticsLoad
			,CP.ysnUniqueEntityReference
			,CP.ysnAllowBasisComponentToAccrue
			,CP.ysnAutoCreateDerivative
			,CP.ysnEnableItemContracts
   			,CP.ysnAllowNonInventoryOnItemContracts  
			,CP.ysnDocumentByBookAndSubBook
			,CP.ysnUpdatedAvailabilityPurchase
			,CP.ysnUpdatedAvailabilitySales
			,CP.ysnAllowFutureTypeContractsPurchase
			,CP.ysnAllowFutureTypeContractsSales
			,CP.ysnAllowAutoShortCloseFutureTypeContracts
			,CP.strDefaultReleaseReport
			,CP.ysnEnableReleaseInstructionsTab
			,strCleanCostUOM = U1.strUnitMeasure
			,strCleanCostCurrency = C1.strCurrency
			,strDefContractStatus = CS.strContractStatus
			,strDefContainerType = CT.strContainerType
			,strDefSalesperson = EY.strName
			,strVoucherItem = VI.strItemNo
			,strInvoiceItem = II.strItemNo
			,CP.ysnAllocationMandatoryPurchase
			,CP.ysnAllocationMandatorySales
			,PC.strPriceCalculationType
			,strDefStorageSchedule = SR.strScheduleDescription
			,ysnMultiplePriceFixation = CP.ysnMultiplePriceFixation
			,CP.ysnEnableFreightBasis
			,CP.intFreightBasisCostItemId
			,strFreightBasisCostItem = FB.strItemNo
			,CP.ysnCreateOtherCostPayable
			,CP.ysnAllowPartialHedgeLots
			,CP.ysnDefaultCommodityUOMtoStockHeader
			,CP.ysnForexRatePriceOptionalOnContract
			,CP.ysnAllowSignedWhenContractHasAmendment
			,CP.intQuantityDecimals
			,CP.ysnAutoCompleteDPDeliveryDate
			,CP.intPricingDecimals
			,CP.strContractApprovalIncrements
			,CP.ysnListAllCustomerVendorLocations -- CT-5315
			,CP.ysnAllowBasisSequencePriceChangeWhenPartiallyPriced
			,CP.ysnStayAsDraftContractUntilApproved
			,CP.ysnCalculatePlannedAvailabilityPurchase
			,CP.ysnCalculatePlannedAvailabilitySale
			,CP.ysnPricingAsAmendment
			,CP.ysnEnableHTAMultiplePricing
			,CP.ysnAllowHeaderSaveWithNoSequence
			,CP.ysnCompanyLocationInContractHeader
			,CP.ysnCalculateQualityPremium
			,CP.ysnOptionalityPremiumDiscount
			,CP.ysnDefaultShipperCargillFrontingDetails			
			,CP.ysnFreightTermCost
			,CP.ysnAutoCalculateFreightTermCost
			,CP.intDefaultFreightId
			,strFreightItem = FI.strItemNo
			,CP.intDefaultInsuranceId
			,strInsuranceItem = II.strItemNo
			,CP.intDefaultTHCId
			,strTHCItem = THC.strItemNo
			,CP.intDefaultStorageId
			,strStorageItem = SI.strItemNo
	FROM	tblCTCompanyPreference		CP
	LEFT JOIN	tblICUnitMeasure			U1	ON	U1.intUnitMeasureId			=	CP.intCleanCostUOMId
	LEFT JOIN	tblSMCurrency				C1	ON	C1.intCurrencyID			=	CP.intCleanCostCurrencyId
	LEFT JOIN	tblCTContractStatus			CS	ON	CS.intContractStatusId		=	CP.intDefContractStatusId
	LEFT JOIN	tblLGContainerType			CT	ON	CT.intContainerTypeId		=	CP.intDefContainerTypeId
	LEFT JOIN	tblEMEntity					EY	ON	EY.intEntityId				=	CP.intDefSalespersonId
	LEFT JOIN	tblICItem					VI	ON	VI.intItemId				=	CP.intVoucherItemId
	LEFT JOIN	tblICItem					II	ON	II.intItemId				=	CP.intInvoiceItemId
	LEFT JOIN	tblCTPriceCalculationType	PC	ON	PC.intPriceCalculationTypeId=	CP.intPriceCalculationTypeId
	LEFT JOIN	tblGRStorageScheduleRule	SR	ON	SR.intStorageScheduleRuleId	=	CP.intDefStorageSchedule
	LEFT JOIN	tblICItem					FB	ON	FB.intItemId				=	CP.intFreightBasisCostItemId
	LEFT JOIN	tblICItem					FI	ON	FI.intItemId				=	CP.intDefaultFreightId
	LEFT JOIN	tblICItem					INS	ON	INS.intItemId				=	CP.intDefaultInsuranceId
	LEFT JOIN	tblICItem					THC	ON	THC.intItemId				=	CP.intDefaultTHCId
	LEFT JOIN	tblICItem					SI	ON	SI.intItemId				=	CP.intDefaultStorageId
