CREATE TABLE [dbo].[tblSTCheckoutProcess]
(
	[intCheckoutProcessId]		INT NOT NULL IDENTITY, 
	[intCheckoutId]				INT NOT NULL,
    [dtmCheckoutProcessDate]	DATETIME NOT NULL,
    [strGuid]					NVARCHAR(50) NOT NULL,
    [intConcurrencyId]			INT NOT NULL, 
    CONSTRAINT [PK_tblSTCheckoutProcess_intCheckoutProcessId] PRIMARY KEY ([intCheckoutProcessId]), 
    CONSTRAINT [FK_tblSTCheckoutProcess_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) ON DELETE CASCADE,
)