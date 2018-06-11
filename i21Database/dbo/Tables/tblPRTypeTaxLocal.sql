﻿CREATE TABLE [dbo].[tblPRTypeTaxLocal](
	[intTypeTaxLocalId] [int] NOT NULL,
	[intTypeTaxStateId] INT NOT NULL, 
	[strLocalName] [nvarchar](20) COLLATE Latin1_General_CI_AS NOT NULL,
	[strLocalType] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
	[intConcurrencyId] [int] NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPRTypeTaxLocal] PRIMARY KEY ([intTypeTaxLocalId]), 
	CONSTRAINT [FK_tblPRTypeTaxLocal_tblPRTypeTaxState] FOREIGN KEY ([intTypeTaxStateId]) REFERENCES [tblPRTypeTaxState]([intTypeTaxStateId])
)
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTaxLocal',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTaxLocalId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Local Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTaxLocal',
    @level2type = N'COLUMN',
    @level2name = 'strLocalName'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTaxLocal',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Local Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTaxLocal',
    @level2type = N'COLUMN',
    @level2name = N'strLocalType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'State Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTaxLocal',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTaxStateId'