CREATE TABLE tblIPCurrencyRateStage (
	intCurrencyRateStageId INT identity(1, 1)
	,intTrxSequenceNo BIGINT
	,strCompanyLocation NVARCHAR(6) COLLATE Latin1_General_CI_AS
	,intActionId INT
	,dtmCreatedDate DATETIME
	,strCreatedBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strFromCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strToCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblRate NUMERIC(18, 6)
	,strRateType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dtmEffectiveDate DATETIME
	
	,strErrorMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,dtmTransactionDate DATETIME DEFAULT(GETDATE())
	,ysnMailSent BIT DEFAULT 0
	,intStatusId INT
	
	,CONSTRAINT PK_tblIPCurrencyRateStage PRIMARY KEY (intCurrencyRateStageId)
	)
