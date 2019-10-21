﻿CREATE TABLE [dbo].[tblMFItemSubstitutionDetail]
(
	[intItemSubstitutionDetailId] INT NOT NULL IDENTITY(1,1),
	[intItemSubstitutionId] INT NOT NULL,
	[intItemId] INT NOT NULL, 
	[dtmValidFrom] DATETIME NULL, 
    [dtmValidTo] DATETIME NULL,
	[ysnYearValidationRequired] BIT NOT NULL CONSTRAINT [DF_tblMFItemSubstitutionDetail_ysnYearValidationRequired] DEFAULT 0, 
    [dblPercent] NUMERIC(18, 6) NULL CONSTRAINT [DF_tblMFItemSubstitutionDetail_dblPercent] DEFAULT 0,
	[dblSubstituteRatio] NUMERIC(18, 6) NULL CONSTRAINT [DF_tblMFItemSubstitutionDetail_dblSubstituteRatio] DEFAULT 0, 
    [dblMaxSubstituteRatio] NUMERIC(18, 6) NULL CONSTRAINT [DF_tblMFItemSubstitutionDetail_dblMaxSubstituteRatio] DEFAULT 0,  
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL ,
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL,	 
    [intConcurrencyId] INT NULL DEFAULT 0,
	CONSTRAINT [PK_tblMFItemSubstitutionDetail_intItemSubstitutionDetailId] PRIMARY KEY ([intItemSubstitutionDetailId]),
	CONSTRAINT [FK_tblMFItemSubstitutionDetail_tblMFItemSubstitution_intItemSubstitutionId] FOREIGN KEY ([intItemSubstitutionId]) REFERENCES [tblMFItemSubstitution]([intItemSubstitutionId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblMFItemSubstitutionDetail_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
)
