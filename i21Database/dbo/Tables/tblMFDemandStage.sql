CREATE TABLE tblMFDemandStage (
	intDemandStageId INT IDENTITY(1, 1) CONSTRAINT PK_tblMFDemandStage_intDemandStageId PRIMARY KEY
	,intInvPlngReportMasterID INT
	,strInvPlngReportName nvarchar(150)COLLATE Latin1_General_CI_AS
	,strReportMasterXML nvarchar(MAX)COLLATE Latin1_General_CI_AS
	,strReportMaterialXML nvarchar(MAX)COLLATE Latin1_General_CI_AS
	,strReportAttributeValueXML nvarchar(MAX)COLLATE Latin1_General_CI_AS
	,strRowState NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strFeedStatus NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,dtmFeedDate DATETIME CONSTRAINT DF_tblMFDemandStage_dtmFeedDate DEFAULT GETDATE()
	,strMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,intTransactionId int
    ,intCompanyId int
	,strItemSupplyTarget NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,ysnMailSent Bit
	)

