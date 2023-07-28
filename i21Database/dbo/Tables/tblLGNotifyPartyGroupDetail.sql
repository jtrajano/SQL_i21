CREATE TABLE [dbo].[tblLGNotifyPartyGroupDetail]
(
	[intNotifyPartyGroupDetailId] INT NOT NULL IDENTITY (1, 1),
    [intNotifyPartyGroupId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL, 
    [strNotifyOrConsignee] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [intEntityId] INT NULL,
    [intCompanySetupID] INT NULL,
    [intBankId] INT NULL,
    [intEntityLocationId] INT NULL,
    [intCompanyLocationId] INT NULL,
    
    CONSTRAINT [FK_tblLGNotifyPartyGroupDetail_tblLGNotifyPartyGroup] FOREIGN KEY ([intNotifyPartyGroupId]) REFERENCES [tblLGNotifyPartyGroup]([intNotifyPartyGroupId]) ON DELETE CASCADE,

    CONSTRAINT [FK_tblLGNotifyPartyGroupDetail_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES tblEMEntity([intEntityId]),
    CONSTRAINT [FK_tblLGNotifyPartyGroupDetail_tblSMCompanySetup_intCompanySetupID] FOREIGN KEY ([intCompanySetupID]) REFERENCES [tblSMCompanySetup]([intCompanySetupID]),
    CONSTRAINT [FK_tblLGNotifyPartyGroupDetail_tblCMBank_intBankId] FOREIGN KEY ([intBankId]) REFERENCES [tblCMBank]([intBankId]),
    CONSTRAINT [FK_tblLGNotifyPartyGroupDetail_tblEMEntityLocation_intEntityLocationId] FOREIGN KEY ([intEntityLocationId]) REFERENCES [tblEMEntityLocation]([intEntityLocationId]),
    CONSTRAINT [FK_tblLGNotifyPartyGroupDetail_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
)
