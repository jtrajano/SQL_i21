CREATE TABLE [dbo].[tblSMTerm] (
    [intTermID]        INT             IDENTITY (1, 1) NOT NULL,
    [strTerm]          NVARCHAR (100)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strType]          NVARCHAR (100)  COLLATE Latin1_General_CI_AS NOT NULL,
    [dblDiscountEP]    NUMERIC (18, 6) NULL,
    [intBalanceDue]    INT             NULL,
    [intDiscountDay]   INT             NULL,
    [dblAPR]           NUMERIC (18, 6) NULL,
    [strTermCode]      NVARCHAR (100)  COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnAllowEFT]      BIT             DEFAULT ((1)) NOT NULL,
    [intDayofMonthDue] INT             NULL,
    [intDueNextMonth]  INT             NULL,
	[dtmDiscountDate] DATETIME             NULL,
    [dtmDueDate]	DATETIME             NULL,
    [ysnActive]        BIT             DEFAULT ((1)) NOT NULL,
    [intSort]          INT             NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [PK_tblSMTerm] PRIMARY KEY CLUSTERED ([intTermID] ASC), 
    CONSTRAINT [AK_tblSMTerm_strTerm] UNIQUE ([strTerm]), 
    CONSTRAINT [AK_tblSMTerm_strTermCode] UNIQUE ([strTermCode])
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMTerm',
    @level2type = N'COLUMN',
    @level2name = N'intTermID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Term Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMTerm',
    @level2type = N'COLUMN',
    @level2name = N'strTerm'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Term Type. This could either be Stardard, Date Driven, or Specific Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMTerm',
    @level2type = N'COLUMN',
    @level2name = N'strType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount for Early Payment',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMTerm',
    @level2type = N'COLUMN',
    @level2name = N'dblDiscountEP'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Balance Due',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMTerm',
    @level2type = N'COLUMN',
    @level2name = N'intBalanceDue'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Days',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMTerm',
    @level2type = N'COLUMN',
    @level2name = N'intDiscountDay'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'APR for Late Payment',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMTerm',
    @level2type = N'COLUMN',
    @level2name = N'dblAPR'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Origin Term Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMTerm',
    @level2type = N'COLUMN',
    @level2name = N'strTermCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Allow EFT on Invoices',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMTerm',
    @level2type = N'COLUMN',
    @level2name = N'ysnAllowEFT'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Day of Month Due',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMTerm',
    @level2type = N'COLUMN',
    @level2name = N'intDayofMonthDue'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Due Next Month',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMTerm',
    @level2type = N'COLUMN',
    @level2name = N'intDueNextMonth'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMTerm',
    @level2type = N'COLUMN',
    @level2name = N'dtmDiscountDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Due Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMTerm',
    @level2type = N'COLUMN',
    @level2name = N'dtmDueDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Term is Active',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMTerm',
    @level2type = N'COLUMN',
    @level2name = N'ysnActive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMTerm',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMTerm',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'