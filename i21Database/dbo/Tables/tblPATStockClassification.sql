CREATE TABLE [dbo].[tblPATStockClassification]
(
	[intStockId] INT NOT NULL  IDENTITY, 
    [strStockName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strStockDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL, 
    [dblParValue] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [intDividendsGLAccount] INT NOT NULL DEFAULT 0, 
    [intTreasuryGLAccount] INT NOT NULL DEFAULT 0, 
    [intDividendsPerShare] INT NULL DEFAULT 0, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT 1, 
    CONSTRAINT [PK_tblPATStockClassification] PRIMARY KEY ([intStockId]), 
	CONSTRAINT [AK_tblPATStockClassification_strStockName] UNIQUE ([strStockName]), 
    CONSTRAINT [FK_tblPATStockClassification_tblDividendGLAccount] FOREIGN KEY ([intDividendsGLAccount]) REFERENCES [tblGLAccount]([intAccountId]), 
    CONSTRAINT [FK_tblPATStockClassification_tblTreasuryGLAccount] FOREIGN KEY ([intTreasuryGLAccount]) REFERENCES [tblGLAccount]([intAccountId]) 
)
