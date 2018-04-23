CREATE TABLE [dbo].[tblCFNetworkCost](
	[intNetworkCost] [int] NOT NULL,
	[intSiteId] [int] NULL,
	[dtmDate] [datetime] NULL,
	[intItemId] [int] NULL,
	[dblTransferCost] [numeric](18, 6) NULL,
	[dblTaxesPerUnit] [numeric](18, 6) NULL,
	CONSTRAINT [PK_tblCFNetworkCost] PRIMARY KEY CLUSTERED ([intNetworkCost] ASC),
 );
GO