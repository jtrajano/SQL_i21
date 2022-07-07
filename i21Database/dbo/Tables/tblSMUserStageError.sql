CREATE TABLE tblSMUserStageError
(
	intUserStageErrorId			INT IDENTITY(1,1),
	strUserName					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strUserId					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strExtErpId					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strEmail					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strPhone					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strMobile					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strContactName				NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strLocationName				NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strAddress					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strCity						NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strState					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strZip						NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strCountry					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strUserRole					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	ysnActive					BIT DEFAULT 0,

	strTransactionType			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strErrorMessage				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strImportStatus				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strSessionId				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dtmTransactionDate			DATETIME DEFAULT(GETDATE()),
	ysnMailSent					BIT DEFAULT 0,

	CONSTRAINT [PK_tblSMUserStageError_intUserStageErrorId] PRIMARY KEY ([intUserStageErrorId])
)