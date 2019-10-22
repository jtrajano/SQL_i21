﻿CREATE TABLE tblQMSampleStage
(
	intSampleStageId		INT IDENTITY(1,1) PRIMARY KEY, 
	intSampleId				INT,
	strSampleNumber			NVARCHAR(100)  COLLATE Latin1_General_CI_AS,
	strHeaderXML			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strDetailXML			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strTestResultXML		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strReference			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strRowState				NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFeedStatus			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate				DATETIME CONSTRAINT DF_tblQMSampleStage_dtmFeedDate DEFAULT GETDATE(),
	strMessage				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intMultiCompanyId		INT,
	intEntityId				INT,
	intCompanyLocationId	INT,
	strTransactionType		NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intToBookId				INT,
	strFromCompanyName		NVARCHAR(150) COLLATE Latin1_General_CI_AS,
	intNewSampleId			INT,
	strNewSampleNumber		NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strNewSampleTypeName	NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	ysnMailSent				BIT CONSTRAINT DF_tblQMSampleStage_ysnMailSent DEFAULT 0
)