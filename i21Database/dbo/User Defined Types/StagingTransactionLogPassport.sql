CREATE TYPE StagingTransactionLogPassport AS TABLE
(
	[intRowCount]									INT				NOT NULL,
	
	-- Header
	[strNAXMLPOSJournalVersion]						NVARCHAR(40)	NULL,
	[intTransmissionHeaderStoreLocationID]			INT				NULL,
	[strTransmissionHeaderVendorName]				NVARCHAR(200)	NULL,
	[strTransmissionHeaderVendorModelVersion]		NVARCHAR(40)	NULL,
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
	[strTrainingModeFlagValue]						NVARCHAR(40)		NULL,
	[intCashierID]									INT				NULL,
	[intRegisterID]									INT				NULL,
	[strTillID]										NVARCHAR(40)	NULL,
	[strOutsideSalesFlagValue]						NVARCHAR(40)		NULL,
	[intTransactionID]								INT				NULL,
	[dtmEventStartDate]								DATETIME		NULL,
	[dtmEventStartTime]								DATETIME		NULL,
	[dtmEventEndDate]								DATETIME		NULL,
	[dtmEventEndTime]								DATETIME		NULL,
	[dtmBusinessDate]								DATETIME		NULL,
	[dtmReceiptDate]								DATETIME		NULL,
	[dtmReceiptTime]								DATETIME		NULL,
	[strOfflineFlagValue]							NVARCHAR(40)		NULL,
	[strSuspendFlagValue]							NVARCHAR(40)		NULL,

	-- LinkedTransactionInfo
	[intOriginalStoreLocationID]					INT				NULL,
	[intOriginalRegisterID]							INT				NULL,
	[intOriginalTransactionID]						INT				NULL,
	[dtmOriginalEventStartDate]						DATETIME		NULL,
	[dtmOriginalEventStartTime]						DATETIME		NULL,
	[dtmOriginalEventEndDate]						DATETIME		NULL,
	[dtmOriginalEventEndTime]						DATETIME		NULL,
	[strTransactionLinkReason]						NVARCHAR(40)	NULL,

	-- TransactionLine
	[strTransactionLineStatus]						NVARCHAR(40)	NULL,

	-- ItemLine
	-- > ItemCode
	[strItemLineItemCodeFormat]						NVARCHAR(40)	NULL,
	[strItemLinePOSCode]							NVARCHAR(40)	NULL,
	[strItemLinePOSCodeModifier]					NVARCHAR(40)		NULL,
	[strItemLinePOSCodeModifierName]				NVARCHAR(40)	NULL,
	-- > ItemTax
	[intItemLineTaxLevelID]							INT				NULL,
	-- > FuelLine
	[strFuelGradeID]								NVARCHAR(40)	NULL,
	[intFuelPositionID]								INT				NULL,
	[strPriceTierCode]								NVARCHAR(40)		NULL,
	[intTimeTierCode]								INT				NULL,
	[strServiceLevelCode]							NVARCHAR(40)	NULL,
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
	[strMerchandiseCodeLineDescription]				NVARCHAR(200)	NULL,
	[dblActualSalesPrice]							DECIMAL(18, 6)	NULL,
	-- > Promotion
	[strPromotionID]								NVARCHAR(200)	NULL,
	[strPromotionIDType]							NVARCHAR(40)	NULL,
	[strPromotionReason]							NVARCHAR(200)	NULL,
	[dblPromotionAmount]							DECIMAL(18, 6)	NULL,

	[strLineDescription]							NVARCHAR(200)	NULL,
	[strLineEntryMethod]							NVARCHAR(40)	NULL,
	[dblLineActualSalesPrice]						DECIMAL(18, 6)	NULL,
	[intLineMerchandiseCode]						INT				NULL,
	[intItemLineSellingUnits]						INT				NULL,
	[dblLineRegularSellPrice]						DECIMAL(18, 6)	NULL,
	[dblLineSalesQuantity]							DECIMAL(18, 6)	NULL,
	[dblLineSalesAmount]							DECIMAL(18, 6)	NULL,
	-- > SalesRestriction
	[strSalesRestrictFlagValue]						NVARCHAR(40)	NULL,
	[strSalesRestrictFlagType]						NVARCHAR(40)	NULL,

	-- TenderInfo
	[strTenderCode]									NVARCHAR(30)	NULL,
	[strTenderSubCode]								NVARCHAR(30)	NULL,
	[dblTenderAmount]								DECIMAL(18, 6)	NULL,
	[strChangeFlag]									NVARCHAR(40)	NULL,
	-- > Authorization
	[strPreAuthorizationFlag]						NVARCHAR(40)	NULL,
	[strRequestedAmount]							NVARCHAR(40)	NULL,
	[strAuthorizationResponseCode]					NVARCHAR(40)	NULL,
	[strAuthorizationResponseDescription]			NVARCHAR(200)	NULL,
	[strApprovalReferenceCode]						NVARCHAR(40)	NULL,
	[strReferenceNumber]							NVARCHAR(40)	NULL,
	[strProviderID]									NVARCHAR(200)	NULL,
	[dtmAuthorizationDate]							DATETIME		NULL,
	[dtmAuthorizationTime]							DATETIME		NULL,
	[strHostAuthorizedFlag]							NVARCHAR(40)	NULL,
	[strAuthorizationApprovalDescription]			NVARCHAR(40)	NULL,
	[strAuthorizingTerminalID]						NVARCHAR(40)	NULL,
	[strForceOnLineFlag]							NVARCHAR(40)	NULL,
	[strElectronicSignature]						NVARCHAR(40)	NULL,
	[dblAuthorizedChargeAmount]						DECIMAL(18, 6)	NULL,

	-- TransactionSummary
	[dblTransactionTotalGrossAmount]				DECIMAL(18, 6)	NULL,
	[dblTransactionTotalNetAmount]					DECIMAL(18, 6)	NULL,
	[dblTransactionTotalTaxSalesAmount]				DECIMAL(18, 6)	NULL,
	[dblTransactionTotalTaxExemptAmount]			DECIMAL(18, 6)	NULL,
	[dblTransactionTotalTaxNetAmount]				DECIMAL(18, 6)	NULL,
	[dblTransactionTotalGrandAmount]				DECIMAL(18, 6)	NULL,
	[strTransactionTotalGrandAmountDirection]		NVARCHAR(40)	NULL
)