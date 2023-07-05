﻿CREATE TABLE [dbo].[tblSTJobTypes]
(
    [intJobTypeId] INT NOT NULL,
    [strJobType] NVARCHAR(150) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId] INT NULL,
    CONSTRAINT [PK_tblSTJobTypes] PRIMARY KEY CLUSTERED ([intJobTypeId] ASC)
)