CREATE TABLE [dbo].[tblPREFileFormatField]
(
	[intEFileFormatFieldId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intEFileFormatRecordId] INT NOT NULL, 
    [intFieldNo] INT NULL, 
    [intLength] INT NULL, 
    [intType] INT NULL, 
    [strDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [strFieldValue] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [strFormat] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intFillerPosition] INT NULL, 
    [intFillerType] INT NULL, 
    [ysnNewLine] BIT NULL DEFAULT ((0)), 
    [intConcurrencyId] INT NOT NULL DEFAULT ((1)), 
    CONSTRAINT [FK_tblPREFileFormatField_tblPRFileFormatRecord] FOREIGN KEY ([intEFileFormatRecordId]) REFERENCES [tblPREFileFormatRecord]([intEFileFormatRecordId]) ON DELETE CASCADE
)
