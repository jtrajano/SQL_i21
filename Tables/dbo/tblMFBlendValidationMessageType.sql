CREATE TABLE [dbo].[tblMFBlendValidationMessageType]
(
	[intMessageTypeId] INT NOT NULL,
	[strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	CONSTRAINT [PK_tblMFBlendValidationMessageType_intMessageTypeId] PRIMARY KEY ([intMessageTypeId]), 
    CONSTRAINT [UQ_tblMFBlendValidationMessageType_strName] UNIQUE ([strName]) 
)
