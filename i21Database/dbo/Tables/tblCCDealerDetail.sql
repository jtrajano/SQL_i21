CREATE TABLE [dbo].[tblCCDealerDetail]
(
	[intDealerDetailId] INT NOT NULL IDENTITY,
	[intDealerHeaderId] INT NULL DEFAULT 0,
	[intSiteId] INT NULL DEFAULT 0,
	[dblGross] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblFees] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblNet] DECIMAL(18, 6) NULL DEFAULT 0, 
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblCCDealerDetail] PRIMARY KEY ([intDealerDetailId]),
	CONSTRAINT [FK_tblCCDealerDetail_tblCCDealerHeader_intDealerHeaderId] FOREIGN KEY ([intDealerHeaderId]) REFERENCES [dbo].[tblCCDealerHeader] ([intDealerHeaderId]),
	CONSTRAINT [FK_tblCCDealerDetail_tblCCSite_intSiteId] FOREIGN KEY ([intSiteId]) REFERENCES [dbo].[tblCCSite] ([intSiteId])
	
)
