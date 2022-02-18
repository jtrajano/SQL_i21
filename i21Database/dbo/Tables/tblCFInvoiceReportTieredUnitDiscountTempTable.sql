CREATE TABLE tblCFInvoiceReportTieredUnitDiscountTempTable 
	(
		[intInvoiceReportTieredUnitDiscountTempTableId]                     INT             IDENTITY (1, 1) NOT NULL,
		[strGuid]															NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
		[strUserId]															NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
		[strStatementType]													NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
		[intAccountId]														INT	NULL,
		[intCustomerGroupId]												INT	NULL,
		[strGroupName]														NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
		[dblEligibleGallons]												NUMERIC(18,6) NULL,
		[intDiscountScheduleId]												INT	NULL,
		[dblRate]															NUMERIC(18,6) NULL,
		[dblQuantity]														NUMERIC(18,6) NULL,
		[dblAmount]															NUMERIC(18,6) NULL,
		[intFeeProfileId]													INT	NULL,
		[intFeeId]															INT	NULL,
		[intTransactionId]													INT	NULL
	)