﻿CREATE TABLE [dbo].[tblSMCurrencyExchangeRateDetail]
(
	[intCurrencyExchangeRateDetailId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intCurrencyExchangeRateId] INT NOT NULL, 
    [dblRate] NUMERIC(38, 20) NOT NULL, 
    [intRateTypeId] INT NOT NULL, 
    [dtmValidFromDate] DATETIME NOT NULL, 
	[strSource] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
	[dtmCreatedDate] DATETIME NULL, 
	[dtmCreatedDateUTC] DATETIME NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMCurrencyExchangeRateDetail_tblSMCurrencyExchangeRate] FOREIGN KEY (intCurrencyExchangeRateId) REFERENCES tblSMCurrencyExchangeRate(intCurrencyExchangeRateId) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblSMCurrencyExchangeRateDetail_tblSMCurrencyExchangeRateType] FOREIGN KEY (intRateTypeId) REFERENCES tblSMCurrencyExchangeRateType(intCurrencyExchangeRateTypeId), 
    CONSTRAINT [AK_tblSMCurrencyExchangeRateDetail_CurrencyExchangeRateTypeValidFromDate] UNIQUE ([intCurrencyExchangeRateId], [intRateTypeId], [dtmValidFromDate])
)