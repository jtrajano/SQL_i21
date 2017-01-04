CREATE TABLE tblETImportBaseEngineering(
	[intImportBaseEngineeringId] INT IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 0,
	[intRecordId] INT NOT NULL ,
    [strCustomerNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL , 
    [strSiteNumber] NVARCHAR(5) COLLATE Latin1_General_CI_AS  NULL , 
	[dblPercentFullAfterDelivery] NUMERIC(18, 6) NULL, 
	[strLocation] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL, 
	[strItemNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL, 
    [dtmDate] DATETIME NULL, 
	[intTaxGroupId] INT NULL, 
	[dblQuantity] NUMERIC(18, 6) NULL, 
	[dblPrice] NUMERIC(18, 6) NULL, 
	[dblTaxCategory1] NUMERIC(18, 6) NULL, 
	[dblTaxCategory2] NUMERIC(18, 6) NULL, 
	[dblTaxCategory3] NUMERIC(18, 6) NULL, 
	[dblTaxCategory4] NUMERIC(18, 6) NULL, 
	[dblTaxCategory5] NUMERIC(18, 6) NULL, 
	[dblTaxCategory6] NUMERIC(18, 6) NULL, 
	[dblTaxCategory7] NUMERIC(18, 6) NULL, 
	[dblTaxCategory8] NUMERIC(18, 6) NULL, 
	[dblTaxCategory9] NUMERIC(18, 6) NULL, 
	[dblTaxCategory10] NUMERIC(18, 6) NULL, 
	[dblTaxCategory11] NUMERIC(18, 6) NULL, 
	[dblTaxCategory12] NUMERIC(18, 6) NULL, 
	[dblTaxCategory13] NUMERIC(18, 6) NULL, 
	[dblTaxCategory14] NUMERIC(18, 6) NULL, 
	[dblTaxCategory15] NUMERIC(18, 6) NULL, 
	[dblTaxCategory16] NUMERIC(18, 6) NULL, 
	[dblTaxCategory17] NUMERIC(18, 6) NULL, 
	[dblTaxCategory18] NUMERIC(18, 6) NULL, 
	[dblTaxCategory19] NUMERIC(18, 6) NULL, 
	[dblTaxCategory20] NUMERIC(18, 6) NULL, 
	[dblTaxCategory21] NUMERIC(18, 6) NULL, 
	[dblTaxCategory22] NUMERIC(18, 6) NULL, 
	[dblTaxCategory23] NUMERIC(18, 6) NULL, 
	[dblTaxCategory24] NUMERIC(18, 6) NULL, 
	[dblTaxCategory25] NUMERIC(18, 6) NULL, 
	[dblTaxCategory26] NUMERIC(18, 6) NULL, 
	[dblTaxCategory27] NUMERIC(18, 6) NULL, 
	[dblTaxCategory28] NUMERIC(18, 6) NULL, 
	[dblTaxCategory29] NUMERIC(18, 6) NULL, 
	[dblTaxCategory30] NUMERIC(18, 6) NULL, 
    [dtmDateSession] DATETIME NOT NULL, 
    [ysnProcessed] BIT NOT NULL DEFAULT 0, 
    [strInvoiceNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dblPrebuyPrice] NUMERIC(18, 6) NULL DEFAULT 0, 
    [dblPrebuyQuantity] NUMERIC(18, 6) NULL DEFAULT 0, 
    [dblContractPrice] NUMERIC(18, 6) NULL DEFAULT 0, 
    [dblContractQuantity] NUMERIC(18, 6) NULL DEFAULT 0, 
    CONSTRAINT [PK_tblETImportBaseEngineering] PRIMARY KEY ([intImportBaseEngineeringId]),
)
GO

CREATE INDEX [IX_tblETImportBaseEngineering_strCustomerNumber] ON [dbo].[tblETImportBaseEngineering] ([strCustomerNumber])


GO

CREATE INDEX [IX_tblETImportBaseEngineering_strSiteNumber] ON [dbo].[tblETImportBaseEngineering] ([strSiteNumber])

GO

CREATE INDEX [IX_tblETImportBaseEngineering_dtmDateSession] ON [dbo].[tblETImportBaseEngineering] ([dtmDateSession] DESC)
