CREATE TYPE StagingTransactionLogFuelComputation AS TABLE
(
	[intRowCount] INT NULL,
	[intProductNumber] INT NOT NULL,
	[dblPrice] DECIMAL(18,2) NOT NULL,
	[dblDollarsSold] DECIMAL(18, 2) NOT NULL,
	[dblGallonsSold] DECIMAL(18, 3) NOT NULL
)