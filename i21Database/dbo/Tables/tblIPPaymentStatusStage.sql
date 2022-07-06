CREATE TABLE tblIPPaymentStatusStage (
	intPaymentStatusStageId INT IDENTITY(1, 1)
	,intTrxSequenceNo BIGINT
	,strCompanyLocation NVARCHAR(6) COLLATE Latin1_General_CI_AS
	,intActionId INT
	,dtmCreatedDate DATETIME
	,strCreatedBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strVoucherNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strERPVoucherNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strERPJournalNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intPaymentStatus INT
	,strERPPaymentReferenceNo NVARCHAR(50) COLLATE Latin1_General_CI_AS

	,strErrorMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,dtmTransactionDate DATETIME DEFAULT(GETDATE())
	,ysnMailSent BIT DEFAULT 0
	,intStatusId INT
	
	,CONSTRAINT PK_tblIPPaymentStatusStage PRIMARY KEY (intPaymentStatusStageId)
	)
