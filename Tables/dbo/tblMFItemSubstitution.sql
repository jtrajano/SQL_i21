CREATE TABLE [dbo].[tblMFItemSubstitution]
(
	[intItemSubstitutionId] INT NOT NULL IDENTITY(1,1), 
    [intItemId] INT NOT NULL, 
	[intLocationId] INT NOT NULL, 
    [intItemSubstitutionTypeId] INT NOT NULL, 
    [strComment] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
	[ysnProcessed] BIT NOT NULL CONSTRAINT [DF_tblMFItemSubstitution_ysnProcessed] DEFAULT 0, 
    [ysnCancelled] BIT NOT NULL CONSTRAINT [DF_tblMFItemSubstitution_ysnCancelled] DEFAULT 0,
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL ,
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL,	 
    [intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFItemSubstitution_intConcurrencyId] DEFAULT 0,
	CONSTRAINT [PK_tblMFItemSubstitution_intItemSubstitutionId] PRIMARY KEY ([intItemSubstitutionId]), 
	CONSTRAINT [FK_tblMFItemSubstitution_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblMFItemSubstitution_tblSMCompanyLocation_intCompanyLocationId_intLocationId] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
	CONSTRAINT [FK_tblMFItemSubstitution_tblMFItemSubstitutionType_intItemSubstitutionTypeId] FOREIGN KEY ([intItemSubstitutionTypeId]) REFERENCES [tblMFItemSubstitutionType]([intItemSubstitutionTypeId]), 
)
