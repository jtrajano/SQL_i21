﻿CREATE VIEW [dbo].[vyuCTCompanyPreference]
	
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
			,CP.ysnShowReportLangaugeSelection
			,CP.strDefaultAmendmentReport
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
			,CP.ysnAutoCreateDerivative
			,CP.ysnEnableItemContracts
			,CP.ysnDocumentByBookAndSubBook
			,CP.ysnAllocationMandatoryPurchase
			,CP.ysnAllocationMandatorySales
			,U1.strUnitMeasure		AS	strCleanCostUOM
			,C1.strCurrency			AS	strCleanCostCurrency
			,CS.strContractStatus	AS	strDefContractStatus
			,CT.strContainerType	AS	strDefContainerType
			,EY.strName				AS	strDefSalesperson
			,VI.strItemNo			AS	strVoucherItem
			,II.strItemNo			AS	strInvoiceItem
			,PC.strPriceCalculationType
			,SR.strScheduleDescription	AS	strDefStorageSchedule
			,CP.ysnMultiplePriceFixation AS ysnMultiplePriceFixation
	FROM	tblCTCompanyPreference		CP LEFT
	JOIN	tblICUnitMeasure			U1	ON	U1.intUnitMeasureId			=	CP.intCleanCostUOMId		LEFT
	JOIN	tblSMCurrency				C1	ON	C1.intCurrencyID			=	CP.intCleanCostCurrencyId	LEFT
	JOIN	tblCTContractStatus			CS	ON	CS.intContractStatusId		=	CP.intDefContractStatusId	LEFT
	JOIN	tblLGContainerType			CT	ON	CT.intContainerTypeId		=	CP.intDefContainerTypeId	LEFT
	JOIN	tblEMEntity					EY	ON	EY.intEntityId				=	CP.intDefSalespersonId		LEFT
	JOIN	tblICItem					VI	ON	VI.intItemId				=	CP.intVoucherItemId			LEFT
	JOIN	tblICItem					II	ON	II.intItemId				=	CP.intInvoiceItemId			LEFT
	JOIN	tblCTPriceCalculationType	PC	ON	PC.intPriceCalculationTypeId=	CP.intPriceCalculationTypeId	LEFT    
	JOIN	tblGRStorageScheduleRule	SR	ON	SR.intStorageScheduleRuleId	=	CP.intDefStorageSchedule

