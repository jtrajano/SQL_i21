﻿GO
DECLARE @intImportFileHeaderId INT
DECLARE @intImportFileColumnDetailId INT
DECLARE @intTagAttributeId INT
DECLARE @strLayoutTitle NVARCHAR(MAX)
SET @strLayoutTitle = 'Radiant - MCM'

--START CHECK HEADER
IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle)
BEGIN
SELECT @intImportFileHeaderId = intImportFileHeaderId FROM dbo.tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle
  UPDATE [dbo].[tblSMImportFileHeader]
  SET [strLayoutTitle] = 'Radiant - MCM'
       ,[strFileType] = 'XML'
       ,[strFieldDelimiter] = NULL
       ,[strXMLType] = 'Inbound'
       ,[strXMLInitiater] = '<?xml version="1.0" encoding="utf-8"?>'
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 0
  WHERE intImportFileHeaderId = @intImportFileHeaderId
END
ELSE IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileHeader]
      ([strLayoutTitle],[strFileType],[strFieldDelimiter],[strXMLType],[strXMLInitiater],[ysnActive],[intConcurrencyId])
  VALUES 
      ('Radiant - MCM','XML',NULL,'Inbound','<?xml version="1.0" encoding="utf-8"?>',1,0)
END
--END CHECK HEADER

SELECT @intImportFileHeaderId = intImportFileHeaderId FROM dbo.tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle

--LEVEL 1
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'NAXML-MovementReport' AND intLevel = 1 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,1,0,'NAXML-MovementReport','tblSTPriceBookStaging',NULL,NULL,0,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'NAXML-MovementReport' AND intLevel = 1 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 1  AND strXMLTag = 'NAXML-MovementReport'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 1
       ,[intPosition] = 0
       ,[strXMLTag] = 'NAXML-MovementReport'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 0
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 2
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'TransmissionHeader' AND intLevel = 2 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,2,1,'TransmissionHeader','tblSTPriceBookStaging',NULL,'Header',1,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'TransmissionHeader' AND intLevel = 2 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 2  AND strXMLTag = 'TransmissionHeader'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 2
       ,[intPosition] = 1
       ,[strXMLTag] = 'TransmissionHeader'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = 'Header'
       ,[intLength] = 1
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 3
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'StoreLocationID' AND intLevel = 3 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,3,1,'StoreLocationID','tblSTPriceBookStaging',NULL,NULL,2,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'StoreLocationID' AND intLevel = 3 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 3  AND strXMLTag = 'StoreLocationID'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 3
       ,[intPosition] = 1
       ,[strXMLTag] = 'StoreLocationID'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 2
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 4
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'VendorName' AND intLevel = 4 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,4,2,'VendorName','tblSTPriceBookStaging',NULL,NULL,2,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'VendorName' AND intLevel = 4 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 4  AND strXMLTag = 'VendorName'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 4
       ,[intPosition] = 2
       ,[strXMLTag] = 'VendorName'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 2
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 5
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'VendorModelVersion' AND intLevel = 5 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,5,3,'VendorModelVersion','tblSTPriceBookStaging',NULL,NULL,2,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'VendorModelVersion' AND intLevel = 5 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 5  AND strXMLTag = 'VendorModelVersion'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 5
       ,[intPosition] = 3
       ,[strXMLTag] = 'VendorModelVersion'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 2
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 6
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'Extension' AND intLevel = 6 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,6,1,'Extension','tblSTPriceBookStaging',NULL,'Header',2,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'Extension' AND intLevel = 6 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 6  AND strXMLTag = 'Extension'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 6
       ,[intPosition] = 1
       ,[strXMLTag] = 'Extension'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = 'Header'
       ,[intLength] = 2
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 7
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'radiant:StoreName' AND intLevel = 7 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,7,1,'radiant:StoreName','tblSTPriceBookStaging',NULL,NULL,6,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'radiant:StoreName' AND intLevel = 7 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 7  AND strXMLTag = 'radiant:StoreName'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 7
       ,[intPosition] = 1
       ,[strXMLTag] = 'radiant:StoreName'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 6
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 8
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'radiant:BusinessDate' AND intLevel = 8 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,8,2,'radiant:BusinessDate','tblSTPriceBookStaging',NULL,NULL,6,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'radiant:BusinessDate' AND intLevel = 8 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 8  AND strXMLTag = 'radiant:BusinessDate'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 8
       ,[intPosition] = 2
       ,[strXMLTag] = 'radiant:BusinessDate'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 6
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 9
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MerchandiseCodeMovement' AND intLevel = 9 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,9,2,'MerchandiseCodeMovement','tblSTPriceBookStaging',NULL,'Header',1,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MerchandiseCodeMovement' AND intLevel = 9 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 9  AND strXMLTag = 'MerchandiseCodeMovement'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 9
       ,[intPosition] = 2
       ,[strXMLTag] = 'MerchandiseCodeMovement'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = 'Header'
       ,[intLength] = 1
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 10
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MovementHeader' AND intLevel = 10 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,10,1,'MovementHeader','tblSTPriceBookStaging',NULL,'Header',9,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MovementHeader' AND intLevel = 10 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 10  AND strXMLTag = 'MovementHeader'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 10
       ,[intPosition] = 1
       ,[strXMLTag] = 'MovementHeader'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = 'Header'
       ,[intLength] = 9
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 11
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'ReportSequenceNumber' AND intLevel = 11 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,11,1,'ReportSequenceNumber','tblSTPriceBookStaging',NULL,NULL,10,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'ReportSequenceNumber' AND intLevel = 11 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 11  AND strXMLTag = 'ReportSequenceNumber'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 11
       ,[intPosition] = 1
       ,[strXMLTag] = 'ReportSequenceNumber'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 10
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 12
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'PrimaryReportPeriod' AND intLevel = 12 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,12,2,'PrimaryReportPeriod','tblSTPriceBookStaging',NULL,NULL,10,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'PrimaryReportPeriod' AND intLevel = 12 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 12  AND strXMLTag = 'PrimaryReportPeriod'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 12
       ,[intPosition] = 2
       ,[strXMLTag] = 'PrimaryReportPeriod'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 10
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 13
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'SecondaryReportPeriod' AND intLevel = 13 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,13,3,'SecondaryReportPeriod','tblSTPriceBookStaging',NULL,NULL,10,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'SecondaryReportPeriod' AND intLevel = 13 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 13  AND strXMLTag = 'SecondaryReportPeriod'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 13
       ,[intPosition] = 3
       ,[strXMLTag] = 'SecondaryReportPeriod'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 10
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 14
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'BusinessDate' AND intLevel = 14 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,14,4,'BusinessDate','tblSTPriceBookStaging',NULL,NULL,10,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'BusinessDate' AND intLevel = 14 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 14  AND strXMLTag = 'BusinessDate'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 14
       ,[intPosition] = 4
       ,[strXMLTag] = 'BusinessDate'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 10
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 15
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'BeginDate' AND intLevel = 15 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,15,5,'BeginDate','tblSTPriceBookStaging',NULL,NULL,10,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'BeginDate' AND intLevel = 15 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 15  AND strXMLTag = 'BeginDate'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 15
       ,[intPosition] = 5
       ,[strXMLTag] = 'BeginDate'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 10
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 16
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'BeginTime' AND intLevel = 16 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,16,6,'BeginTime','tblSTPriceBookStaging',NULL,NULL,10,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'BeginTime' AND intLevel = 16 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 16  AND strXMLTag = 'BeginTime'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 16
       ,[intPosition] = 6
       ,[strXMLTag] = 'BeginTime'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 10
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 17
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'EndDate' AND intLevel = 17 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,17,7,'EndDate','tblSTPriceBookStaging',NULL,NULL,10,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'EndDate' AND intLevel = 17 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 17  AND strXMLTag = 'EndDate'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 17
       ,[intPosition] = 7
       ,[strXMLTag] = 'EndDate'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 10
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 18
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'EndTime' AND intLevel = 18 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,18,8,'EndTime','tblSTPriceBookStaging',NULL,NULL,10,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'EndTime' AND intLevel = 18 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 18  AND strXMLTag = 'EndTime'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 18
       ,[intPosition] = 8
       ,[strXMLTag] = 'EndTime'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 10
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 19
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'SalesMovementHeader' AND intLevel = 19 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,19,2,'SalesMovementHeader','tblSTPriceBookStaging',NULL,'Header',9,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'SalesMovementHeader' AND intLevel = 19 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 19  AND strXMLTag = 'SalesMovementHeader'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 19
       ,[intPosition] = 2
       ,[strXMLTag] = 'SalesMovementHeader'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = 'Header'
       ,[intLength] = 9
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 20
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'RegisterID' AND intLevel = 20 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,20,1,'RegisterID','tblSTPriceBookStaging',NULL,NULL,19,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'RegisterID' AND intLevel = 20 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 20  AND strXMLTag = 'RegisterID'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 20
       ,[intPosition] = 1
       ,[strXMLTag] = 'RegisterID'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 19
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 21
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'CashierID' AND intLevel = 21 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,21,2,'CashierID','tblSTPriceBookStaging',NULL,NULL,19,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'CashierID' AND intLevel = 21 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 21  AND strXMLTag = 'CashierID'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 21
       ,[intPosition] = 2
       ,[strXMLTag] = 'CashierID'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 19
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 22
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'TillID' AND intLevel = 22 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,22,3,'TillID','tblSTPriceBookStaging',NULL,NULL,19,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'TillID' AND intLevel = 22 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 22  AND strXMLTag = 'TillID'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 22
       ,[intPosition] = 3
       ,[strXMLTag] = 'TillID'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 19
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 23
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'EmployeeNumber' AND intLevel = 23 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,23,4,'EmployeeNumber','tblSTPriceBookStaging',NULL,NULL,19,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'EmployeeNumber' AND intLevel = 23 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 23  AND strXMLTag = 'EmployeeNumber'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 23
       ,[intPosition] = 4
       ,[strXMLTag] = 'EmployeeNumber'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 19
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 24
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MCMDetail' AND intLevel = 24 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,24,3,'MCMDetail','tblSTPriceBookStaging',NULL,'Header',9,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MCMDetail' AND intLevel = 24 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 24  AND strXMLTag = 'MCMDetail'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 24
       ,[intPosition] = 3
       ,[strXMLTag] = 'MCMDetail'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = 'Header'
       ,[intLength] = 9
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 25
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MerchandiseCode' AND intLevel = 25 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,25,1,'MerchandiseCode','tblSTPriceBookStaging',NULL,NULL,24,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MerchandiseCode' AND intLevel = 25 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 25  AND strXMLTag = 'MerchandiseCode'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 25
       ,[intPosition] = 1
       ,[strXMLTag] = 'MerchandiseCode'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 24
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 26
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MerchandiseCodeDescription' AND intLevel = 26 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,26,2,'MerchandiseCodeDescription','tblSTPriceBookStaging',NULL,NULL,24,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MerchandiseCodeDescription' AND intLevel = 26 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 26  AND strXMLTag = 'MerchandiseCodeDescription'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 26
       ,[intPosition] = 2
       ,[strXMLTag] = 'MerchandiseCodeDescription'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 24
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 27
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MCMSalesTotals' AND intLevel = 27 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,27,3,'MCMSalesTotals','tblSTPriceBookStaging',NULL,'Header',24,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MCMSalesTotals' AND intLevel = 27 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 27  AND strXMLTag = 'MCMSalesTotals'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 27
       ,[intPosition] = 3
       ,[strXMLTag] = 'MCMSalesTotals'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = 'Header'
       ,[intLength] = 24
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 28
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'DiscountAmount' AND intLevel = 28 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,28,1,'DiscountAmount','tblSTPriceBookStaging',NULL,NULL,27,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'DiscountAmount' AND intLevel = 28 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 28  AND strXMLTag = 'DiscountAmount'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 28
       ,[intPosition] = 1
       ,[strXMLTag] = 'DiscountAmount'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 27
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 29
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'DiscountCount' AND intLevel = 29 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,29,2,'DiscountCount','tblSTPriceBookStaging',NULL,NULL,27,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'DiscountCount' AND intLevel = 29 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 29  AND strXMLTag = 'DiscountCount'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 29
       ,[intPosition] = 2
       ,[strXMLTag] = 'DiscountCount'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 27
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 30
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'PromotionAmount' AND intLevel = 30 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,30,3,'PromotionAmount','tblSTPriceBookStaging',NULL,NULL,27,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'PromotionAmount' AND intLevel = 30 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 30  AND strXMLTag = 'PromotionAmount'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 30
       ,[intPosition] = 3
       ,[strXMLTag] = 'PromotionAmount'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 27
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 31
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'PromotionCount' AND intLevel = 31 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,31,4,'PromotionCount','tblSTPriceBookStaging',NULL,NULL,27,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'PromotionCount' AND intLevel = 31 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 31  AND strXMLTag = 'PromotionCount'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 31
       ,[intPosition] = 4
       ,[strXMLTag] = 'PromotionCount'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 27
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 32
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'RefundAmount' AND intLevel = 32 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,32,5,'RefundAmount','tblSTPriceBookStaging',NULL,NULL,27,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'RefundAmount' AND intLevel = 32 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 32  AND strXMLTag = 'RefundAmount'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 32
       ,[intPosition] = 5
       ,[strXMLTag] = 'RefundAmount'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 27
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 33
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'RefundCount' AND intLevel = 33 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,33,6,'RefundCount','tblSTPriceBookStaging',NULL,NULL,27,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'RefundCount' AND intLevel = 33 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 33  AND strXMLTag = 'RefundCount'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 33
       ,[intPosition] = 6
       ,[strXMLTag] = 'RefundCount'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 27
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 34
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'SalesQuantity' AND intLevel = 34 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,34,7,'SalesQuantity','tblSTPriceBookStaging',NULL,NULL,27,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'SalesQuantity' AND intLevel = 34 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 34  AND strXMLTag = 'SalesQuantity'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 34
       ,[intPosition] = 7
       ,[strXMLTag] = 'SalesQuantity'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 27
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 35
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'SalesAmount' AND intLevel = 35 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,35,8,'SalesAmount','tblSTPriceBookStaging',NULL,NULL,27,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'SalesAmount' AND intLevel = 35 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 35  AND strXMLTag = 'SalesAmount'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 35
       ,[intPosition] = 8
       ,[strXMLTag] = 'SalesAmount'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 27
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 36
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'TransactionCount' AND intLevel = 36 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,36,9,'TransactionCount','tblSTPriceBookStaging',NULL,NULL,27,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'TransactionCount' AND intLevel = 36 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 36  AND strXMLTag = 'TransactionCount'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 36
       ,[intPosition] = 9
       ,[strXMLTag] = 'TransactionCount'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 27
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 37
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'VoidAmount' AND intLevel = 37 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,37,10,'VoidAmount','tblSTPriceBookStaging',NULL,NULL,27,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'VoidAmount' AND intLevel = 37 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 37  AND strXMLTag = 'VoidAmount'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 37
       ,[intPosition] = 10
       ,[strXMLTag] = 'VoidAmount'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 27
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 38
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'VoidCount' AND intLevel = 38 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,38,11,'VoidCount','tblSTPriceBookStaging',NULL,NULL,27,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'VoidCount' AND intLevel = 38 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 38  AND strXMLTag = 'VoidCount'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 38
       ,[intPosition] = 11
       ,[strXMLTag] = 'VoidCount'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 27
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 39
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'OpenDepartmentSalesAmount' AND intLevel = 39 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,39,12,'OpenDepartmentSalesAmount','tblSTPriceBookStaging',NULL,NULL,27,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'OpenDepartmentSalesAmount' AND intLevel = 39 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 39  AND strXMLTag = 'OpenDepartmentSalesAmount'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 39
       ,[intPosition] = 12
       ,[strXMLTag] = 'OpenDepartmentSalesAmount'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 27
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 40
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'OpenDepartmentSalesCount' AND intLevel = 40 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,40,13,'OpenDepartmentSalesCount','tblSTPriceBookStaging',NULL,NULL,27,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'OpenDepartmentSalesCount' AND intLevel = 40 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 40  AND strXMLTag = 'OpenDepartmentSalesCount'
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 40
       ,[intPosition] = 13
       ,[strXMLTag] = 'OpenDepartmentSalesCount'
       ,[strTable] = 'tblSTPriceBookStaging'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 27
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END



--LEVEL 1Attributes(2x)
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 1 AND strXMLTag = 'NAXML-MovementReport'
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'xmlns:radiant' AND intSequence = 1 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  INSERT INTO [dbo].[tblSMXMLTagAttribute]
      ([intImportFileColumnDetailId],[intSequence],[strTagAttribute],[strTable],[strColumnName],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileColumnDetailId,1,'xmlns:radiant',NULL,NULL,'http://www.radiantsystems.com/NAXML-Extension',1,1)
END
IF EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'xmlns:radiant' AND intSequence = 1 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  SELECT @intTagAttributeId = intTagAttributeId FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'xmlns:radiant' AND intSequence = 1 AND intImportFileColumnDetailId = @intImportFileColumnDetailId
  UPDATE[dbo].[tblSMXMLTagAttribute]
  SET [intImportFileColumnDetailId] = @intImportFileColumnDetailId
       ,[intSequence] = 1
       ,[strTagAttribute] = 'xmlns:radiant'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDefaultValue] = 'http://www.radiantsystems.com/NAXML-Extension'
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intTagAttributeId = @intTagAttributeId
END

SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 1 AND strXMLTag = 'NAXML-MovementReport'
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'xmlns' AND intSequence = 2 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  INSERT INTO [dbo].[tblSMXMLTagAttribute]
      ([intImportFileColumnDetailId],[intSequence],[strTagAttribute],[strTable],[strColumnName],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileColumnDetailId,2,'xmlns',NULL,NULL,'http://www.naxml.org/POSBO/Vocabulary/2003-10-16',1,1)
END
IF EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'xmlns' AND intSequence = 2 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  SELECT @intTagAttributeId = intTagAttributeId FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'xmlns' AND intSequence = 2 AND intImportFileColumnDetailId = @intImportFileColumnDetailId
  UPDATE[dbo].[tblSMXMLTagAttribute]
  SET [intImportFileColumnDetailId] = @intImportFileColumnDetailId
       ,[intSequence] = 2
       ,[strTagAttribute] = 'xmlns'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDefaultValue] = 'http://www.naxml.org/POSBO/Vocabulary/2003-10-16'
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intTagAttributeId = @intTagAttributeId
END

