CREATE TABLE [dbo].[tblRKElectronicPricingHistory]
(
	[intElectronicPricingHistoryId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
    [strSymbol] NVARCHAR(5) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strExchange] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strMonthCode] NVARCHAR(1) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intOptionYear] INT NOT NULL, 
    [dtmHistoryDateTime] DATETIME NULL, 
    [dblOpenPrice] NUMERIC(18, 6) NOT NULL, 
    [dblLowPrice] NUMERIC(18, 6) NOT NULL, 
    [dblHighPrice] NUMERIC(18, 6) NOT NULL, 
    [dblClosePrice] NUMERIC(18, 6) NOT NULL, 
    [dblLastPrice] NUMERIC(18, 6) NOT NULL, 
    CONSTRAINT [PK_tblRKElectronicPricingHistory_intElectronicPricingHistoryId] PRIMARY KEY ([intElectronicPricingHistoryId]) 
)
