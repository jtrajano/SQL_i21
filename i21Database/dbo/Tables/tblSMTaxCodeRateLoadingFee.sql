CREATE TABLE [dbo].[tblSMTaxCodeRateLoadingFee]
(
	[intTaxCodeRateLoadingFeeId]	INT NOT NULL PRIMARY KEY IDENTITY, 
    [intTaxCodeRateId]				INT NOT NULL, 
    [dblTotalGalsFrom]				NUMERIC(18, 6) NULL, 
    [dblTotalGalsTo]				NUMERIC(18, 6) NULL, 
	[dblGasolineGalsFrom]           NUMERIC(18, 6) NULL, 
    [dblGasolineGalsTo]             NUMERIC(18, 6) NULL,
    [dblFeeAmount]                  NUMERIC(18, 6) NOT NULL,
    [dblIncrementalGals]            NUMERIC(18, 6) NULL,
    [dblIncrementalAmount]          NUMERIC(18, 6) NULL,
    
	[intConcurrencyId]              INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMTaxCodeRateLoadingFee_tblSMTaxCodeRate] FOREIGN KEY ([intTaxCodeRateId]) REFERENCES [tblSMTaxCodeRate]([intTaxCodeRateId]) ON DELETE CASCADE
)
