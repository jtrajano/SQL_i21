CREATE TABLE [dbo].[tblSMStartingNumberLocation]
(
	[intStartingNumberLocationId]		INT				NOT NULL	PRIMARY KEY IDENTITY,
    [intStartingNumberId]				INT				NOT NULL, 
	[intCompanyLocationId]				INT				NOT NULL, 
    [intNumber]							INT				NOT NULL,
    [intConcurrencyId]					INT				NOT NULL	DEFAULT 1, 
    CONSTRAINT [FK_tblSMStartingNumberLocation_tblSMCompanyLocation] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]) ON DELETE CASCADE--, 
    --CONSTRAINT [FK_tblSMStartingNumberLocation_tblSMStartingNumber] FOREIGN KEY ([intStartingNumberId]) REFERENCES [tblSMStartingNumber]([intStartingNumberId]) ON DELETE CASCADE
)

