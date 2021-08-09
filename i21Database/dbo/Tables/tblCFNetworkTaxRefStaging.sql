CREATE TABLE [dbo].[tblCFNetworkTaxRefStaging](
	[intNetworkTaxRefStagingId] [int] IDENTITY(1,1)  NOT NULL,
	[intNetworkId] [int] NULL,
	[strNetworkId] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strItemCategory] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strNetworkTaxCode] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strState] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strTaxCode] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strGUID] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intEntityId] INT NULL, 
	[intRecordNo] INT NULL, 
	[ysnInvalidData]	BIT NULL,
	[strInvalidDataReason] NVARCHAR(MAX),
	[intConcurrencyId] INT CONSTRAINT [DF_tblCFNetworkTaxRefStaging_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFNetworkTaxRefStaging] PRIMARY KEY CLUSTERED (intNetworkTaxRefStagingId ASC),
 );
GO


