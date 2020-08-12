CREATE TABLE [dbo].[tblQMSampleType]
(
	[intSampleTypeId] INT NOT NULL IDENTITY, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMSampleType_intConcurrencyId] DEFAULT 0, 
	[strSampleTypeName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[intControlPointId] INT NOT NULL, 
	[ysnFinalApproval] BIT NOT NULL CONSTRAINT [DF_tblQMSampleType_ysnFinalApproval] DEFAULT 0, 
	strApprovalBase NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intSampleLabelId INT,
	ysnAdjustInventoryQtyBySampleQty BIT CONSTRAINT [DF_tblQMSampleType_ysnAdjustInventoryQtyBySampleQty] DEFAULT 0,
	ysnPartyMandatory BIT CONSTRAINT [DF_tblQMSampleType_ysnPartyMandatory] DEFAULT 1,
	[intApprovalLotStatusId] INT, 
	[intRejectionLotStatusId] INT, 
	[intBondedApprovalLotStatusId] INT, 
	[intBondedRejectionLotStatusId] INT, 
	intSampleTypeRefId INT,

	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMSampleType_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMSampleType_dtmLastModified] DEFAULT GetDate(),
		
	CONSTRAINT [PK_tblQMSampleType] PRIMARY KEY ([intSampleTypeId]), 
	CONSTRAINT [AK_tblQMSampleType_strSampleTypeName] UNIQUE ([strSampleTypeName]), 
	CONSTRAINT [FK_tblQMSampleType_tblQMControlPoint] FOREIGN KEY ([intControlPointId]) REFERENCES [tblQMControlPoint]([intControlPointId]),
	CONSTRAINT [FK_tblQMSampleType_tblQMSampleLabel] FOREIGN KEY ([intSampleLabelId]) REFERENCES [tblQMSampleLabel]([intSampleLabelId]),
	CONSTRAINT [FK_tblQMSampleType_tblICLotStatus_intApprovalLotStatusId] FOREIGN KEY ([intApprovalLotStatusId]) REFERENCES [tblICLotStatus]([intLotStatusId]),
	CONSTRAINT [FK_tblQMSampleType_tblICLotStatus_intRejectionLotStatusId] FOREIGN KEY ([intRejectionLotStatusId]) REFERENCES [tblICLotStatus]([intLotStatusId]),
	CONSTRAINT [FK_tblQMSampleType_tblICLotStatus_intBondedApprovalLotStatusId] FOREIGN KEY ([intBondedApprovalLotStatusId]) REFERENCES [tblICLotStatus]([intLotStatusId]),
	CONSTRAINT [FK_tblQMSampleType_tblICLotStatus_intBondedRejectionLotStatusId] FOREIGN KEY ([intBondedRejectionLotStatusId]) REFERENCES [tblICLotStatus]([intLotStatusId])
)