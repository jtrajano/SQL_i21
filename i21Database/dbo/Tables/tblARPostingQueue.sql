CREATE TABLE [dbo].[tblARPostingQueue] (
    [intPostQueueId]        INT             IDENTITY (1, 1) NOT NULL,
    [intTransactionId]	    INT             NOT NULL,
    [strTransactionNumber]  NVARCHAR(100)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strBatchId]            NVARCHAR(100)   COLLATE Latin1_General_CI_AS NULL,
    [dtmPostingdate]        DATETIME        NULL,
    [intEntityId]           INT             NULL,
	[strTransactionType]	NVARCHAR(100)   COLLATE Latin1_General_CI_AS NOT NULL,

    CONSTRAINT [PK_tblARPostingQueue] PRIMARY KEY CLUSTERED ([intPostQueueId] ASC)	
);

