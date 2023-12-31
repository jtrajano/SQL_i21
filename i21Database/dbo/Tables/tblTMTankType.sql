﻿CREATE TABLE [dbo].[tblTMTankType] (
    [intConcurrencyId] INT           DEFAULT 1 NOT NULL,
    [intTankTypeId]    INT           IDENTITY (1, 1) NOT NULL,
    [strTankType]      NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_tblTMTankType] PRIMARY KEY CLUSTERED ([intTankTypeId] ASC),
	CONSTRAINT [UQ_strTankType_strTankType] UNIQUE NONCLUSTERED ([strTankType] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMTankType',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMTankType',
    @level2type = N'COLUMN',
    @level2name = N'intTankTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tank Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMTankType',
    @level2type = N'COLUMN',
    @level2name = N'strTankType'