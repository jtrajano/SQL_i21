CREATE TABLE tblLGFreightRateMatrix (
	 [intFreightRateMatrixId] INT IDENTITY PRIMARY KEY,
	 [intEntityId] INT,
	 [strServiceContractNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	 [dtmDate] DATETIME,
	 [dtmValidFrom] DATETIME,
	 [dtmValidTo] DATETIME,
	 [strOriginPort] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	 [strDestinationCity] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	 [dblBasicCost] NUMERIC(18, 6),
	 [intCurrencyId] INT,
	 [intContainerTypeId] INT,
	 [dblFuelCost] NUMERIC(18, 6),
	 [dblAdditionalCost] NUMERIC(18, 6),
	 [dblTerminalHandlingCharges] NUMERIC(18, 6),
	 [dblDestinationDeliveryCharges] NUMERIC(18, 6),
	 [dblTotalCostPerContainer] NUMERIC(18, 6),
	 [intConcurrencyId] INT NOT NULL DEFAULT 0
	)