CREATE TABLE [dbo].[tblAPBillBatch] (
    [intBillBatchId]     INT             IDENTITY (1, 1) NOT NULL,
    [intAccountId]       INT             NOT NULL,
    [ysnPosted]          BIT             DEFAULT ((0)) NULL,
	[dtmBatchDate]		DATETIME NULL ,
    [strBillBatchNumber] NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strReference]       NVARCHAR (200)   COLLATE Latin1_General_CI_AS NULL,
    [dblTotal]           DECIMAL (18, 2) NOT NULL,
    [intUserId] INT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    [intEntityId] INT NOT NULL, 
	[ysnDeleted] BIT NULL DEFAULT 0,
	[dtmDateDeleted] DATETIME NULL,
    [dtmDateCreated] DATETIME NULL DEFAULT GETDATE(), 
    CONSTRAINT [PK_dbo.tblAPBillBatches] PRIMARY KEY CLUSTERED ([intBillBatchId] ASC),
	CONSTRAINT [FK_dbo.tblAPBillBatch_dbo.tblEMEntity_intEntityId] FOREIGN KEY (intEntityId) REFERENCES tblEMEntity(intEntityId),
	CONSTRAINT [FK_dbo.tblAPBillBatch_dbo.tblGLAccount_intAccountId] FOREIGN KEY (intAccountId) REFERENCES tblGLAccount(intAccountId)
);

GO
CREATE INDEX [IX_tblAPBillBatch_strBillBatchNumber] ON [dbo].[tblAPBillBatch] ([strBillBatchNumber])
