CREATE TABLE [dbo].[tblIPSAPInternalOrder]
(
	[intInternalOrderId] INT IDENTITY(1, 1),
	[strSAPInternalOrderNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[intCommodityId] INT,
	[intYearDiff] INT,

	CONSTRAINT [PK_tblIPSAPInternalOrder_intInternalOrderId] PRIMARY KEY ([intInternalOrderId]) 
)
