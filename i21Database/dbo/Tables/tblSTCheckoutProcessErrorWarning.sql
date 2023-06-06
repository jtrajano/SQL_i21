CREATE TABLE [dbo].[tblSTCheckoutProcessErrorWarning]
(
	[intCheckoutProcessErrorWarningId]	INT NOT NULL IDENTITY, 
	[intCheckoutProcessId]				INT NOT NULL,
    [intCheckoutId]				        INT NULL,
	[strMessageType]					NVARCHAR(1) COLLATE Latin1_General_CI_AS NOT NULL,
    [strMessage]						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSTCheckoutProcessErrorWarning_intCheckoutProcessErrorWarningId] PRIMARY KEY ([intCheckoutProcessErrorWarningId]),
    CONSTRAINT [FK_tblSTCheckoutProcessErrorWarning_tblSTCheckoutProcess] FOREIGN KEY ([intCheckoutProcessId]) REFERENCES [tblSTCheckoutProcess]([intCheckoutProcessId]) ON DELETE CASCADE
)