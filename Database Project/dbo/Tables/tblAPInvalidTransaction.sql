﻿CREATE TABLE [dbo].[tblAPInvalidTransaction]
(
	[intId] INT NOT NULL PRIMARY KEY, 
    [strError] NVARCHAR(100) NULL, 
    [strTransactionType] NVARCHAR(50) NULL, 
    [strTransactionId] NVARCHAR(50) NULL
)
