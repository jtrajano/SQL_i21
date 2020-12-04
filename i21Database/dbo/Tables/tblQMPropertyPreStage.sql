﻿CREATE TABLE tblQMPropertyPreStage
(
	intPropertyPreStageId			INT IDENTITY(1,1) PRIMARY KEY, 
	intPropertyId					INT,
	strPropertyName					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strRowState						NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intUserId						INT,
	strFeedStatus					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate						DATETIME CONSTRAINT DF_tblQMPropertyPreStage_dtmFeedDate DEFAULT GETDATE(),
	strMessage						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	ysnMailSent						BIT CONSTRAINT DF_tblQMPropertyPreStage_ysnMailSent DEFAULT 0,
	intStatusId						INT
)