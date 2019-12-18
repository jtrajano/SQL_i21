CREATE TABLE [dbo].[tblICImportStagingUOM] (
	[intImportStagingUOMId] [int] IDENTITY(1,1) NOT NULL,
	[strImportIdentifier] [nvarchar](200) COLLATE Latin1_General_CI_AS NULL,
	[strItemNo] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strUOM] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[dblUnitQty] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strWeightUOM] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strUPCCode] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strShortUPCCode] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[ysnIsStockUnit] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[ysnAllowPurchase] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[ysnAllowSale] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[dblLength] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[dblWidth] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[dblHeight] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strDimensionUOM] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[dblWeight] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[dblVolume] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strVolumeUOM] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[dblMaxQty] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[dtmDateCreated] [datetime] NULL,
	[dtmDateModified] [datetime] NULL,
	[intCreatedByUserId] [int] NULL,
	[intModifiedByUserId] [int] NULL,
	[intConcurrencyId] [int] NULL,
    CONSTRAINT [PK_tblICImportStagingUOM] PRIMARY KEY ([intImportStagingUOMId] ASC)
)