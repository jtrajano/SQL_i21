CREATE TABLE tblIPTestResultArchive
(
	intTestResultStageId		INT IDENTITY(1,1),
	strSampleNumber				NVARCHAR(30) COLLATE Latin1_General_CI_AS,
	strSampleStatus				NVARCHAR(30) COLLATE Latin1_General_CI_AS,
	dblCuppingScore				NUMERIC(18, 6),
	dblGradingScore				NUMERIC(18, 6),
	strComments					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmCuppingDate				DATETIME,
	strCuppedBy					NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dtmUpdated					DATETIME,
	strUpdatedBy				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intRecordStatus				INT,

	strErrorMessage				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strImportStatus				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dtmTransactionDate			DATETIME DEFAULT(GETDATE()),
	ysnMailSent					BIT DEFAULT 0,

	CONSTRAINT [PK_tblIPTestResultArchive_intTestResultStageId] PRIMARY KEY (intTestResultStageId)
)
