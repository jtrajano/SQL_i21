CREATE TABLE [dbo].[tblSCLastScaleSetup]
(
	[intLastScaleSetupId] [int] IDENTITY(1,1) NOT NULL,
	[intScaleSetupId] [int] NULL,
	[intEntityId] [int] NULL,
	[intEntityScaleOperatorId] [int] NULL,
	[dtmScaleDate] [date] NULL,
	[intConcurrencyId] [int] NULL, 
    CONSTRAINT [PK_tblSCLastScaleSetup] PRIMARY KEY ([intLastScaleSetupId]),
	CONSTRAINT [FK_tblSCLastScaleSetup_tblSCScaleSetup_intScaleSetupId] FOREIGN KEY ([intScaleSetupId]) REFERENCES [tblSCScaleSetup]([intScaleSetupId]),  
	CONSTRAINT [FK_tblSCLastScaleSetup_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityScaleOperatorId]) REFERENCES [tblEMEntity]([intEntityId]),
	CONSTRAINT [FK_tblSCLastScaleSetup_tblSMUserSecurity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [tblSMUserSecurity]([intEntityId])
)
