CREATE TABLE [dbo].[tblCTContractReleaseInstruction]
(
	intContractReleaseInstructionId INT NOT NULL IDENTITY,
    intContractDetailId INT NOT NULL,
	strReleaseNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dtmDate DATETIME NOT NULL,
	dblQuantity NUMERIC(38, 20) NOT NULL,
	intItemUOMId INT NOT NULL,
	strNotes NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	strConditions NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
    intConcurrencyId INT NULL,
    CONSTRAINT [PK_tblCTContractReleaseInstruction_intContractReleaseInstructionId] PRIMARY KEY CLUSTERED (intContractReleaseInstructionId ASC), 
    CONSTRAINT [FK_tblCTContractReleaseInstruction_tblCTContractDetail_intContractDetailId] FOREIGN KEY (intContractDetailId) REFERENCES tblCTContractDetail(intContractDetailId) ON DELETE CASCADE
)
