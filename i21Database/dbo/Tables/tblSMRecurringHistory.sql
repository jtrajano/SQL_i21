CREATE TABLE [dbo].[tblSMRecurringHistory]
(
	[intRecurringHistoryId] INT IDENTITY (1, 1) NOT NULL, 
    [strTransactionNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strTransactionCreated] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
    [dtmDateProcessed] DATETIME NOT NULL, 
    [strReference] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL, 
    [dtmNextProcess] DATETIME NOT NULL, 
    [dtmLastProcess] DATETIME NOT NULL, 
    [intTransactionTypeId] INT NOT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT 0, 
    PRIMARY KEY CLUSTERED ([intRecurringHistoryId] ASC),
)

