CREATE TABLE [dbo].[tblAPRecurringHistory]
(
	[intRecurringHistoryId] INT NOT NULL PRIMARY KEY, 
    [strTransactionId] NVARCHAR(100) NOT NULL, 
    [strTransactionCreated] NVARCHAR(100) NOT NULL, 
    [dtmDateProcessed] DATETIME NOT NULL, 
    [strReference] NVARCHAR(500) NULL, 
    [dtmNextProcess] DATETIME NOT NULL, 
    [dtmLastProcess] DATETIME NOT NULL, 
    [intTransactionType] INT NOT NULL
)
