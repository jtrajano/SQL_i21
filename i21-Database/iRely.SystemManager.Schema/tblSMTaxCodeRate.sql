CREATE TABLE [dbo].[tblSMTaxCodeRate]
(
	[intTaxCodeRateId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intTaxCodeId] INT NOT NULL, 
    [strCalculationMethod] NVARCHAR(15) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intUnitMeasureId] INT NULL, 
    [dblRate] NUMERIC(18, 6) NOT NULL, 
    [dtmEffectiveDate] DATETIME NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMTaxCodeRate_tblICUnitMeasure] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])
	--, 
	--CONSTRAINT [AK_tblSMTaxGroupCode_intTaxCodeId_dtmEffectiveDate_strCalculationMethod_intUnitMeasureId] CHECK (NOT(dbo.fnSMUniqueEffectiveMethodUOM([intTaxCodeId],[dtmEffectiveDate],[strCalculationMethod],[intUnitMeasureId]) > 1))
)
