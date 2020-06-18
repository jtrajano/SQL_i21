CREATE TABLE [dbo].[tblCTMiscellaneous]
(
	[intMiscellaneousId] INT IDENTITY(1,1) NOT NULL,
	[ysnContractBalanceInProgress] BIT NOT NULL DEFAULT 0,
	[ysnDestinationWeightsAndGradesFixed] BIT NOT NULL DEFAULT 0
)