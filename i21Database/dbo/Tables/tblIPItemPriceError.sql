CREATE TABLE tblIPItemPriceError (
	intItemPriceStageId INT IDENTITY(1, 1)
	,intTrxSequenceNo BIGINT
	,strCompanyLocation NVARCHAR(6) COLLATE Latin1_General_CI_AS
	,intActionId INT
	,dtmCreatedDate DATETIME
	,strCreatedBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,dblStandardCost NUMERIC(18, 6)
	,strCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS
	
	,strErrorMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,dtmTransactionDate DATETIME DEFAULT(GETDATE())
	,ysnMailSent BIT DEFAULT 0
	
	,CONSTRAINT PK_tblIPItemPriceError PRIMARY KEY (intItemPriceStageId)
	)
