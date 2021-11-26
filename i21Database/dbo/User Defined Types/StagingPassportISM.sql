CREATE TYPE StagingPassportISM AS TABLE
(
	intRowCount 				INT				  NULL,
	intStoreLocationId			INT				  NULL,
	strVendorName				NVARCHAR(MAX)	  NULL,
	strVendorModelVersion		NVARCHAR(MAX)	  NULL,
	intReportSequenceNumber		INT				  NULL,
	intPrimaryReportPeriod		INT				  NULL,
	intSecondaryReportPeriod	INT				  NULL,
	dtmBusinessDate				DATETIME		  NULL,
	dtmBeginDate				DATETIME		  NULL,
	dtmBeginTime				DATETIME		  NULL,
	dtmEndDate					DATETIME		  NULL,
	dtmEndTime					DATETIME		  NULL,
	strPOSCodeFormat			NVARCHAR(MAX)	  NULL,
	strPOSCode					NVARCHAR(MAX)	  NULL,
	intPOSCodeModifier		    INT				  NULL,
	strItemID					NVARCHAR(MAX)	  NULL,
	strDescription				NVARCHAR(MAX)	  NULL,
	intMerchandiseCode		    INT				  NULL,
	intSellingUnits			    INT				  NULL,
	dblActualSalesPrice			NUMERIC(18,6)     NULL,
	dblSalesQuantity			NUMERIC(18,6)     NULL,
	dblSalesAmount				NUMERIC(18,6)     NULL,
	dblDiscountAmount			NUMERIC(18,6)     NULL,
	dblDiscountCount			NUMERIC(18,6)     NULL,
	dblPromotionAmount			NUMERIC(18,6)     NULL,
	dblPromotionCount			NUMERIC(18,6)     NULL,
	dblRefundAmount				NUMERIC(18,6)     NULL,
	dblRefundCount				NUMERIC(18,6)     NULL,
	dblTransactionCount			NUMERIC(18,6)     NULL
)
