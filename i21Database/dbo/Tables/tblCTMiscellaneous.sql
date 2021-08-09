﻿CREATE TABLE [dbo].[tblCTMiscellaneous]
(
	[intMiscellaneousId] INT IDENTITY(1,1) NOT NULL,
	[ysnContractBalanceInProgress] BIT NOT NULL DEFAULT 0,
	[ysnDestinationWeightsAndGradesFixed] BIT NOT NULL DEFAULT 0,
	[ysnFixedSMTransactionWithWrongPricingScreenId] BIT NOT NULL DEFAULT 0,
	[ysnContractPriceContractInProgress] BIT NOT NULL DEFAULT 0,
	[ysnFixedPriceAndInvoiceLink] BIT NOT NULL DEFAULT 0
)