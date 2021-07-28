CREATE TABLE [dbo].[tblSMLog] (
    [intLogId]			 INT              IDENTITY (1, 1) NOT NULL,
    [strType]		     NVARCHAR(100)    COLLATE Latin1_General_CI_AS NULL,
    [dtmDate]			 DATETIME         NOT NULL,
    [intEntityId]        INT              NULL,
	[strEntityName]	     NVARCHAR(500)    COLLATE Latin1_General_CI_AS NULL,
	[strCustomerName]    NVARCHAR(500)    COLLATE Latin1_General_CI_AS NULL,
    [intOriginalScreenId]	INT				NULL,
	[intTransactionId]	 INT			  NULL,
	[strRoute]			 NVARCHAR(MAX)	  NULL,
    [intConcurrencyId]   INT              NOT NULL,
	CONSTRAINT [FK_dbo.tblSMLog_tblSMTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [tblSMTransaction]([intTransactionId]) ON DELETE CASCADE,
    --CONSTRAINT [FK_dbo.tblSMLog_dbo.tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]),
    CONSTRAINT [PK_dbo.tblSMLog] PRIMARY KEY CLUSTERED ([intLogId] ASC)
);

GO
CREATE NONCLUSTERED INDEX [IX_tblSMLog_intLogId] ON [dbo].[tblSMLog] ([intTransactionId])
GO

GO
CREATE NONCLUSTERED INDEX [IX_tblSMLog_1] ON [dbo].[tblSMLog] ([dtmDate]) include ([intTransactionId])
GO

