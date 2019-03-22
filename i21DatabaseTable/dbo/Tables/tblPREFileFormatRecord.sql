CREATE TABLE [dbo].[tblPREFileFormatRecord]
(
	[intEFileFormatRecordId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intEFileFormatId] INT NOT NULL, 
    [intRecordNo] INT NULL, 
    [strDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [intRecordType] INT NULL, 
    [strDatasource] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[strFilterField] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[strFilterValue] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT ((1)), 
    CONSTRAINT [FK_tblPREFileFormatRecord_tblPREFileFormat] FOREIGN KEY (intEFileFormatId) REFERENCES tblPREFileFormat(intEFileFormatId) ON DELETE CASCADE
)
