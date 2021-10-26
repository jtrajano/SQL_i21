GO
DECLARE @intImportFileHeaderId INT
DECLARE @intImportFileColumnDetailId INT
DECLARE @intTagAttributeId INT
DECLARE @strLayoutTitle NVARCHAR(MAX)
SET @strLayoutTitle = 'Passport - TPM 3.4'


PRINT N'BEGIN - Store Register TPM setup entries'


--START CHECK HEADER
IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle)
BEGIN
SELECT @intImportFileHeaderId = intImportFileHeaderId FROM dbo.tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle
  UPDATE [dbo].[tblSMImportFileHeader]
  SET [strLayoutTitle] = 'Passport - TPM 3.4'
       ,[strFileType] = 'XML'
       ,[strFieldDelimiter] = NULL
       ,[strXMLType] = 'Inbound'
       ,[strXMLInitiater] = '<?xml version="1.0" encoding="ISO-8859-1"?>'
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 2
  WHERE intImportFileHeaderId = @intImportFileHeaderId
END
ELSE IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle)
BEGIN

    PRINT N'BEGIN - Insert TPM setup entries'
  INSERT INTO [dbo].[tblSMImportFileHeader]
      ([strLayoutTitle],[strFileType],[strFieldDelimiter],[strXMLType],[strXMLInitiater],[ysnActive],[intConcurrencyId])
  VALUES 
      ('Passport - TPM 3.4','XML',NULL,'Inbound','<?xml version="1.0" encoding="ISO-8859-1"?>',1,2)
    PRINT N'END - Insert TPM setup entries'
END
--END CHECK HEADER

PRINT N'END - Store Register TPM setup entries'
GO