CREATE TYPE StagingNetworkCard AS TABLE
(
	[intRowCount]									INT				NOT NULL,
	
	-- Header
	[intPeriodSysid]								INT				NULL,
	[strPeriodPeriodType]							NVARCHAR(20)	NULL,
	[strPeriodName]									NVARCHAR(20)	NULL,
	[intPeriodPeriodSeqNum]							INT				NULL,
	[dtmPeriodPeriodBeginDate]						DATETIME		NULL,
	[dtmPeriodPeriodEndDate]						DATETIME		NULL,
	[intPeriodSite]									INT				NULL,

	-- Body
	[intCardInfoCardNumber]							INT				NULL,
	[strCardInfoCardName]							NVARCHAR(30)	NULL,
	[dblCardChargesCount]							DECIMAL(18, 6)	NULL,
	[dblCardChargesAmount]							DECIMAL(18, 6)	NULL,
	[dblCardCorrectionsCount]						DECIMAL(18, 6)	NULL,
	[dblCardCorrectionsAmount]						DECIMAL(18, 6)	NULL
)