CREATE TABLE [dbo].[tblICReasonCode]
(
	[intReasonCodeId] INT NOT NULL  IDENTITY, 
    [strReasonCode] NVARCHAR(50) NOT NULL, 
    [strType] NVARCHAR(50) NOT NULL, 
    [strDescription] NVARCHAR(50) NULL, 
    [strLotTransactionType] NVARCHAR(50) NULL, 
    [ysnDefault] BIT NULL DEFAULT ((0)), 
    [ysnReduceAvailableTime] BIT NULL DEFAULT ((0)), 
    [ysnExplanationRequired] BIT NULL DEFAULT ((0)), 
	[strLastUpdatedBy] NVARCHAR(50) NOT NULL,
	[dtmLastUpdatedOn] DATETIME NOT NULL,
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICReasonCode] PRIMARY KEY ([intReasonCodeId]), 
    CONSTRAINT [AK_tblICReasonCode_strReasonCode] UNIQUE ([strReasonCode])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICReasonCode',
    @level2type = N'COLUMN',
    @level2name = N'intReasonCodeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reason Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICReasonCode',
    @level2type = N'COLUMN',
    @level2name = N'strReasonCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICReasonCode',
    @level2type = N'COLUMN',
    @level2name = N'strType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICReasonCode',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Lot Transaction Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICReasonCode',
    @level2type = N'COLUMN',
    @level2name = N'strLotTransactionType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICReasonCode',
    @level2type = N'COLUMN',
    @level2name = N'ysnDefault'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reduce Available Time',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICReasonCode',
    @level2type = N'COLUMN',
    @level2name = N'ysnReduceAvailableTime'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Explanation Required',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICReasonCode',
    @level2type = N'COLUMN',
    @level2name = N'ysnExplanationRequired'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICReasonCode',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Updated By',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICReasonCode',
    @level2type = N'COLUMN',
    @level2name = N'strLastUpdatedBy'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Updated On',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICReasonCode',
    @level2type = N'COLUMN',
    @level2name = N'dtmLastUpdatedOn'