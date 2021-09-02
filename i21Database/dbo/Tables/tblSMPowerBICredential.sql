CREATE TABLE [dbo].[tblSMPowerBICredential]
(
	[intPowerBICredentialId]	INT		NOT NULL	PRIMARY KEY IDENTITY, 
	[strUsername]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strPassword]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnActive]					BIT NULL,
	[intConcurrencyId]			INT		NOT NULL	DEFAULT 1
)
