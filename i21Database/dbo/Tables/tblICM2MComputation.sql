﻿CREATE TABLE [dbo].[tblICM2MComputation]
(
	[intM2MComputationId] INT IDENTITY(1, 1) NOT NULL, 
    [strM2MComputation] VARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblICM2MComputation] PRIMARY KEY ([intM2MComputationId]), 
)