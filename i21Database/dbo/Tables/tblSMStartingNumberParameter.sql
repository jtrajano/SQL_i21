﻿CREATE TABLE [dbo].[tblSMStartingNumberParameter]
(
	[intStartingNumberParameterId]		INT				NOT NULL	PRIMARY KEY IDENTITY, 
    [intStartingNumberId]				INT				NOT NULL, 
	[strParameter]						NVARCHAR(25)	NOT NULL, 
    [intSort]							INT				NOT NULL, 
    [intConcurrencyId]					INT				NOT NULL	DEFAULT 1--, 
    --CONSTRAINT [FK_tblSMStartingNumberParameter_tblSMStartingNumber] FOREIGN KEY ([intStartingNumberId]) REFERENCES [tblSMStartingNumber]([intStartingNumberId])
)
