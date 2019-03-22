GO
DECLARE @intImportFileHeaderId INT
DECLARE @intImportFileColumnDetailId INT
DECLARE @intTagAttributeId INT
DECLARE @strLayoutTitle NVARCHAR(MAX)
SET @strLayoutTitle = 'Passport Pricebook  - ITT'

--START CHECK HEADER
IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle)
BEGIN
SELECT @intImportFileHeaderId = intImportFileHeaderId FROM dbo.tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle
  UPDATE [dbo].[tblSMImportFileHeader]
  SET [strLayoutTitle] = 'Passport Pricebook  - ITT'
       ,[strFileType] = 'XML'
       ,[strFieldDelimiter] = NULL
       ,[strXMLType] = 'Outbound'
       ,[strXMLInitiater] = '<?xml version="1.0"?>'
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 13
  WHERE intImportFileHeaderId = @intImportFileHeaderId

----DELETE FROM dbo.tblSMXMLTagAttribute
--DELETE TA
--FROM dbo.tblSMXMLTagAttribute TA
--JOIN dbo.tblSMImportFileColumnDetail IFC ON IFC.intImportFileColumnDetailId = TA.intImportFileColumnDetailId
--WHERE IFC.intImportFileHeaderId = @intImportFileHeaderId

----DELETE FROM dbo.tblSMImportFileColumnDetail
--DELETE FROM dbo.tblSMImportFileColumnDetail
--WHERE intImportFileHeaderId = @intImportFileHeaderId
END
ELSE IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileHeader]
      ([strLayoutTitle],[strFileType],[strFieldDelimiter],[strXMLType],[strXMLInitiater],[ysnActive],[intConcurrencyId])
  VALUES 
      ('Passport Pricebook  - ITT','XML',NULL,'Outbound','<?xml version="1.0"?>',1,13)
END
--END CHECK HEADER

SELECT @intImportFileHeaderId = intImportFileHeaderId FROM dbo.tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle

--LEVEL 1
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 1 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,1,0,'NAXML-MaintenanceRequest','tblSTstgPassportPricebookITT33',NULL,NULL,0,NULL,1,5)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 1 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 1
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 1
       ,[intPosition] = 0
       ,[strXMLTag] = 'NAXML-MaintenanceRequest'
       ,[strTable] = 'tblSTstgPassportPricebookITT33'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 0
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 5
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 2
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 2 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,2,1,'TransmissionHeader','tblSTstgPassportPricebookITT33',NULL,'Header',1,NULL,1,2)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 2 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 2
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 2
       ,[intPosition] = 1
       ,[strXMLTag] = 'TransmissionHeader'
       ,[strTable] = 'tblSTstgPassportPricebookITT33'
       ,[strColumnName] = NULL
       ,[strDataType] = 'Header'
       ,[intLength] = 1
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 2
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 3
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 3 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,3,1,'StoreLocationID','tblSTstgPassportPricebookITT33','StoreLocationID',NULL,2,NULL,1,2)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 3 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 3
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 3
       ,[intPosition] = 1
       ,[strXMLTag] = 'StoreLocationID'
       ,[strTable] = 'tblSTstgPassportPricebookITT33'
       ,[strColumnName] = 'StoreLocationID'
       ,[strDataType] = NULL
       ,[intLength] = 2
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 2
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 4
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 4 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,4,2,'VendorName','tblSTstgPassportPricebookITT33','VendorName',NULL,2,NULL,1,2)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 4 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 4
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 4
       ,[intPosition] = 2
       ,[strXMLTag] = 'VendorName'
       ,[strTable] = 'tblSTstgPassportPricebookITT33'
       ,[strColumnName] = 'VendorName'
       ,[strDataType] = NULL
       ,[intLength] = 2
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 2
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 5
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 5 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,5,3,'VendorModelVersion','tblSTstgPassportPricebookITT33','VendorModelVersion',NULL,2,NULL,1,2)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 5 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 5
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 5
       ,[intPosition] = 3
       ,[strXMLTag] = 'VendorModelVersion'
       ,[strTable] = 'tblSTstgPassportPricebookITT33'
       ,[strColumnName] = 'VendorModelVersion'
       ,[strDataType] = NULL
       ,[intLength] = 2
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 2
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 6
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 6 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,6,2,'ItemMaintenance','tblSTstgPassportPricebookITT33',NULL,'Header',1,NULL,1,2)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 6 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 6
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 6
       ,[intPosition] = 2
       ,[strXMLTag] = 'ItemMaintenance'
       ,[strTable] = 'tblSTstgPassportPricebookITT33'
       ,[strColumnName] = NULL
       ,[strDataType] = 'Header'
       ,[intLength] = 1
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 2
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 7
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 7 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,7,1,'TableAction',NULL,NULL,NULL,6,NULL,1,2)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 7 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 7
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 7
       ,[intPosition] = 1
       ,[strXMLTag] = 'TableAction'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 6
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 2
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 8
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 8 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,8,2,'RecordAction',NULL,NULL,NULL,6,NULL,1,2)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 8 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 8
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 8
       ,[intPosition] = 2
       ,[strXMLTag] = 'RecordAction'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 6
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 2
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 9
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 9 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,9,3,'ITTDetail','tblSTstgPassportPricebookITT33',NULL,NULL,6,NULL,1,3)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 9 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 9
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 9
       ,[intPosition] = 3
       ,[strXMLTag] = 'ITTDetail'
       ,[strTable] = 'tblSTstgPassportPricebookITT33'
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 6
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 3
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 10
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 10 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,10,1,'RecordAction',NULL,NULL,NULL,9,NULL,1,2)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 10 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 10
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 10
       ,[intPosition] = 1
       ,[strXMLTag] = 'RecordAction'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 9
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 2
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 11
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 11 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,11,2,'ItemCode','tblSTstgPassportPricebookITT33',NULL,'Header',9,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 11 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 11
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 11
       ,[intPosition] = 2
       ,[strXMLTag] = 'ItemCode'
       ,[strTable] = 'tblSTstgPassportPricebookITT33'
       ,[strColumnName] = NULL
       ,[strDataType] = 'Header'
       ,[intLength] = 9
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 12
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 12 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,12,1,'POSCodeFormat',NULL,NULL,NULL,11,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 12 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 12
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 12
       ,[intPosition] = 1
       ,[strXMLTag] = 'POSCodeFormat'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 11
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 13
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 13 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,13,2,'POSCode','tblSTstgPassportPricebookITT33','POSCode',NULL,11,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 13 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 13
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 13
       ,[intPosition] = 2
       ,[strXMLTag] = 'POSCode'
       ,[strTable] = 'tblSTstgPassportPricebookITT33'
       ,[strColumnName] = 'POSCode'
       ,[strDataType] = NULL
       ,[intLength] = 11
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 14
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 14 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,14,3,'POSCodeModifier','tblSTstgPassportPricebookITT33','POSCodeModifier',NULL,11,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 14 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 14
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 14
       ,[intPosition] = 3
       ,[strXMLTag] = 'POSCodeModifier'
       ,[strTable] = 'tblSTstgPassportPricebookITT33'
       ,[strColumnName] = 'POSCodeModifier'
       ,[strDataType] = NULL
       ,[intLength] = 11
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 15
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 15 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,15,3,'ITTData','tblSTstgPassportPricebookITT33',NULL,'Header',9,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 15 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 15
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 15
       ,[intPosition] = 3
       ,[strXMLTag] = 'ITTData'
       ,[strTable] = 'tblSTstgPassportPricebookITT33'
       ,[strColumnName] = NULL
       ,[strDataType] = 'Header'
       ,[intLength] = 9
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 16
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 16 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,16,1,'ActiveFlg',NULL,NULL,NULL,15,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 16 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 16
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 16
       ,[intPosition] = 1
       ,[strXMLTag] = 'ActiveFlg'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 15
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 17
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 17 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,17,2,'InventoryValuePrice','tblSTstgPassportPricebookITT33','InventoryValuePrice',NULL,15,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 17 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 17
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 17
       ,[intPosition] = 2
       ,[strXMLTag] = 'InventoryValuePrice'
       ,[strTable] = 'tblSTstgPassportPricebookITT33'
       ,[strColumnName] = 'InventoryValuePrice'
       ,[strDataType] = NULL
       ,[intLength] = 15
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 18
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 18 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,18,3,'MerchandiseCode','tblSTstgPassportPricebookITT33','MerchandiseCode',NULL,15,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 18 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 18
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 18
       ,[intPosition] = 3
       ,[strXMLTag] = 'MerchandiseCode'
       ,[strTable] = 'tblSTstgPassportPricebookITT33'
       ,[strColumnName] = 'MerchandiseCode'
       ,[strDataType] = NULL
       ,[intLength] = 15
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 19
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 19 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,19,4,'RegularSellPrice','tblSTstgPassportPricebookITT33','RegularSellPrice',NULL,15,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 19 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 19
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 19
       ,[intPosition] = 4
       ,[strXMLTag] = 'RegularSellPrice'
       ,[strTable] = 'tblSTstgPassportPricebookITT33'
       ,[strColumnName] = 'RegularSellPrice'
       ,[strDataType] = NULL
       ,[intLength] = 15
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 20
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 20 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,20,5,'Description','tblSTstgPassportPricebookITT33','Description',NULL,15,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 20 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 20
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 20
       ,[intPosition] = 5
       ,[strXMLTag] = 'Description'
       ,[strTable] = 'tblSTstgPassportPricebookITT33'
       ,[strColumnName] = 'Description'
       ,[strDataType] = NULL
       ,[intLength] = 15
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 21
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 21 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,21,6,'PaymentSystemsProductCode','tblSTstgPassportPricebookITT33','PaymentSystemsProductCode',NULL,15,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 21 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 21
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 21
       ,[intPosition] = 6
       ,[strXMLTag] = 'PaymentSystemsProductCode'
       ,[strTable] = 'tblSTstgPassportPricebookITT33'
       ,[strColumnName] = 'PaymentSystemsProductCode'
       ,[strDataType] = NULL
       ,[intLength] = 15
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 22
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 22 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,22,7,'SellingUnits','tblSTstgPassportPricebookITT33','SellingUnits',NULL,15,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 22 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 22
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 22
       ,[intPosition] = 7
       ,[strXMLTag] = 'SellingUnits'
       ,[strTable] = 'tblSTstgPassportPricebookITT33'
       ,[strColumnName] = 'SellingUnits'
       ,[strDataType] = NULL
       ,[intLength] = 15
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 23
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 23 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,23,8,'TaxStrategyId','tblSTstgPassportPricebookITT33','TaxStrategyID',NULL,15,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 23 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 23
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 23
       ,[intPosition] = 8
       ,[strXMLTag] = 'TaxStrategyId'
       ,[strTable] = 'tblSTstgPassportPricebookITT33'
       ,[strColumnName] = 'TaxStrategyID'
       ,[strDataType] = NULL
       ,[intLength] = 15
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 24
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 24 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,24,9,'PriceMethodCode','tblSTstgPassportPricebookITT33','PriceMethodCode',NULL,15,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 24 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 24
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 24
       ,[intPosition] = 9
       ,[strXMLTag] = 'PriceMethodCode'
       ,[strTable] = 'tblSTstgPassportPricebookITT33'
       ,[strColumnName] = 'PriceMethodCode'
       ,[strDataType] = NULL
       ,[intLength] = 15
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 25
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 25 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,25,10,'ReceiptDescription','tblSTstgPassportPricebookITT33','ReceiptDescription',NULL,15,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 25 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 25
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 25
       ,[intPosition] = 10
       ,[strXMLTag] = 'ReceiptDescription'
       ,[strTable] = 'tblSTstgPassportPricebookITT33'
       ,[strColumnName] = 'ReceiptDescription'
       ,[strDataType] = NULL
       ,[intLength] = 15
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 26
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 26 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,26,11,'FoodStampableFlg','tblSTstgPassportPricebookITT33','FoodStampableFlg',NULL,15,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 26 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 26
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 26
       ,[intPosition] = 11
       ,[strXMLTag] = 'FoodStampableFlg'
       ,[strTable] = 'tblSTstgPassportPricebookITT33'
       ,[strColumnName] = 'FoodStampableFlg'
       ,[strDataType] = NULL
       ,[intLength] = 15
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 27
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 27 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,27,12,'QuantityRequiredFlg','tblSTstgPassportPricebookITT33','QuantityRequiredFlg',NULL,15,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 27 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 27
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 27
       ,[intPosition] = 12
       ,[strXMLTag] = 'QuantityRequiredFlg'
       ,[strTable] = 'tblSTstgPassportPricebookITT33'
       ,[strColumnName] = 'QuantityRequiredFlg'
       ,[strDataType] = NULL
       ,[intLength] = 15
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--Delete Rows Not Included
DELETE FROM tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel NOT IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27)



--LEVEL 1   Attributes(1x)
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 1 AND strXMLTag = 'NAXML-MaintenanceRequest'
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 1 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  INSERT INTO [dbo].[tblSMXMLTagAttribute]
      ([intImportFileColumnDetailId],[intSequence],[strTagAttribute],[strTable],[strColumnName],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileColumnDetailId,1,'version',NULL,NULL,'3.4',0,3)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 1 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  SELECT @intTagAttributeId = intTagAttributeId FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 1 AND intImportFileColumnDetailId = @intImportFileColumnDetailId
  UPDATE[dbo].[tblSMXMLTagAttribute]
  SET [intImportFileColumnDetailId] = @intImportFileColumnDetailId
       ,[intSequence] = 1
       ,[strTagAttribute] = 'version'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDefaultValue] = '3.4'
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 3
  WHERE intTagAttributeId = @intTagAttributeId
END

--Delete Rows Not Included in LEVEL 1   Attributes(1x)
DELETE FROM tblSMXMLTagAttribute WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId AND intSequence NOT IN (1)


--LEVEL 7   Attributes(1x)
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 7 AND strXMLTag = 'TableAction'
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 1 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  INSERT INTO [dbo].[tblSMXMLTagAttribute]
      ([intImportFileColumnDetailId],[intSequence],[strTagAttribute],[strTable],[strColumnName],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileColumnDetailId,1,'type','tblSTstgPassportPricebookITT33','TableActionType',NULL,1,2)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 1 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  SELECT @intTagAttributeId = intTagAttributeId FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 1 AND intImportFileColumnDetailId = @intImportFileColumnDetailId
  UPDATE[dbo].[tblSMXMLTagAttribute]
  SET [intImportFileColumnDetailId] = @intImportFileColumnDetailId
       ,[intSequence] = 1
       ,[strTagAttribute] = 'type'
       ,[strTable] = 'tblSTstgPassportPricebookITT33'
       ,[strColumnName] = 'TableActionType'
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 2
  WHERE intTagAttributeId = @intTagAttributeId
END

--Delete Rows Not Included in LEVEL 7   Attributes(1x)
DELETE FROM tblSMXMLTagAttribute WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId AND intSequence NOT IN (1)


--LEVEL 8   Attributes(1x)
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 8 AND strXMLTag = 'RecordAction'
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 1 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  INSERT INTO [dbo].[tblSMXMLTagAttribute]
      ([intImportFileColumnDetailId],[intSequence],[strTagAttribute],[strTable],[strColumnName],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileColumnDetailId,1,'type','tblSTstgPassportPricebookITT33','RecordActionType',NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 1 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  SELECT @intTagAttributeId = intTagAttributeId FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 1 AND intImportFileColumnDetailId = @intImportFileColumnDetailId
  UPDATE[dbo].[tblSMXMLTagAttribute]
  SET [intImportFileColumnDetailId] = @intImportFileColumnDetailId
       ,[intSequence] = 1
       ,[strTagAttribute] = 'type'
       ,[strTable] = 'tblSTstgPassportPricebookITT33'
       ,[strColumnName] = 'RecordActionType'
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intTagAttributeId = @intTagAttributeId
END

--Delete Rows Not Included in LEVEL 8   Attributes(1x)
DELETE FROM tblSMXMLTagAttribute WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId AND intSequence NOT IN (1)


--LEVEL 10   Attributes(1x)
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 10 AND strXMLTag = 'RecordAction'
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 1 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  INSERT INTO [dbo].[tblSMXMLTagAttribute]
      ([intImportFileColumnDetailId],[intSequence],[strTagAttribute],[strTable],[strColumnName],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileColumnDetailId,1,'type','tblSTstgPassportPricebookITT33','ITTDetailRecordActionType',NULL,1,2)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 1 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  SELECT @intTagAttributeId = intTagAttributeId FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 1 AND intImportFileColumnDetailId = @intImportFileColumnDetailId
  UPDATE[dbo].[tblSMXMLTagAttribute]
  SET [intImportFileColumnDetailId] = @intImportFileColumnDetailId
       ,[intSequence] = 1
       ,[strTagAttribute] = 'type'
       ,[strTable] = 'tblSTstgPassportPricebookITT33'
       ,[strColumnName] = 'ITTDetailRecordActionType'
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 2
  WHERE intTagAttributeId = @intTagAttributeId
END

--Delete Rows Not Included in LEVEL 10   Attributes(1x)
DELETE FROM tblSMXMLTagAttribute WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId AND intSequence NOT IN (1)


--LEVEL 12   Attributes(1x)
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 12 AND strXMLTag = 'POSCodeFormat'
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 1 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  INSERT INTO [dbo].[tblSMXMLTagAttribute]
      ([intImportFileColumnDetailId],[intSequence],[strTagAttribute],[strTable],[strColumnName],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileColumnDetailId,1,'format','tblSTstgPassportPricebookITT33','POSCodeFormatFormat',' ',1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 1 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  SELECT @intTagAttributeId = intTagAttributeId FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 1 AND intImportFileColumnDetailId = @intImportFileColumnDetailId
  UPDATE[dbo].[tblSMXMLTagAttribute]
  SET [intImportFileColumnDetailId] = @intImportFileColumnDetailId
       ,[intSequence] = 1
       ,[strTagAttribute] = 'format'
       ,[strTable] = 'tblSTstgPassportPricebookITT33'
       ,[strColumnName] = 'POSCodeFormatFormat'
       ,[strDefaultValue] = ' '
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intTagAttributeId = @intTagAttributeId
END

--Delete Rows Not Included in LEVEL 12   Attributes(1x)
DELETE FROM tblSMXMLTagAttribute WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId AND intSequence NOT IN (1)


--LEVEL 16   Attributes(1x)
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 16 AND strXMLTag = 'ActiveFlg'
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 1 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  INSERT INTO [dbo].[tblSMXMLTagAttribute]
      ([intImportFileColumnDetailId],[intSequence],[strTagAttribute],[strTable],[strColumnName],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileColumnDetailId,1,'value','tblSTstgPassportPricebookITT33','ActiveFlagValue',' ',1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 1 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  SELECT @intTagAttributeId = intTagAttributeId FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 1 AND intImportFileColumnDetailId = @intImportFileColumnDetailId
  UPDATE[dbo].[tblSMXMLTagAttribute]
  SET [intImportFileColumnDetailId] = @intImportFileColumnDetailId
       ,[intSequence] = 1
       ,[strTagAttribute] = 'value'
       ,[strTable] = 'tblSTstgPassportPricebookITT33'
       ,[strColumnName] = 'ActiveFlagValue'
       ,[strDefaultValue] = ' '
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intTagAttributeId = @intTagAttributeId
END

--Delete Rows Not Included in LEVEL 16   Attributes(1x)
DELETE FROM tblSMXMLTagAttribute WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId AND intSequence NOT IN (1)


GO