﻿CREATE TABLE [dbo].[tblPATStockClassification]
(
	[intStockId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strStockName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strStockDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [dblParValue] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblNextCertificate] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [intDividendsGLAccount] INT NULL DEFAULT 0, 
    [intTreasuryGLAccount] INT NULL DEFAULT 0, 
    [intDividendsPerShare] INT NULL DEFAULT 0, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT 1
)
