CREATE TABLE [dbo].[tblSCTicketEmailOption]
(
	[intTicketEmailOptionId] INT NOT NULL IDENTITY, 
    [intScaleSetupId] INT NOT NULL, 
	[strEmailSubject] NVARCHAR(250) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strEmailBody] NVARCHAR(250) COLLATE Latin1_General_CI_AS NOT NULL, 
	[ysnEnabledEmailOption] BIT NOT NULL, 
	[ysnEmailEachSplit] BIT NOT NULL, 
    [intConcurrencyId] INT NULL,
    CONSTRAINT [PK_tblSCTicketEmailOption_intTicketEmailOptionId] PRIMARY KEY ([intTicketEmailOptionId]), 
    CONSTRAINT [FK_tblSCTicketEmailOption_tblSCScaleSetup_intScaleSetupId] FOREIGN KEY ([intScaleSetupId]) REFERENCES [tblSCScaleSetup]([intScaleSetupId]), 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketEmailOption',
    @level2type = N'COLUMN',
    @level2name = N'intTicketEmailOptionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Scale Setup Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketEmailOption',
    @level2type = N'COLUMN',
    @level2name = N'intScaleSetupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Email Subject',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketEmailOption',
    @level2type = N'COLUMN',
    @level2name = N'strEmailSubject'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Email Body',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketEmailOption',
    @level2type = N'COLUMN',
    @level2name = N'strEmailBody'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Enabled Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketEmailOption',
    @level2type = N'COLUMN',
    @level2name = N'ysnEnabledEmailOption'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Email Each Split',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketEmailOption',
    @level2type = N'COLUMN',
    @level2name = N'ysnEmailEachSplit'