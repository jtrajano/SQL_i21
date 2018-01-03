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
