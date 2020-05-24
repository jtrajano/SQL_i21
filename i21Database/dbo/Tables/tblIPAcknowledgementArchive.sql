CREATE TABLE [dbo].[tblIPAcknowledgementArchive] (
	intAcknowledgementArchiveId INT NOT NULL IDENTITY(1, 1)
	,strXml NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,dtmCreatedDate DATETIME CONSTRAINT [DF_tblIPAcknowledgementArchive_dtmCreatedDate] DEFAULT GETDATE()
	,intDeadLock INT  CONSTRAINT [DF_tblIPAcknowledgementArchive_intDeadLock] DEFAULT 0
		,stri21ReferenceNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strERPReferenceNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,CONSTRAINT [PK_tblIPAcknowledgementArchive_intAcknowledgementArchiveId] PRIMARY KEY (intAcknowledgementArchiveId)
	)
