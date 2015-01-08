CREATE TABLE [dbo].[tblSCTicketPrintOption]
(
	[intTicketPrintOptionId] INT NOT NULL IDENTITY, 
    [intScaleSetupId] INT NOT NULL, 
    [intTicketFormatId] INT NOT NULL, 
    [strTicketPrintDescription] NVARCHAR(20) NOT NULL, 
    [ysnPrintEachSplit] BIT NOT NULL, 
    [intTicketPrintCopies] INT NOT NULL, 
    [intIssueCutCode] INT NOT NULL, 
    [strTicketPrinter] NVARCHAR(162) NULL, 
	[intTicketTypeOption] INT NOT NULL,
	[strInOutIndicator] NVARCHAR(1) NOT NULL,
	[intPrintingOption] INT NOT NULL,
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSCTicketPrintOption_intTicketPrintOptionId] PRIMARY KEY ([intTicketPrintOptionId]), 
    CONSTRAINT [FK_tblSCTicketPrintOption_tblSCScaleSetup_intScaleSetupId] FOREIGN KEY ([intScaleSetupId]) REFERENCES [tblSCScaleSetup]([intScaleSetupId]), 
    CONSTRAINT [FK_tblSCTicketPrintOption_tblSCTicketFormat_intTicketFormatId] FOREIGN KEY ([intTicketFormatId]) REFERENCES [tblSCTicketFormat]([intTicketFormatId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketPrintOption',
    @level2type = N'COLUMN',
    @level2name = N'intTicketPrintOptionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Scale Setup ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketPrintOption',
    @level2type = N'COLUMN',
    @level2name = N'intScaleSetupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Format ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketPrintOption',
    @level2type = N'COLUMN',
    @level2name = N'intTicketFormatId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Print Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketPrintOption',
    @level2type = N'COLUMN',
    @level2name = N'strTicketPrintDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Print Each Split',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketPrintOption',
    @level2type = N'COLUMN',
    @level2name = N'ysnPrintEachSplit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Print Copies',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketPrintOption',
    @level2type = N'COLUMN',
    @level2name = N'intTicketPrintCopies'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Issue Cut Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketPrintOption',
    @level2type = N'COLUMN',
    @level2name = N'intIssueCutCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Printer',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketPrintOption',
    @level2type = N'COLUMN',
    @level2name = N'strTicketPrinter'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketPrintOption',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Type Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketPrintOption',
    @level2type = N'COLUMN',
    @level2name = N'intTicketTypeOption'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'In Out Indicator',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketPrintOption',
    @level2type = N'COLUMN',
    @level2name = N'strInOutIndicator'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Printing Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketPrintOption',
    @level2type = N'COLUMN',
    @level2name = N'intPrintingOption'