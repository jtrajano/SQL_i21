﻿CREATE TABLE [dbo].[tblSCDistributionOption]
(
	[intDistributionOptionId] INT NOT NULL IDENTITY, 
    [strDistributionOption] NVARCHAR(3) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intTicketPoolId] INT NOT NULL, 
    [intTicketTypeId] INT NOT NULL, 
    [ysnDistributionAllowed] BIT NOT NULL,
	[ysnDefaultDistribution] BIT NOT NULL, 
	[intStorageScheduleTypeId] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblSCDistributionOption_intDistributionOptionId] PRIMARY KEY ([intDistributionOptionId]), 
    CONSTRAINT [FK_tblSCDistributionOption_tblSCTicketPool_intTicketPoolId] FOREIGN KEY (intTicketPoolId) REFERENCES tblSCTicketPool(intTicketPoolId), 
    CONSTRAINT [FK_tblSCDistributionOption_tblSCTicketType_intTicketTypeId] FOREIGN KEY (intTicketTypeId) REFERENCES tblSCTicketType(intTicketTypeId), 
	CONSTRAINT [FK_tblSCDistributionOption_tblGRStorageType_intStorageScheduleTypeId] FOREIGN KEY (intStorageScheduleTypeId) REFERENCES tblGRStorageType(intStorageScheduleTypeId), 
    CONSTRAINT [UK_tblSCDistributionOption_intTicketPoolId] UNIQUE ([intTicketPoolId],[intTicketTypeId],[strDistributionOption]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDistributionOption',
    @level2type = N'COLUMN',
    @level2name = N'intDistributionOptionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Distribution Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDistributionOption',
    @level2type = N'COLUMN',
    @level2name = 'strDistributionOption'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Pool ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDistributionOption',
    @level2type = N'COLUMN',
    @level2name = N'intTicketPoolId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDistributionOption',
    @level2type = N'COLUMN',
    @level2name = N'intTicketTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Distribution Allowed',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDistributionOption',
    @level2type = N'COLUMN',
    @level2name = N'ysnDistributionAllowed'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDistributionOption',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Distribution',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDistributionOption',
    @level2type = N'COLUMN',
    @level2name = N'ysnDefaultDistribution'