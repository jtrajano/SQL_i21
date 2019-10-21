CREATE TABLE [dbo].[tblCTContractCondition]
(
	[intContractConditionId] INT IDENTITY(1,1) NOT NULL, 
    [intContractHeaderId] INT NOT NULL, 
    [intConditionId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL,
	CONSTRAINT [PK_tblCTContractCondition_intContractConditionId] PRIMARY KEY CLUSTERED ([intContractConditionId] ASC),
	CONSTRAINT [UQ_tblCTContractCondition_intContractHeaderId_intConditionId] UNIQUE ([intContractHeaderId], [intConditionId]), 
	CONSTRAINT [FK_tblCTContractCondition_tblCTContractHeader_intContractHeaderId] FOREIGN KEY ([intContractHeaderId]) REFERENCES [tblCTContractHeader]([intContractHeaderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblCTContractCondition_tblCTCondition_intConditionId] FOREIGN KEY ([intConditionId]) REFERENCES [tblCTCondition]([intConditionId]) 
)
