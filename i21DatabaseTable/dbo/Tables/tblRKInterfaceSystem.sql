﻿CREATE TABLE [dbo].[tblRKInterfaceSystem]
(
	[intInterfaceSystemId] INT IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] INT NOT NULL, 
	[strInterfaceSystem] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strInterfaceSystemURL] NVARCHAR(max) COLLATE Latin1_General_CI_AS NOT NULL,	
	[strOpen] NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
	[strHigh] NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
	[strLow] NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
	[strLastSettle] NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
	[strLastElement] NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
	[strOptInterfaceSystemURL] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strOptOpen] NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL, 
    [strOptHigh] NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL, 
    [strOptLow] NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL, 
    [strOptLastSettle] NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL, 
    CONSTRAINT [PK_tblRKInterfaceSystem_intInterfaceSystemId] PRIMARY KEY ([intInterfaceSystemId])
)