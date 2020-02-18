﻿CREATE TABLE tblQMPropertyStage
(
	intPropertyStageId				INT IDENTITY(1,1) PRIMARY KEY, 
	intPropertyId					INT,
	strPropertyName					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strHeaderXML					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strPropertyValidityPeriodXML	NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strConditionalPropertyXML		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strRowState						NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strUserName						NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFeedStatus					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate						DATETIME CONSTRAINT DF_tblQMPropertyStage_dtmFeedDate DEFAULT GETDATE(),
	strMessage						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intMultiCompanyId				INT,
	intEntityId						INT,
	intCompanyLocationId			INT,
	strTransactionType				NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intToBookId						INT,
	ysnMailSent						BIT CONSTRAINT DF_tblQMPropertyStage_ysnMailSent DEFAULT 0
)