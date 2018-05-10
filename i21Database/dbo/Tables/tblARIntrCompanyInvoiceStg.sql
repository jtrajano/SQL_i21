﻿CREATE TABLE [dbo].[tblARIntrCompanyInvoiceStg]
(
	[intStgId] INT IDENTITY PRIMARY KEY
	,[intInvoiceId] INT
	,[strInvoiceNumber] NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL
	,[intLoadId] INT
	,[intLoadRefId] INT
	,[strLoadNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,[strRowState] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,[strFeedStatus] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NULL
	,[dtmFeedDate] DATETIME
	,[strMessage] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,[intMultiCompanyId] INT
	,[intToCompanyLocationId] INT
	,[intToBookId] INT
	,[intReferenceId] INT
	,[intEntityId] INT
	,[strTransactionType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
)
