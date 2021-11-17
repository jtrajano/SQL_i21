﻿CREATE TABLE [dbo].[tblLGLoadStg]
(
	[intLoadStgId] INT IDENTITY(1,1) PRIMARY KEY,
	[intLoadId] INT,
	[strTransactionType] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	[strLoadNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	[strShippingInstructionNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	[strContractBasis] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	[strContractBasisDesc] NVARCHAR(500) COLLATE Latin1_General_CI_AS, 
	[strBillOfLading] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[strShippingLine] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[strShippingLineAccountNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[strExternalShipmentNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[strDateQualifier] NVARCHAR(10) COLLATE Latin1_General_CI_AS,
	[dtmScheduledDate] DATETIME, 
	[strMVessel] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strMVoyageNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strFVessel] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strFVoyageNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[dtmETAPOD] DATETIME, 
	[dtmETAPOL] DATETIME, 
	[dtmETSPOL] DATETIME, 
	[dtmBLDate] DATETIME, 
	[strRowState] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[strFeedStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[dtmFeedCreated] DATETIME,
	[strMessage] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS, 
	[strMessageState] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[ysnMailSent]	BIT DEFAULT 0
)
GO

CREATE NONCLUSTERED INDEX [IX_tblLGLoadStg_intLoadId] ON [dbo].[tblLGLoadStg]
(
	[intLoadId] ASC
)
INCLUDE 
(
	[strRowState]
	,[strFeedStatus]
)

GO