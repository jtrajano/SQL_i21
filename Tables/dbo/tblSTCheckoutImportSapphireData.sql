CREATE TABLE [dbo].[tblSTCheckoutImportSapphireData]
(
	[intSapphireDataId] INT NOT NULL IDENTITY, 
    [intCheckoutId] INT NULL, 
    [intPeriod] INT NULL, 
    [intSet] INT NULL, 
    [dtmPollDate] DATETIME NULL, 
    [strHHMM] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strAP] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSTCheckoutImportSapphireData] PRIMARY KEY ([intSapphireDataId]), 
    CONSTRAINT [FK_tblSTCheckoutHeader_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId])  ON DELETE CASCADE
)
