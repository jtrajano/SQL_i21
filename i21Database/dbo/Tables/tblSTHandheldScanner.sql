CREATE TABLE [dbo].[tblSTHandheldScanner]
(
	[intHandheldScannerId] INT NOT NULL IDENTITY, 
    [intStoreId] INT NOT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblSTHandheldScanner] PRIMARY KEY ([intHandheldScannerId]), 
    CONSTRAINT [FK_tblSTHandheldScanner_tblSTStore] FOREIGN KEY ([intStoreId]) REFERENCES [tblSTStore]([intStoreId])
)
