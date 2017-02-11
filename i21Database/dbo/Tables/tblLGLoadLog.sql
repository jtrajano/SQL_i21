﻿CREATE TABLE [dbo].[tblLGLoadLog]
(
	[intLoadLogId] INT IDENTITY(1,1) PRIMARY KEY,
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
	[dtmETAPOD] DATETIME, 
	[dtmETAPOL] DATETIME, 
	[dtmETSPOL] DATETIME, 
	[dtmBLDate] DATETIME, 
	[strRowState] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[strFeedStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[strMessage] NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
)
