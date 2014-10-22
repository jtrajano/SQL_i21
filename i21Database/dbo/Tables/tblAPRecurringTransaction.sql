CREATE TABLE [dbo].[tblAPRecurringTransaction] (
    [intRecurringId]   INT           IDENTITY (1, 1) NOT NULL,
    [intTransactionId] INT           NOT NULL,
	[intTransactionType] INT           NOT NULL,
    [strFrequency]     NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [dtmLastProcess]   DATETIME      NULL,
    [dtmNextProcess]   DATETIME      NULL,
    [dtmStartDate]     DATETIME      NULL,
    [dtmEndDate]       DATETIME      NULL,
    [ysnActive]        BIT           NULL,
    [ysnDue]           BIT           NULL,
    [intGroupId]       INT           NULL,
    [intDayofMonth]    INT           NULL,
	[intEntityId]		INT			NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    PRIMARY KEY CLUSTERED ([intRecurringId] ASC)
);

