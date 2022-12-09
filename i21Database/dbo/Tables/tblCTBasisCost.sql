CREATE TABLE [dbo].[tblCTBasisCost]
(
	[intBasisCostId] INT IDENTITY (1, 1) NOT NULL,
	[strItemNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intItemId] INT NOT NULL,
	[intPriority] INT NOT NULL,
    [intSort] INT NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 1,
	[strCostMethod] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	CONSTRAINT [PK_tblCTBasisCost] PRIMARY KEY CLUSTERED ([intBasisCostId] ASC),
    
)