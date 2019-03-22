CREATE TABLE [dbo].[tblLGLoadNotifyParties]
(
[intLoadNotifyPartyId] INT NOT NULL IDENTITY (1, 1),
[intConcurrencyId] INT NOT NULL, 
[intLoadId] INT NOT NULL,
[strNotifyOrConsignee] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[strType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[intEntityId] INT NULL,
[intCompanySetupID] INT NULL,
[intBankId] INT NULL,
[intEntityLocationId] INT NULL,
[intCompanyLocationId] INT NULL,
[strText] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NULL,
[intLoadNotifyPartyRefId] INT NULL,

CONSTRAINT [PK_tblLGLoadNotifyParties] PRIMARY KEY ([intLoadNotifyPartyId]), 
CONSTRAINT [FK_tblLGLoadNotifyParties_tblLGLoad_intLoadId] FOREIGN KEY ([intLoadId]) REFERENCES [tblLGLoad]([intLoadId]) ON DELETE CASCADE,
CONSTRAINT [FK_tblLGLoadNotifyParties_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES tblEMEntity([intEntityId]),
CONSTRAINT [FK_tblLGLoadNotifyParties_tblSMCompanySetup_intCompanySetupID] FOREIGN KEY ([intCompanySetupID]) REFERENCES [tblSMCompanySetup]([intCompanySetupID]),
CONSTRAINT [FK_tblLGLoadNotifyParties_tblCMBank_intBankId] FOREIGN KEY ([intBankId]) REFERENCES [tblCMBank]([intBankId]),
CONSTRAINT [FK_tblLGLoadNotifyParties_tblEMEntityLocation_intEntityLocationId] FOREIGN KEY ([intEntityLocationId]) REFERENCES [tblEMEntityLocation]([intEntityLocationId]),
CONSTRAINT [FK_tblLGLoadNotifyParties_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId])
)
