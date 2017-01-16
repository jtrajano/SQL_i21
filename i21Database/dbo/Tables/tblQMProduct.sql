﻿CREATE TABLE [dbo].[tblQMProduct]
(
	[intProductId] INT NOT NULL IDENTITY, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMProduct_intConcurrencyId] DEFAULT 0, 
	[intProductTypeId] INT NOT NULL, 
	[intProductValueId] INT NULL CONSTRAINT [DF_tblQMProduct_intProductValueId] DEFAULT 0, 
	[strDirections] NVARCHAR(1000) COLLATE Latin1_General_CI_AS, 
	[strNote] NVARCHAR(500) COLLATE Latin1_General_CI_AS, 
	[ysnActive] BIT NOT NULL CONSTRAINT [DF_tblQMProduct_ysnActive] DEFAULT 1,
	[intApprovalLotStatusId] INT, 
	[intRejectionLotStatusId] INT, 
	[intBondedApprovalLotStatusId] INT, 
	[intBondedRejectionLotStatusId] INT, 
	[intUnitMeasureId] INT, 

	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMProduct_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMProduct_dtmLastModified] DEFAULT GetDate(),
		
	CONSTRAINT [PK_tblQMProduct] PRIMARY KEY ([intProductId]), 
	CONSTRAINT [FK_tblQMProduct_tblQMProductType] FOREIGN KEY ([intProductTypeId]) REFERENCES [tblQMProductType]([intProductTypeId]),
	CONSTRAINT [FK_tblQMProduct_tblICLotStatus_intApprovalLotStatusId] FOREIGN KEY ([intApprovalLotStatusId]) REFERENCES [tblICLotStatus]([intLotStatusId]),
	CONSTRAINT [FK_tblQMProduct_tblICLotStatus_intRejectionLotStatusId] FOREIGN KEY ([intRejectionLotStatusId]) REFERENCES [tblICLotStatus]([intLotStatusId]),
	CONSTRAINT [FK_tblQMProduct_tblICLotStatus_intBondedApprovalLotStatusId] FOREIGN KEY ([intBondedApprovalLotStatusId]) REFERENCES [tblICLotStatus]([intLotStatusId]),
	CONSTRAINT [FK_tblQMProduct_tblICLotStatus_intBondedRejectionLotStatusId] FOREIGN KEY ([intBondedRejectionLotStatusId]) REFERENCES [tblICLotStatus]([intLotStatusId]),
	CONSTRAINT [FK_tblQMProduct_tblICUnitMeasure_intUnitMeasureId] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])
)