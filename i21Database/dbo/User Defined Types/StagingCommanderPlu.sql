CREATE TYPE StagingCommanderPlu AS TABLE
(
	[intRowCount] 										INT					NULL,
	[strPeriodSysId] 								    NVARCHAR(MAX)		NULL,
	[strPeriodPeriodType]                     			NVARCHAR(MAX)		NULL,
	[strPeriodName]                  					NVARCHAR(MAX)		NULL,
	[intPeriodPeriodSeqNum]                           	NVARCHAR(MAX)		NULL,
	[strPeriodPeriodBeginDate]                          NVARCHAR(MAX)		NULL,
	[strPeriodPeriodEndDate]                       		NVARCHAR(MAX)		NULL,
	[strPluPdPeriod]									NVARCHAR(MAX)		NULL,
	[intPluPdSite]                           			INT					NULL,
	[dblPluInfoSalePrice]                             	NUMERIC(18,6)		NULL,
	[dblPluInfoOriginalPrice]                           NUMERIC(18,6)		NULL,
	[strPluInfoReasonCode]                        		NVARCHAR(MAX)		NULL,
	[dblPluInfoPercentOfSales]                        	NUMERIC(18,6)		NULL,
	[intPluBaseUPC]                        				BIGINT				NULL,
	[intPluBaseModifier]                        		INT					NULL,
	[strPluBaseName]                        			NVARCHAR(MAX)		NULL,
	[intNetSalesCount]                        			INT					NULL,
	[dblNetSalesAmount]                        			NUMERIC(18,6)		NULL,
	[dblNetSalesItemCount]                        		NUMERIC(18,6)		NULL
)