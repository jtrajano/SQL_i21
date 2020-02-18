﻿CREATE TABLE tblQMProductStage
(
	intProductStageId						INT IDENTITY(1,1) PRIMARY KEY, 
	intProductId							INT,
	strProductName							NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strHeaderXML							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strProductControlPointXML				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strProductTestXML						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strProductPropertyXML					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strProductPropertyValidityPeriodXML		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strConditionalProductPropertyXML		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strProductPropertyFormulaPropertyXML	NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strRowState								NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strUserName								NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFeedStatus							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate								DATETIME CONSTRAINT DF_tblQMProductStage_dtmFeedDate DEFAULT GETDATE(),
	strMessage								NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intMultiCompanyId						INT,
	intEntityId								INT,
	intCompanyLocationId					INT,
	strTransactionType						NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intToBookId								INT,
	ysnMailSent								BIT CONSTRAINT DF_tblQMProductStage_ysnMailSent DEFAULT 0
)