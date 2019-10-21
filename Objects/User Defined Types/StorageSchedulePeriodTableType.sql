CREATE TYPE StorageSchedulePeriodTableType AS TABLE ( 
	intSchedulePeriodId INT IDENTITY PRIMARY KEY CLUSTERED
	,intPeriodNumber		INT NULL
	,strPeriodType			NVARCHAR(30) NULL
	,dtmStartDate			DATETIME NULL
	,dtmEndingDate			DATETIME NULL
	,intNumberOfDays		INT NULL
	,dblStorageRate			NUMERIC(18,6) NULL
	,dblFeeRate				NUMERIC(18,6) NULL
	,strFeeType				NVARCHAR(30) NULL
)