CREATE TABLE [dbo].[tblSTCheckoutFuelReport]
(
	[intCheckoutFuelReportId]		INT NOT NULL IDENTITY, 
	[intCheckoutId]				    INT NULL,
    [intStoreId]                    INT NOT NULL,
    [strTierProductSavedFileName]   NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL,
    [strTierProductFileContent]     NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]			    INT NOT NULL, 
    CONSTRAINT [PK_tblSTCheckoutFuelReport_intCheckoutFuelReportId] PRIMARY KEY ([intCheckoutFuelReportId]), 
    CONSTRAINT [FK_tblSTCheckoutFuelReport_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblSTCheckoutFuelReport_tblSTStore] FOREIGN KEY ([intStoreId]) REFERENCES [tblSTStore]([intStoreId]) ON DELETE CASCADE,
)