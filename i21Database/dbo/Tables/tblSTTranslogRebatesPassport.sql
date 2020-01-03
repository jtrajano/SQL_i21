CREATE TABLE  [dbo].[tblSTTranslogRebatesPassport]
(
	[intTranslogId]									INT				NOT NULL IDENTITY,
	[intScanTransactionId]							INT				NULL,
	[strTrlUPCwithoutCheckDigit]					NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL,

	-- Header
	[strNAXMLPOSJournalVersion]						NVARCHAR(5)		COLLATE Latin1_General_CI_AS NULL,
	[intTransmissionHeaderStoreLocationID]			INT				NULL,
	[strTransmissionHeaderVendorName]				NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL,
	[strTransmissionHeaderVendorModelVersion]		NVARCHAR(20)	COLLATE Latin1_General_CI_AS NULL,
	[intReportSequenceNumber]						INT				NULL,
	[intPrimaryReportPeriod]						INT				NULL,
	[intSecondaryReportPeriod]						INT				NULL,
	[dtmBeginDate]									DATETIME		NULL,
	[dtmBeginTime]									DATETIME		NULL,
	[dtmEndDate]									DATETIME		NULL,
	[dtmEndTime]									DATETIME		NULL,

	-- Body
	-- SaleEvent
	[intEventSequenceID]							INT				NULL,
	[strTrainingModeFlagValue]						NVARCHAR(5)		COLLATE Latin1_General_CI_AS NULL,
	[intCashierID]									INT				NULL,
	[intRegisterID]									INT				NULL,
	[strTillID]										NVARCHAR(10)	COLLATE Latin1_General_CI_AS NULL,
	[strOutsideSalesFlagValue]						NVARCHAR(5)		COLLATE Latin1_General_CI_AS NULL,
	[intTransactionID]								INT				NULL,
	[dtmEventStartDate]								DATETIME		NULL,
	[dtmEventStartTime]								DATETIME		NULL,
	[dtmEventEndDate]								DATETIME		NULL,
	[dtmEventEndTime]								DATETIME		NULL,
	[dtmBusinessDate]								DATETIME		NULL,
	[dtmReceiptDate]								DATETIME		NULL,
	[dtmReceiptTime]								DATETIME		NULL,
	[strOfflineFlagValue]							NVARCHAR(5)		COLLATE Latin1_General_CI_AS NULL,
	[strSuspendFlagValue]							NVARCHAR(5)		COLLATE Latin1_General_CI_AS NULL,

	-- LinkedTransactionInfo
	[intOriginalStoreLocationID]					INT				NULL,
	[intOriginalRegisterID]							INT				NULL,
	[intOriginalTransactionID]						INT				NULL,
	[dtmOriginalEventStartDate]						DATETIME		NULL,
	[dtmOriginalEventStartTime]						DATETIME		NULL,
	[dtmOriginalEventEndDate]						DATETIME		NULL,
	[dtmOriginalEventEndTime]						DATETIME		NULL,
	[strTransactionLinkReason]						NVARCHAR(20)	COLLATE Latin1_General_CI_AS NULL,

	-- TransactionLine
	[strTransactionLineStatus]						NVARCHAR(20)	COLLATE Latin1_General_CI_AS NULL,

	-- ItemLine
	-- > ItemCode
	[strItemLineItemCodeFormat]						NVARCHAR(10)	COLLATE Latin1_General_CI_AS NULL,
	[strItemLinePOSCode]							NVARCHAR(20)	COLLATE Latin1_General_CI_AS NULL,
	[strItemLinePOSCodeModifier]					NVARCHAR(5)		COLLATE Latin1_General_CI_AS NULL,
	[strItemLinePOSCodeModifierName]				NVARCHAR(10)	COLLATE Latin1_General_CI_AS NULL,
	-- > ItemTax
	[intItemLineTaxLevelID]							INT				NULL,
	-- > FuelLine
	[strFuelGradeID]								NVARCHAR(10)	COLLATE Latin1_General_CI_AS NULL,
	[intFuelPositionID]								INT				NULL,
	[strPriceTierCode]								NVARCHAR(5)		COLLATE Latin1_General_CI_AS NULL,
	[intTimeTierCode]								INT				NULL,
	[strServiceLevelCode]							NVARCHAR(20)	COLLATE Latin1_General_CI_AS NULL,
	-- > TransactionTax
	[intTaxLevelID]									INT				NULL,
	[dblTaxableSalesAmount]							DECIMAL(18, 6)	NULL,
	[dblTaxCollectedAmount]							DECIMAL(18, 6)	NULL,
	[dblTaxableSalesRefundedAmount]					DECIMAL(18, 6)	NULL,
	[dblTaxRefundedAmount]							DECIMAL(18, 6)	NULL,
	[dblTaxExemptSalesAmount]						DECIMAL(18, 6)	NULL,
	[dblTaxExemptSalesRefundedAmount]				DECIMAL(18, 6)	NULL,
	[dblTaxForgivenSalesAmount]						DECIMAL(18, 6)	NULL,
	[dblTaxForgivenSalesRefundedAmount]				DECIMAL(18, 6)	NULL,
	[dblTaxForgivenAmount]							DECIMAL(18, 6)	NULL,
	-- > MerchandiseCodeLine
	[intMerchandiseCode]							INT				NULL,
	[strMerchandiseCodeLineDescription]				NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL,
	[dblActualSalesPrice]							DECIMAL(18, 6)	NULL,
	-- > Promotion
	[strPromotionID]								NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL,
	[strPromotionIDType]							NVARCHAR(20)	COLLATE Latin1_General_CI_AS NULL,
	[strPromotionReason]							NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL,
	[dblPromotionAmount]							DECIMAL(18, 6)	NULL,

	[strLineDescription]							NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL,
	[strLineEntryMethod]							NVARCHAR(20)	COLLATE Latin1_General_CI_AS NULL,
	[dblLineActualSalesPrice]						DECIMAL(18, 6)	NULL,
	[intLineMerchandiseCode]						INT				NULL,
	[intItemLineSellingUnits]						INT				NULL,
	[dblLineRegularSellPrice]						DECIMAL(18, 6)	NULL,
	[dblLineSalesQuantity]							DECIMAL(18, 6)	NULL,
	[dblLineSalesAmount]							DECIMAL(18, 6)	NULL,
	-- > SalesRestriction
	[strSalesRestrictFlagValue]						NVARCHAR(10)	COLLATE Latin1_General_CI_AS NULL,
	[strSalesRestrictFlagType]						NVARCHAR(10)	COLLATE Latin1_General_CI_AS NULL,

	-- TenderInfo
	[strTenderCode]									NVARCHAR(15)	COLLATE Latin1_General_CI_AS NULL,
	[strTenderSubCode]								NVARCHAR(15)	COLLATE Latin1_General_CI_AS NULL,
	[dblTenderAmount]								DECIMAL(18, 6)	NULL,
	[strChangeFlag]									NVARCHAR(10)	COLLATE Latin1_General_CI_AS NULL,
	-- > Authorization
	[strPreAuthorizationFlag]						NVARCHAR(20)	COLLATE Latin1_General_CI_AS NULL,
	[strRequestedAmount]							NVARCHAR(20)	COLLATE Latin1_General_CI_AS NULL,
	[strAuthorizationResponseCode]					NVARCHAR(20)	COLLATE Latin1_General_CI_AS NULL,
	[strAuthorizationResponseDescription]			NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL,
	[strApprovalReferenceCode]						NVARCHAR(20)	COLLATE Latin1_General_CI_AS NULL,
	[strReferenceNumber]							NVARCHAR(20)	COLLATE Latin1_General_CI_AS NULL,
	[strProviderID]									NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL,
	[dtmAuthorizationDate]							DATETIME		NULL,
	[dtmAuthorizationTime]							DATETIME		NULL,
	[strHostAuthorizedFlag]							NVARCHAR(20)	COLLATE Latin1_General_CI_AS NULL,
	[strAuthorizationApprovalDescription]			NVARCHAR(20)	COLLATE Latin1_General_CI_AS NULL,
	[strAuthorizingTerminalID]						NVARCHAR(20)	COLLATE Latin1_General_CI_AS NULL,
	[strForceOnLineFlag]							NVARCHAR(20)	COLLATE Latin1_General_CI_AS NULL,
	[strElectronicSignature]						NVARCHAR(20)	COLLATE Latin1_General_CI_AS NULL,
	[dblAuthorizedChargeAmount]						DECIMAL(18, 6)	NULL,

	-- TransactionSummary
	[dblTransactionTotalGrossAmount]				DECIMAL(18, 6)	NULL,
	[dblTransactionTotalNetAmount]					DECIMAL(18, 6)	NULL,
	[dblTransactionTotalTaxSalesAmount]				DECIMAL(18, 6)	NULL,
	[dblTransactionTotalTaxExemptAmount]			DECIMAL(18, 6)	NULL,
	[dblTransactionTotalTaxNetAmount]				DECIMAL(18, 6)	NULL,
	[dblTransactionTotalGrandAmount]				DECIMAL(18, 6)	NULL,
	[strTransactionTotalGrandAmountDirection]		NVARCHAR(20)	COLLATE Latin1_General_CI_AS NULL,

	[intStoreId]									INT				NOT NULL,
	[ysnSubmitted]									BIT				NOT NULL,
	[ysnPMMSubmitted]								BIT				NOT NULL DEFAULT ((0)),
	[ysnRJRSubmitted]								BIT				NOT NULL DEFAULT ((0)),
	[intConcurrencyId]								INT				NOT NULL,

	CONSTRAINT [PK_tblSTTranslogRebatesPassport] PRIMARY KEY ([intTranslogId]),
)
GO

CREATE NONCLUSTERED INDEX [IDX_tblSTTranslogRebatesPassport]
		ON [dbo].[tblSTTranslogRebatesPassport]([intTransactionID] ASC, [strTillID] ASC, [intCashierID] ASC, [intRegisterID] ASC, [intStoreId] ASC);