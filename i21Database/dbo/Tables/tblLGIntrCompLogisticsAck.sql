﻿	CREATE TABLE tblLGIntrCompLogisticsAck
	(
		[intAcknowledgementId] INT IDENTITY(1,1) PRIMARY KEY, 
		[intLoadId] INT,
		[strLoadNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
		[strLoad] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		[strLoadDetail] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		[strLoadDetailLot] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		[strLoadNotifyParty] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		[strLoadDocument] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		[strLoadContainer] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		[strLoadDetailContainerLink] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		[strLoadWarehouse] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		[strLoadWarehouseContainer] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		[strLoadWarehouseServices] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		[strLoadCost] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		[strLoadStorageCost] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		[strReference] NVARCHAR(512) COLLATE Latin1_General_CI_AS NULL,
		[strRowState] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
		[strFeedStatus] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NULL,
		[dtmFeedDate] DATETIME DEFAULT(GETDATE()),
		[strMessage] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		[intMultiCompanyId] INT,
		[intReferenceId] INT,
		[intEntityId] INT,
		[strTransactionType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
		intTransactionId int,
		intCompanyId int,
		intTransactionRefId int,
		intCompanyRefId int
	)