CREATE TABLE [dbo].[tblRKAssignFuturesToContractSummary]
(
	[intAssignFuturesToContractSummaryId]  INT IDENTITY(1,1) NOT NULL,
	[intAssignFuturesToContractHeaderId] int NOT NULL,
	[intConcurrencyId] INT NOT NULL,
	[intContractHeaderId] INT NOT NULL,
	[intContractDetailId] INT NOT NULL,	
	[dtmMatchDate] DATETIME NOT NULL, 
	[intFutOptTransactionId] INT NOT NULL,
    [intAssignedLots] INT NOT NULL, 
	[intHedgedLots] INT NOT NULL,
	[ysnIsHedged] Bit NULL,
    CONSTRAINT [PK_tblRKAssignFuturesToContractSummary] PRIMARY KEY (intAssignFuturesToContractSummaryId),
	CONSTRAINT [FK_tblRKAssignFuturesToContractSummary_tblRKAssignFuturesToContractSummaryHeader_intAssignFuturesToContractHeaderId] FOREIGN KEY ([intAssignFuturesToContractHeaderId]) REFERENCES [tblRKAssignFuturesToContractSummaryHeader]([intAssignFuturesToContractHeaderId]),	 
	CONSTRAINT [FK_tblRKAssignFuturesToContractSummary_tblCTContractHeader_intContractHeaderId] FOREIGN KEY ([intContractHeaderId]) REFERENCES [tblCTContractHeader]([intContractHeaderId]),	
    CONSTRAINT [FK_tblRKAssignFuturesToContractSummary_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]),
	CONSTRAINT [FK_tblRKAssignFuturesToContractSummary_tblRKFutOptTransaction_intFutOptTransactionId] FOREIGN KEY ([intFutOptTransactionId]) REFERENCES [tblRKFutOptTransaction]([intFutOptTransactionId]),
)