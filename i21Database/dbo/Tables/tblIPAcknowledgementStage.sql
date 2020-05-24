CREATE TABLE [dbo].[tblIPAcknowledgementStage] (
	intAcknowledgementStageId INT NOT NULL IDENTITY(1, 1)
	,strXml NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,dtmCreatedDate DATETIME CONSTRAINT [DF_tblIPAcknowledgementStage_dtmCreatedDate] DEFAULT GETDATE()
	,intDeadLock INT  CONSTRAINT [DF_tblIPAcknowledgementStage_intDeadLock] DEFAULT 0
	,stri21ReferenceNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strERPReferenceNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,CONSTRAINT [PK_tblIPAcknowledgementStage_intAcknowledgementStageId] PRIMARY KEY (intAcknowledgementStageId)
	)
