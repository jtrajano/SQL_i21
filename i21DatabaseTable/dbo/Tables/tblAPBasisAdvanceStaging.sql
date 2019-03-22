CREATE TABLE [dbo].[tblAPBasisAdvanceStaging]
(
	[intBasisAdvanceStagingId] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
	[intBasisAdvanceDummyHeaderId] INT NOT NULL,
	[intTicketId] INT NOT NULL,
	[intContractDetailId] INT NOT NULL,
	[intConcurrencyId] INT DEFAULT(0) NOT NULL
)
