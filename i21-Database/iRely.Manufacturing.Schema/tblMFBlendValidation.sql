CREATE TABLE [dbo].[tblMFBlendValidation]
(
	[intBlendValidationId] INT NOT NULL IDENTITY, 
    [intBlendValidationDefaultId] INT NOT NULL, 
    [intMessageTypeId] INT NOT NULL, 
    [strMessage] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL CONSTRAINT [DF_tblMFBlendValidation_strMessage] DEFAULT '',
	[intTypeId] INT NULL,
	[intLastModifiedUserId] [int] NOT NULL,
	[dtmLastModified] [datetime] NOT NULL CONSTRAINT [DF_tblMFBlendValidation_dtmLastModified] DEFAULT GetDate(),	 
    [intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFBlendValidation_intConcurrencyId] DEFAULT 0,
	CONSTRAINT [PK_tblMFBlendValidation_intBlendValidationId] PRIMARY KEY ([intBlendValidationId]),
	CONSTRAINT [UQ_tblMFBlendValidation_intBlendValidationDefaultId] UNIQUE ([intBlendValidationDefaultId],[intTypeId]),
	CONSTRAINT [FK_tblMFBlendValidation_intBlendValidationDefaultId] FOREIGN KEY ([intBlendValidationDefaultId]) REFERENCES [tblMFBlendValidationDefault]([intBlendValidationDefaultId]),
	CONSTRAINT [FK_tblMFBlendValidation_intMessageTypeId] FOREIGN KEY ([intMessageTypeId]) REFERENCES [tblMFBlendValidationMessageType]([intMessageTypeId]) 
)
