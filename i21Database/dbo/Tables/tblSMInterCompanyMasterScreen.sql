CREATE TABLE [dbo].[tblSMInterCompanyMasterScreen]
(
	[intInterCompanyMasterTableId]			INT					IDENTITY (1, 1) NOT NULL,
    [intScreenId]							INT					NOT NULL,
    [intConcurrencyId]						INT					DEFAULT (1) NOT NULL,

    CONSTRAINT [PK_tblSMInterCompanyMasterTable] PRIMARY KEY CLUSTERED ([intInterCompanyMasterTableId] ASC),
	CONSTRAINT [FK_tblSMInterCompanyMasterScreen_tblSMScreen] FOREIGN KEY ([intScreenId]) REFERENCES [tblSMScreen]([intScreenId]) ON DELETE CASCADE
)
