CREATE TABLE [dbo].[tblCTSequenceUsageHistory]
(
	intSequenceUsageHistoryId INT IDENTITY,
	intContractDetailId INT NOT NULL,
	strScreenName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	intExternalId INT NOT NULL,
	
	strFieldName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	dblOldValue NUMERIC(18, 6)NOT NULL,
	dblTransactionQuantity NUMERIC(18, 6) NOT NULL,
	dblNewValue NUMERIC(18, 6)NOT NULL,
	dblBalance  NUMERIC(18, 6) NULL,
	
	intUserId INT NOT NULL,
	dtmTransactionDate DATETIME NOT NULL,

	intExternalHeaderId INT NULL, 
    intContractHeaderId INT NULL, 
	intContractSeq INT NULL,
	strNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strUserName NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	strReason NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,

    CONSTRAINT [PK_tblCTSequenceUsageHistory_intSequenceUsageHistoryId] PRIMARY KEY CLUSTERED ([intSequenceUsageHistoryId] ASC), 
	CONSTRAINT [FK_tblCTSequenceUsageHistory_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]) ON DELETE CASCADE
)
GO

CREATE NONCLUSTERED INDEX [IX_tblCTSequenceUsageHistory] ON [dbo].[tblCTSequenceUsageHistory]
(
	[intContractHeaderId] ASC,
	[intContractDetailId] ASC,
	[strScreenName] ASC,
	[intExternalId] ASC,
	[strFieldName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
		
GO

CREATE NONCLUSTERED INDEX [IX_tblCTSequenceUsageHistory_intExternalId] ON [dbo].[tblCTSequenceUsageHistory] ([intExternalId], [strScreenName])

GO

CREATE NONCLUSTERED INDEX [IX_tblCTSequenceUsageHistory_intContractDetailId] ON [dbo].[tblCTSequenceUsageHistory] ([intContractDetailId])

GO