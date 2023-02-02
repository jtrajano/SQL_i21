CREATE TABLE [dbo].[tblSTCheckoutProcess]
(
	[intCheckoutProcessId]		INT NOT NULL IDENTITY, 
	[intCheckoutId]				INT NULL,
    [intStoreId]                INT NOT NULL,
    [dtmCheckoutProcessDate]	DATETIME NOT NULL,
    [strGuid]					NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnConsFinishedProcessing] BIT NOT NULL DEFAULT 0,
    [intConcurrencyId]			INT NOT NULL, 
    CONSTRAINT [PK_tblSTCheckoutProcess_intCheckoutProcessId] PRIMARY KEY ([intCheckoutProcessId]), 
    CONSTRAINT [FK_tblSTCheckoutProcess_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblSTCheckoutProcess_tblSTStore] FOREIGN KEY ([intStoreId]) REFERENCES [tblSTStore]([intStoreId]) ON DELETE CASCADE,
)