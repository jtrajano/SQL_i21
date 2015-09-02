CREATE TABLE [dbo].[tblCTSequenceUsageHistory]
(
	intSequenceUsageHistoryId INT IDENTITY,
	intContractDetailId INT NOT NULL,
	strScreenName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	intExternalId INT NOT NULL,
	
	strFieldName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	dblOldValue NUMERIC(12, 4)NOT NULL,
	dblTransactionQuantity NUMERIC(12, 4) NOT NULL,
	dblNewValue NUMERIC(12, 4)NOT NULL,
	
	intUserId INT NOT NULL,
	dtmTransactionDate DATETIME NOT NULL,

    CONSTRAINT [PK_tblCTSequenceUsageHistory_intSequenceUsageHistoryId] PRIMARY KEY CLUSTERED ([intSequenceUsageHistoryId] ASC), 
	CONSTRAINT [FK_tblCTSequenceUsageHistory_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]) ON DELETE CASCADE
)
