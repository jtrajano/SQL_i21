CREATE TABLE [dbo].[tblCFNetworkCost](
	[intNetworkCostId] [int] IDENTITY(1,1)  NOT NULL,
	[intSiteId] [int] NULL,
	[intNetworkId] [int] NOT NULL,
	[dtmDate] [datetime] NULL,
	[intItemId] [int] NULL,
	[dblTransferCost] [numeric](18, 6) NULL,
	[dblTaxesPerUnit] [numeric](18, 6) NULL,
	[intConcurrencyId] INT CONSTRAINT [DF_tblCFNetworkCost_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFNetworkCost] PRIMARY KEY CLUSTERED ([intNetworkCostId] ASC),
 );
GO