GO
DECLARE @entityId INT
SELECT TOP 1 @entityId = intEntityId FROM tblEMEntity

IF NOT EXISTS(SELECT 1 FROM  tblCTCompanyPreference)
BEGIN
INSERT INTO tblCTCompanyPreference (
 ysnAssignSaleContract
,ysnAssignPurchaseContract
,ysnRequireDPContract
,ysnApplyScaleToBasis
,intPriceCalculationTypeId
,intConcurrencyId
,strLotCalculationType
,ysnPartialPricing
,ysnPolarization
,strPricingQuantity
,intCleanCostCurrencyId
,intCleanCostUOMId
,strDefaultContractReport
,ysnShowReportLangaugeSelection
,strDefaultAmendmentReport
,strDefaultPricingConfirmation
,ysnDemandViewForBlend
,intEarlyDaysPurchase
,intEarlyDaysSales
,strDemandItemType
,ysnBagMarkMandatory
,strESA
,ysnAutoCreateDP
,intDefSalespersonId
,dtmDefEndDate
,strSignature
,strDefPackingDescription
,intDefContractStatusId
,ysnBasisComponentPurchase
,ysnBasisComponentSales
,strAmendmentFields
,ysnOutGoingContractFeed
,ysnAlwaysMultiPrice
,ysnMultiPriceOnBasis
,intDefContainerTypeId
,ysnFeedOnApproval
,ysnDisableEntity
,strDefEndDateType
,ysnContractSlspnOnEmail
,strDefStartDateType
,ysnAutoEvaluateMonth
,ysnAllowChangePricing
,ysnHideVendorWOAccNo
,ysnReadOnlyStatusOnCancel
,ysnBrokerage
,ysnDefaultBrokerage
,ysnEnablePriceContractApproval
,ysnAllowLocationChange
,ysnAllowOverSchedule
,intVoucherItemId
,intInvoiceItemId
,ysnEnableMultiProducer
,intDefStorageSchedule
,ysnAmdWoAppvl
,ysnLimitCTByLocation
,ysnAllowLoadBasedContract
,ysnRequireProducerQty
,ysnDisableContractSearchScreenCancelButton
,ysnSendFeedOnPrice
,strBulkChangeFields
,ysnSendFeedOnSlice
,ysnDisableLocationValidation
,ysnReduceScheduleByLogisticsLoad
,ysnUniqueEntityReference
,ysnAutoCreateDerivative
,ysnEnableItemContracts
,ysnAllowNonInventoryOnItemContracts
,ysnAllowBasisComponentToAccrue
,ysnUpdatedAvailabilityPurchase
,ysnUpdatedAvailabilitySales
,ysnDocumentByBookAndSubBook
,ysnAllocationMandatoryPurchase
,ysnAllocationMandatorySales
,ysnMultiplePriceFixation
,ysnContractBalanceInProgress
,ysnEnableFreightBasis
,intFreightBasisCostItemId
,ysnCreateOtherCostPayable
,ysnAllowPartialHedgeLots
,ysnDefaultCommodityUOMtoStockHeader
,ysnForexRatePriceOptionalOnContract
,ysnAllowSignedWhenContractHasAmendment
,intQuantityDecimals
,ysnAutoCompleteDPDeliveryDate
,intPricingDecimals
)
SELECT 
ysnAssignSaleContract = 0
,ysnAssignPurchaseContract = 0
,ysnRequireDPContract = 0
,ysnApplyScaleToBasis = 0
,intPriceCalculationTypeId = 1
,intConcurrencyId = 3
,strLotCalculationType = ''
,ysnPartialPricing = 0
,ysnPolarization = 0
,strPricingQuantity =  ''
,intCleanCostCurrencyId = NULL
,intCleanCostUOMId = NULL
,strDefaultContractReport = ''
,ysnShowReportLangaugeSelection = 0
,strDefaultAmendmentReport = ''
,strDefaultPricingConfirmation = ''
,ysnDemandViewForBlend = 0
,intEarlyDaysPurchase = NULL
,intEarlyDaysSales = NULL
,strDemandItemType = ''
,ysnBagMarkMandatory = NULL
,strESA = ''
,ysnAutoCreateDP = 0
,intDefSalespersonId = NULL
,dtmDefEndDate = NULL
,strSignature = ''
,strDefPackingDescription = ''
,intDefContractStatusId = NULL
,ysnBasisComponentPurchase = 0
,ysnBasisComponentSales = 0
,strAmendmentFields = ''
,ysnOutGoingContractFeed = NULL
,ysnAlwaysMultiPrice = 0
,ysnMultiPriceOnBasis = NULL
,intDefContainerTypeId = NULL
,ysnFeedOnApproval = 0
,ysnDisableEntity = 0
,strDefEndDateType = 0
,ysnContractSlspnOnEmail = 0
,strDefStartDateType = 'Contract Date'
,ysnAutoEvaluateMonth = 0
,ysnAllowChangePricing = 0
,ysnHideVendorWOAccNo = NULL
,ysnReadOnlyStatusOnCancel = 0
,ysnBrokerage = 0
,ysnDefaultBrokerage = 0
,ysnEnablePriceContractApproval = 0
,ysnAllowLocationChange = 0
,ysnAllowOverSchedule = 0
,intVoucherItemId = NULL
,intInvoiceItemId = NULL
,ysnEnableMultiProducer = NULL
,intDefStorageSchedule = NULL
,ysnAmdWoAppvl = 0
,ysnLimitCTByLocation = 0
,ysnAllowLoadBasedContract = 0
,ysnRequireProducerQty = 0
,ysnDisableContractSearchScreenCancelButton = 0
,ysnSendFeedOnPrice = 0
,strBulkChangeFields = ''
,ysnSendFeedOnSlice = 0
,ysnDisableLocationValidation = 0
,ysnReduceScheduleByLogisticsLoad = 0
,ysnUniqueEntityReference = 0
,ysnAutoCreateDerivative = 0
,ysnEnableItemContracts = 0
,ysnAllowNonInventoryOnItemContracts = 0
,ysnAllowBasisComponentToAccrue = 0
,ysnUpdatedAvailabilityPurchase = 0
,ysnUpdatedAvailabilitySales = 0
,ysnDocumentByBookAndSubBook = 0
,ysnAllocationMandatoryPurchase = 0
,ysnAllocationMandatorySales = 0
,ysnMultiplePriceFixation = 0
,ysnContractBalanceInProgress = 0
,ysnEnableFreightBasis = 0
,intFreightBasisCostItemId = NULL
,ysnCreateOtherCostPayable = 0
,ysnAllowPartialHedgeLots = 0
,ysnDefaultCommodityUOMtoStockHeader = 0
,ysnForexRatePriceOptionalOnContract = 0
,ysnAllowSignedWhenContractHasAmendment = 0
,intQuantityDecimals = 0
,ysnAutoCompleteDPDeliveryDate = 0
,intPricingDecimals = 0

--Audit Log          
		IF @entityId IS NOT NULL
		BEGIN
			EXEC dbo.uspSMAuditLog 
						 @keyValue			= 1									-- Primary Key Value of the Invoice. 
						,@screenName		= 'ContractManagement.view.CompanyPreferenceOption'	-- Screen Namespace
						,@entityId			= @entityId									-- Entity Id.
						,@actionType		= 'Added'							-- Action Type
						,@changeDescription	= 'Contract Config Company Preference Default Data'			-- Description
						,@fromValue			= '0'								-- Previous Value
						,@toValue			= '1'								-- New Value
		END
END
GO