CREATE TABLE [dbo].[tblCCImportDealerHeader]
(
	[intImportDealerHeaderId] INT NOT NULL IDENTITY,
	
	[strVendor] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
    [strDate] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strInvoice] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strReference] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strCcdReference] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strPayReference] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblGross] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblFees] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblNet] DECIMAL(18, 6) NULL DEFAULT 0, 
	CONSTRAINT [PK_tblCCImportDealerHeader] PRIMARY KEY ([intImportDealerHeaderId])
	
)
