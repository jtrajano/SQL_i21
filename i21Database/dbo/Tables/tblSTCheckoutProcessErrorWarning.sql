CREATE TABLE [dbo].[tblSTCheckoutProcessErrorWarning]
(
	[intCheckoutProcessErrorWarningId]	INT NOT NULL IDENTITY, 
	[intCheckoutProcessId]				INT NOT NULL,
	[strMessageType]					NVARCHAR(1) NOT NULL,
    [strMessage]						NVARCHAR(500) NOT NULL,
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSTCheckoutProcessErrorWarning_intCheckoutProcessErrorWarningId] PRIMARY KEY ([intCheckoutProcessErrorWarningId]), 
    CONSTRAINT [FK_tblSTCheckoutProcessErrorWarning_tblSTCheckoutProcess] FOREIGN KEY ([intCheckoutProcessId]) REFERENCES [tblSTCheckoutProcess]([intCheckoutProcessId]) ON DELETE CASCADE
)