CREATE TABLE [dbo].[tblIPAcknowledgementError] (
	intAcknowledgementErrorId INT NOT NULL IDENTITY(1, 1)
	,strXml NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strMsg NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,dtmCreatedDate DATETIME CONSTRAINT [DF_tblIPAcknowledgementError_dtmCreatedDate] DEFAULT GETDATE()
	,intDeadLock INT  CONSTRAINT [DF_tblIPAcknowledgementError_intDeadLock] DEFAULT 0
		,stri21ReferenceNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strERPReferenceNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,CONSTRAINT [PK_tblIPAcknowledgementError_intAcknowledgementErrorId] PRIMARY KEY (intAcknowledgementErrorId)
	)
