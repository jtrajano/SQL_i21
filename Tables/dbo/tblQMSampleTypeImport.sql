CREATE TABLE [dbo].[tblQMSampleTypeImport]
(
	[intImportId] INT NOT NULL IDENTITY, 
	[strSampleTypeName] NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
	[strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[strControlPointName] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[ysnFinalApproval] BIT NOT NULL CONSTRAINT [DF_tblQMSampleTypeImport_ysnFinalApproval] DEFAULT 0, 
	strApprovalBase NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strSampleLabelName NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	ysnAdjustInventoryQtyBySampleQty BIT CONSTRAINT [DF_tblQMSampleTypeImport_ysnAdjustInventoryQtyBySampleQty] DEFAULT 0,
	[strApprovalLotStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[strRejectionLotStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[strBondedApprovalLotStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[strBondedRejectionLotStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS,

	[strAttributeName] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[ysnIsMandatory] BIT NOT NULL CONSTRAINT [DF_tblQMSampleTypeImport_ysnIsMandatory] DEFAULT 0, 
	
	[ysnProcessed] BIT NOT NULL CONSTRAINT [DF_tblQMSampleTypeImport_ysnProcessed] DEFAULT 0, 
	[strErrorMsg] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS, 

	CONSTRAINT [PK_tblQMSampleTypeImport] PRIMARY KEY ([intImportId])
)