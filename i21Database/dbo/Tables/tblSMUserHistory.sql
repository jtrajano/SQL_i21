CREATE TABLE [dbo].[tblSMUserHistory] (
    [intUserHistoryId]   INT              IDENTITY (1, 1) NOT NULL,
    [strActionType]		 NVARCHAR(100)    COLLATE Latin1_General_CI_AS NULL,
	[strTransactionType] NVARCHAR(100)	  COLLATE Latin1_General_CI_AS NULL, 
	[strRecordNo]		 NVARCHAR(50)	  COLLATE Latin1_General_CI_AS NULL, 
	[strDescription]	 NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NULL,
    [dtmDate]			 DATETIME         NOT NULL,
    [intEntityId]        INT              NULL,
    [intConcurrencyId]   INT              NOT NULL,
    CONSTRAINT [FK_dbo.tblSMUserHistory_dbo.tblEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId]),
    CONSTRAINT [PK_dbo.tblSMUserHistory] PRIMARY KEY CLUSTERED ([intUserHistoryId] ASC)
);







