CREATE TABLE [dbo].[tblCFNetworkCostStaging](
	[intNetworkCostStagingId] [int] IDENTITY(1,1)  NOT NULL,
	[strSiteNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate] [datetime] NULL,
	[strItemNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[dblTransferCost] [numeric](18, 6) NULL,
	[dblTaxesPerUnit] [numeric](18, 6) NULL,
	[strGUID] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intEntityId] INT NULL, 
	[intRecordNo] INT NULL, 
	[ysnInvalidData]	BIT NULL,
	[strInvalidDataReason] NVARCHAR(MAX),
	[intConcurrencyId] INT CONSTRAINT [DF_tblCFNetworkCostStaging_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFNetworkCostStaging] PRIMARY KEY CLUSTERED (intNetworkCostStagingId ASC),
 );
GO