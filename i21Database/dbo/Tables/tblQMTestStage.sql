﻿CREATE TABLE tblQMTestStage
(
	intTestStageId				INT IDENTITY(1,1) PRIMARY KEY, 
	intTestId					INT,
	strTestName					NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strHeaderXML				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strTestPropertyXML			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strRowState					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strUserName					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFeedStatus				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate					DATETIME CONSTRAINT DF_tblQMTestStage_dtmFeedDate DEFAULT GETDATE(),
	strMessage					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intMultiCompanyId			INT,
	intEntityId					INT,
	intCompanyLocationId		INT,
	strTransactionType			NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intToBookId					INT
)