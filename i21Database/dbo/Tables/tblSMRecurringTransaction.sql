CREATE TABLE [dbo].[tblSMRecurringTransaction]
(
    [intRecurringId] INT NOT NULL IDENTITY ,    
	[intTransactionId] INT NOT NULL , 
    [strTransactionNumber] NVARCHAR(50) NOT NULL, 
    [strTransactionType] NVARCHAR(50) NOT NULL, 
    [strReference] NVARCHAR(50) NULL, 
    [strFrequency] NVARCHAR(50) NOT NULL, 
    [dtmLastProcess] DATETIME NOT NULL, 
    [dtmNextProcess] DATETIME NOT NULL, 
    [ysnDue] BIT NOT NULL, 
    [strRecurringGroup] NVARCHAR(50) NULL, 
    [strDayOfMonth] NVARCHAR(50) NULL, 
    [dtmStartDate] DATETIME NOT NULL, 
    [dtmEndDate] DATETIME NOT NULL, 
    [ysnActive] BIT NOT NULL, 
    [intIteration] INT NOT NULL, 
    [intUserId] INT NOT NULL , 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_tblSMRecurringTransaction] PRIMARY KEY ([intRecurringId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMRecurringTransaction',
    @level2type = N'COLUMN',
    @level2name = 'intRecurringId'