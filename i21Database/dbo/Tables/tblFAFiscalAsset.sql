--Filled when asset is created or depreciated first time
-- this will be used for fiscal closing validation
CREATE TABLE tblFAFiscalAsset
(
	intFiscalAssetId INT IDENTITY(1,1),
	intAssetId INT,
	intBookId INT,
	intBookDepreciationId INT NULL,
	intFiscalPeriodId INT,
	intFiscalYearId INT,
    CONSTRAINT [PK_tblFAFiscalAsset] PRIMARY KEY CLUSTERED ([intFiscalAssetId] ASC),
)
GO