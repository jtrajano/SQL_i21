﻿CREATE TABLE [dbo].[tblCTCompanyPreference]
(
	intCompanyPreferenceId INT NOT NULL IDENTITY, 
    ysnAssignSaleContract BIT NULL, 
    ysnAssignPurchaseContract BIT NULL,
	ysnRequireDPContract BIT NULL,
	ysnApplyScaleToBasis BIT NULL,
	intPriceCalculationTypeId INT NULL,
	intConcurrencyId INT NOT NULL DEFAULT 1,
	strLotCalculationType NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	ysnPartialPricing BIT,
	ysnPolarization BIT,
	strPricingQuantity NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intCleanCostCurrencyId INT NULL,
	intCleanCostUOMId INT NULL,
	strDefaultContractReport NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strDefaultContractReportFuture NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strDefaultReleaseReport NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	ysnShowReportLangaugeSelection BIT NULL,
	strDefaultAmendmentReport NVARCHAR(50) COLLATE Latin1_General_CI_AS,  
	strDefaultPricingConfirmation NVARCHAR(50) COLLATE Latin1_General_CI_AS,  
	ysnDemandViewForBlend BIT NOT NULL CONSTRAINT DF_tblCTCompanyPreference_ysnDemandViewForBlend DEFAULT 0,
	intEarlyDaysPurchase INT NULL,
	intEarlyDaysSales INT NULL,
	strDemandItemType NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	ysnBagMarkMandatory BIT NULL,
	strESA NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	ysnAutoCreateDP BIT,
	intDefSalespersonId	INT,
	dtmDefEndDate DATETIME,
	strSignature NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strDefPackingDescription NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intDefContractStatusId INT,
	ysnBasisComponentPurchase BIT NOT NULL DEFAULT(0),
	ysnBasisComponentSales BIT NOT NULL DEFAULT(0),
    strAmendmentFields NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	ysnOutGoingContractFeed BIT,
	ysnAlwaysMultiPrice BIT,
	ysnMultiPriceOnBasis BIT,
	intDefContainerTypeId INT,
	ysnFeedOnApproval BIT,
	ysnDisableEntity BIT,
	strDefEndDateType NVARCHAR(100)  COLLATE Latin1_General_CI_AS,
	ysnContractSlspnOnEmail BIT,
	strDefStartDateType NVARCHAR(100)  COLLATE Latin1_General_CI_AS,
	ysnAutoEvaluateMonth BIT,
	ysnAllowChangePricing BIT,
	ysnHideVendorWOAccNo BIT,
	ysnReadOnlyStatusOnCancel BIT,
	ysnBrokerage BIT,
	ysnDefaultBrokerage BIT,
	ysnEnablePriceContractApproval BIT,
	ysnAllowLocationChange BIT,
	ysnAllowOverSchedule BIT,
	intVoucherItemId	INT,
	intInvoiceItemId	INT,
	ysnEnableMultiProducer BIT,
	intDefStorageSchedule INT,
	ysnAmdWoAppvl         BIT,
	ysnLimitCTByLocation BIT,
	ysnAllowLoadBasedContract BIT,
	ysnRequireProducerQty BIT,
	ysnDisableContractSearchScreenCancelButton	BIT NULL DEFAULT 0,
	ysnAllowFutureTypeContractsPurchase	BIT NULL DEFAULT 0,
	ysnAllowFutureTypeContractsSales	BIT NULL DEFAULT 0,
	ysnAllowAutoShortCloseFutureTypeContracts BIT NULL DEFAULT 0,
	ysnEnableReleaseInstructionsTab	BIT NULL DEFAULT 0,
	ysnSendFeedOnPrice BIT,
	strBulkChangeFields NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	ysnSendFeedOnSlice BIT,
	ysnDisableLocationValidation BIT,
	ysnReduceScheduleByLogisticsLoad BIT,
	ysnUniqueEntityReference BIT,
	ysnAutoCreateDerivative BIT,
	ysnEnableItemContracts	BIT NULL DEFAULT 0,
	ysnAllowNonInventoryOnItemContracts	BIT NULL DEFAULT 0,
	ysnAllowBasisComponentToAccrue BIT NOT NULL DEFAULT 0,
	ysnUpdatedAvailabilityPurchase BIT NOT NULL DEFAULT 0,
	ysnUpdatedAvailabilitySales BIT NOT NULL DEFAULT 0,
	ysnDocumentByBookAndSubBook	BIT NOT NULL DEFAULT 0,
	ysnAllocationMandatoryPurchase	BIT NOT NULL DEFAULT 0,
	ysnAllocationMandatorySales	BIT NOT NULL DEFAULT 0,
	ysnMultiplePriceFixation	BIT NOT NULL DEFAULT 0,
	ysnContractBalanceInProgress BIT NOT NULL DEFAULT 0,
	ysnEnableFreightBasis BIT,
	intFreightBasisCostItemId INT,
	ysnCreateOtherCostPayable BIT NOT NULL DEFAULT 0,
	ysnAllowPartialHedgeLots BIT NOT NULL DEFAULT 0,
	ysnDefaultCommodityUOMtoStockHeader BIT NOT NULL DEFAULT 1,
	ysnForexRatePriceOptionalOnContract BIT NOT NULL DEFAULT 0,
	ysnAllowSignedWhenContractHasAmendment bit not null default 0,
	intQuantityDecimals INT NOT NULL DEFAULT 2,
	ysnAutoCompleteDPDeliveryDate bit not null default 0,
	intPricingDecimals INT NOT NULL DEFAULT 2,
	strContractApprovalIncrements NVARCHAR(150) COLLATE Latin1_General_CI_AS,
	ysnListAllCustomerVendorLocations bit not null default 0, -- CT-5315
	ysnAllowBasisSequencePriceChangeWhenPartiallyPriced bit null,
	ysnStayAsDraftContractUntilApproved bit not null default 0,
	ysnCalculatePlannedAvailabilityPurchase BIT NULL DEFAULT((0)),
	ysnCalculatePlannedAvailabilitySale BIT NULL DEFAULT((0)),
    CONSTRAINT [PK_tblCTCompanyPreference_intCompanyPreferenceId] PRIMARY KEY CLUSTERED ([intCompanyPreferenceId] ASC),
	CONSTRAINT [FK_tblCTCompanyPreference_tblSMCurrency_intCleanCostCurrencyId_intCurrencyId] FOREIGN KEY ([intCleanCostCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblCTCompanyPreference_tblICUnitMeasure_intCleanCostUOMId_intUnitMeasureId] FOREIGN KEY ([intCleanCostUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
	CONSTRAINT [FK_tblCTCompanyPreference_tblEMEntity_intDefSalespersonId_intEntityId] FOREIGN KEY (intDefSalespersonId) REFERENCES tblEMEntity(intEntityId),
	CONSTRAINT [FK_tblCTCompanyPreference_tblGRStorageScheduleRule_intDefStorageSchedule] FOREIGN KEY (intDefStorageSchedule) REFERENCES [tblGRStorageScheduleRule]([intStorageScheduleRuleId]),
	CONSTRAINT [FK_tblCTCompanyPreference_tblICItem_intItemId] FOREIGN KEY (intFreightBasisCostItemId) REFERENCES [tblICItem]([intItemId]),

)
