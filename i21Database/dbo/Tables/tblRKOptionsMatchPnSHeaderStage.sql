CREATE TABLE tblRKOptionsMatchPnSHeaderStage
(
	intOptionsMatchPnSHeaderStageId		INT IDENTITY(1,1) PRIMARY KEY, 
	intOptionsMatchPnSHeaderId			INT,
	strHeaderXML						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strOptionsMatchPnSXML				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strOptionsPnSExpiredXML				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strRowState							NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strUserName							NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFeedStatus						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate							DATETIME CONSTRAINT DF_tblRKOptionsMatchPnSHeaderStage_dtmFeedDate DEFAULT GETDATE(),
	strMessage							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intMultiCompanyId					INT,
	intEntityId							INT,
	intCompanyLocationId				INT,
	strTransactionType					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intToBookId							INT,
	strFromCompanyName					NVARCHAR(150) COLLATE Latin1_General_CI_AS,
	ysnMailSent							BIT CONSTRAINT DF_tblRKOptionsMatchPnSHeaderStage_ysnMailSent DEFAULT 0,
	intTransactionId					INT,
	intCompanyId						INT,
	intStatusId							INT
)