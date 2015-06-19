CREATE TABLE [dbo].[tblSMTaxCodeRate]
(
	[intTaxCodeRateId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intTaxCodeId] INT NOT NULL, 
    [strCalculationMethod] NVARCHAR(15) COLLATE Latin1_General_CI_AS NOT NULL, 
    [numRate] NUMERIC(18, 6) NOT NULL, 
    [dtmEffectiveDate] DATETIME NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1
)
