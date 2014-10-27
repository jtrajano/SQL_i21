CREATE TABLE [dbo].[tblAPRecurringTransaction] (
    [intRecurringId]   INT           IDENTITY (1, 1) NOT NULL,
    [intTransactionId] INT           NOT NULL,
	[intTransactionType] INT           NOT NULL,
    [intFrequencyId]     INT  NULL,
	[intIterations]     INT  NOT NULL DEFAULT 1,
	[strReference]		NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [dtmLastProcess]   DATETIME      NULL,
    [dtmNextProcess]   DATETIME      NULL,
    [dtmStartDate]     DATETIME      NULL,
    [dtmEndDate]       DATETIME      NULL,
    [ysnActive]        BIT           NULL,
	[ysnProcess]        BIT           NULL DEFAULT 0,
    [ysnDue]           BIT           NULL,
    [intGroupId]       INT           NULL,
    [intDayofMonth]    INT           NULL,
	[intEntityId]		INT			NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    PRIMARY KEY CLUSTERED ([intRecurringId] ASC),
	CONSTRAINT [FK_dbo.tblAPRecurringTransaction_dbo.tblEntity_intEntityId] FOREIGN KEY (intEntityId) REFERENCES tblEntity(intEntityId)
);

