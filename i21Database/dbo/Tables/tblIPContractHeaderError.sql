CREATE TABLE tblIPContractHeaderError (
	intContractHeaderStageId INT IDENTITY(1, 1)
	,intDocNo BIGINT
	,strSender NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strContractNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dtmContractDate DATETIME
	,strVendorAccountNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strCommodity NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strTermsCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strIncoTerm NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strIncoTermLocation NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strSalesPerson NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,dblContractValue NUMERIC(18, 6)
	,strCurrency NVARCHAR(40) COLLATE Latin1_General_CI_AS
	,dtmPeriodFrom DATETIME
	,dtmPeriodTo DATETIME
	,strStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strBuyingOrderNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	
	,strErrorMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,dtmTransactionDate DATETIME DEFAULT(GETDATE())
	,ysnMailSent BIT DEFAULT 0
	
	,CONSTRAINT PK_tblIPContractHeaderError PRIMARY KEY (intContractHeaderStageId)
	)
