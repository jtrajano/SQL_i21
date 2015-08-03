CREATE TABLE [dbo].[tblRKAssignFuturesToContractSummaryHeader]
(
	[intAssignFuturesToContractHeaderId] INT IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] INT NOT NULL, 
	CONSTRAINT [PK_tblRKAssignFuturesToContractSummaryHeader_intAssignFuturesToContractHeaderId] PRIMARY KEY (intAssignFuturesToContractHeaderId)
)
