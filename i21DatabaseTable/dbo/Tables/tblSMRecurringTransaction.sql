CREATE TABLE [dbo].[tblSMRecurringTransaction]
(
    [intRecurringId] INT NOT NULL IDENTITY ,    
	[intTransactionId] INT NOT NULL , 
    [strTransactionNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strTransactionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strReference] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL, 
	[strResponsibleUser] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT '', 
	[intEntityId] INT NOT NULL DEFAULT 0, 
	[intWarningDays] INT NULL  , 
    [strFrequency] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [dtmLastProcess] DATETIME NOT NULL, 
    [dtmNextProcess] DATETIME NOT NULL, 
    [ysnDue] BIT NOT NULL, 
    [strRecurringGroup] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strDayOfMonth] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dtmStartDate] DATETIME NOT NULL, 
    [dtmEndDate] DATETIME NOT NULL, 
    [ysnActive] BIT NOT NULL, 
    [intIteration] INT NOT NULL, 
    [intUserId] INT NULL , 
    [ysnAvailable] BIT NOT NULL DEFAULT 1, 
	[dtmPreviousLastProcess] DATETIME NULL, 
    [dtmPreviousNextProcess] DATETIME NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_tblSMRecurringTransaction] PRIMARY KEY ([intRecurringId]), 
    CONSTRAINT [AK_tblSMRecurringTransaction_strTransactionNumber] UNIQUE ([strTransactionNumber], [intTransactionId]), 
    CONSTRAINT [FK_tblSMRecurringTransaction_tblSMUserSecurity] FOREIGN KEY ([intUserId]) REFERENCES [tblSMUserSecurity]([intEntityId]) 
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