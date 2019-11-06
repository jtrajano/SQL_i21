﻿CREATE TABLE [dbo].[tblRKRiskView]
(
	[intRiskViewId] INT IDENTITY NOT NULL, 
    [strRiskView] NVARCHAR(100) NOT NULL, 
    [ysnCustomWork] BIT NULL DEFAULT ((0)), 
    [strCustomer] NVARCHAR(100) NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblRKRiskView] PRIMARY KEY ([intRiskViewId]) 
)
