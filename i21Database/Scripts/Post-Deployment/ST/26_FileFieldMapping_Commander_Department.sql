GO
DECLARE @intImportFileHeaderId INT
DECLARE @intImportFileColumnDetailId INT
DECLARE @intTagAttributeId INT
DECLARE @strLayoutTitle NVARCHAR(MAX)
SET @strLayoutTitle = 'Commander Department'

--START CHECK HEADER
IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle)
BEGIN
SELECT @intImportFileHeaderId = intImportFileHeaderId FROM dbo.tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle
  UPDATE [dbo].[tblSMImportFileHeader]
  SET [strLayoutTitle] = 'Commander Department'
       ,[strFileType] = 'XML'
       ,[strFieldDelimiter] = NULL
       ,[strXMLType] = 'Inbound'
       ,[strXMLInitiater] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 20
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
      ('Commander Department','XML',NULL,'Inbound',NULL,1,20)
END
--END CHECK HEADER

SELECT @intImportFileHeaderId = intImportFileHeaderId FROM dbo.tblSMImportFileHeader WHERE strLayoutTitle = @strLayoutTitle

--LEVEL 1
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 1 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,1,0,'departmentPd','tblSTCheckoutImportSapphireData',NULL,'Header',0,NULL,1,5)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 1 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 1
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 1
       ,[intPosition] = 0
       ,[strXMLTag] = 'departmentPd'
       ,[strTable] = 'tblSTCheckoutImportSapphireData'
       ,[strColumnName] = NULL
       ,[strDataType] = 'Header'
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
      (@intImportFileHeaderId,NULL,2,1,'period',NULL,NULL,NULL,1,NULL,1,2)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 2 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 2
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 2
       ,[intPosition] = 1
       ,[strXMLTag] = 'period'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
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
      (@intImportFileHeaderId,NULL,3,2,'site',NULL,NULL,NULL,1,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 3 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 3
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 3
       ,[intPosition] = 2
       ,[strXMLTag] = 'site'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 1
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 4
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 4 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,4,3,'constituentPeriods',NULL,NULL,'Header',1,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 4 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 4
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 4
       ,[intPosition] = 3
       ,[strXMLTag] = 'constituentPeriods'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = 'Header'
       ,[intLength] = 1
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 5
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 5 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,5,4,'totals',NULL,NULL,'Header',1,NULL,1,2)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 5 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 5
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 5
       ,[intPosition] = 4
       ,[strXMLTag] = 'totals'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = 'Header'
       ,[intLength] = 1
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
      (@intImportFileHeaderId,NULL,6,1,'deptInfo',NULL,NULL,'Header',5,NULL,1,2)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 6 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 6
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 6
       ,[intPosition] = 1
       ,[strXMLTag] = 'deptInfo'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = 'Header'
       ,[intLength] = 5
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
      (@intImportFileHeaderId,NULL,7,1,'deptBase',NULL,NULL,'Header',6,NULL,1,2)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 7 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 7
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 7
       ,[intPosition] = 1
       ,[strXMLTag] = 'deptBase'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = 'Header'
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
      (@intImportFileHeaderId,NULL,8,1,'name',NULL,NULL,NULL,7,NULL,1,2)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 8 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 8
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 8
       ,[intPosition] = 1
       ,[strXMLTag] = 'name'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 7
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
      (@intImportFileHeaderId,NULL,9,2,'netSales',NULL,NULL,'Header',6,NULL,1,2)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 9 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 9
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 9
       ,[intPosition] = 2
       ,[strXMLTag] = 'netSales'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = 'Header'
       ,[intLength] = 6
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 2
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 10
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 10 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,10,1,'count',NULL,NULL,NULL,9,NULL,1,2)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 10 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 10
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 10
       ,[intPosition] = 1
       ,[strXMLTag] = 'count'
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
      (@intImportFileHeaderId,NULL,11,2,'amount',NULL,NULL,NULL,9,NULL,1,2)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 11 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 11
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 11
       ,[intPosition] = 2
       ,[strXMLTag] = 'amount'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 9
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 2
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 12
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 12 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,12,3,'itemCount',NULL,NULL,NULL,9,NULL,1,2)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 12 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 12
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 12
       ,[intPosition] = 3
       ,[strXMLTag] = 'itemCount'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 9
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 2
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--LEVEL 13
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 13 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
  INSERT INTO [dbo].[tblSMImportFileColumnDetail]
      ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel],[intPosition],[strXMLTag],[strTable],[strColumnName],[strDataType],[intLength],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileHeaderId,NULL,13,3,'refunds',NULL,NULL,'Header',6,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 13 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 13
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 13
       ,[intPosition] = 3
       ,[strXMLTag] = 'refunds'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = 'Header'
       ,[intLength] = 6
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
      (@intImportFileHeaderId,NULL,14,1,'count',NULL,NULL,NULL,13,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 14 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 14
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 14
       ,[intPosition] = 1
       ,[strXMLTag] = 'count'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 13
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
      (@intImportFileHeaderId,NULL,15,2,'amount',NULL,NULL,NULL,13,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 15 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 15
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 15
       ,[intPosition] = 2
       ,[strXMLTag] = 'amount'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 13
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
      (@intImportFileHeaderId,NULL,16,4,'discounts',NULL,NULL,'Header',6,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 16 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 16
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 16
       ,[intPosition] = 4
       ,[strXMLTag] = 'discounts'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = 'Header'
       ,[intLength] = 6
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
      (@intImportFileHeaderId,NULL,17,1,'total',NULL,NULL,'Header',16,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 17 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 17
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 17
       ,[intPosition] = 1
       ,[strXMLTag] = 'total'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = 'Header'
       ,[intLength] = 16
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
      (@intImportFileHeaderId,NULL,18,1,'count',NULL,NULL,NULL,17,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 18 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 18
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 18
       ,[intPosition] = 1
       ,[strXMLTag] = 'count'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 17
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
      (@intImportFileHeaderId,NULL,19,2,'amount',NULL,NULL,NULL,17,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 19 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 19
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 19
       ,[intPosition] = 2
       ,[strXMLTag] = 'amount'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 17
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
      (@intImportFileHeaderId,NULL,20,2,'promotions',NULL,NULL,'Header',16,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 20 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 20
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 20
       ,[intPosition] = 2
       ,[strXMLTag] = 'promotions'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = 'Header'
       ,[intLength] = 16
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
      (@intImportFileHeaderId,NULL,21,1,'count',NULL,NULL,NULL,20,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 21 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 21
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 21
       ,[intPosition] = 1
       ,[strXMLTag] = 'count'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 20
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
      (@intImportFileHeaderId,NULL,22,2,'amount',NULL,NULL,NULL,20,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 22 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 22
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 22
       ,[intPosition] = 2
       ,[strXMLTag] = 'amount'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 20
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
      (@intImportFileHeaderId,NULL,23,3,'manualDiscounts',NULL,NULL,'Header',16,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 23 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 23
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 23
       ,[intPosition] = 3
       ,[strXMLTag] = 'manualDiscounts'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = 'Header'
       ,[intLength] = 16
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
      (@intImportFileHeaderId,NULL,24,1,'count',NULL,NULL,NULL,23,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 24 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 24
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 24
       ,[intPosition] = 1
       ,[strXMLTag] = 'count'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 23
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
      (@intImportFileHeaderId,NULL,25,2,'amount',NULL,NULL,NULL,23,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 25 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 25
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 25
       ,[intPosition] = 2
       ,[strXMLTag] = 'amount'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 23
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
      (@intImportFileHeaderId,NULL,26,5,'grossSales',NULL,NULL,NULL,6,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 26 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 26
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 26
       ,[intPosition] = 5
       ,[strXMLTag] = 'grossSales'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 6
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
      (@intImportFileHeaderId,NULL,27,6,'percentOfSales',NULL,NULL,NULL,6,NULL,1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intLevel = 27 AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 27
  UPDATE [dbo].[tblSMImportFileColumnDetail]
  SET [intImportFileHeaderId] = @intImportFileHeaderId
       ,[intImportFileRecordMarkerId] = NULL
       ,[intLevel] = 27
       ,[intPosition] = 6
       ,[strXMLTag] = 'percentOfSales'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDataType] = NULL
       ,[intLength] = 6
       ,[strDefaultValue] = NULL
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
END

--Delete Rows Not Included
DELETE FROM tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel NOT IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27)



--LEVEL 2   Attributes(6x)
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 2 AND strXMLTag = 'period'
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 1 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  INSERT INTO [dbo].[tblSMXMLTagAttribute]
      ([intImportFileColumnDetailId],[intSequence],[strTagAttribute],[strTable],[strColumnName],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileColumnDetailId,1,'sysid',NULL,NULL,' ',1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 1 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  SELECT @intTagAttributeId = intTagAttributeId FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 1 AND intImportFileColumnDetailId = @intImportFileColumnDetailId
  UPDATE[dbo].[tblSMXMLTagAttribute]
  SET [intImportFileColumnDetailId] = @intImportFileColumnDetailId
       ,[intSequence] = 1
       ,[strTagAttribute] = 'sysid'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDefaultValue] = ' '
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intTagAttributeId = @intTagAttributeId
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 2 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  INSERT INTO [dbo].[tblSMXMLTagAttribute]
      ([intImportFileColumnDetailId],[intSequence],[strTagAttribute],[strTable],[strColumnName],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileColumnDetailId,2,'periodType',NULL,NULL,' ',1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 2 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  SELECT @intTagAttributeId = intTagAttributeId FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 2 AND intImportFileColumnDetailId = @intImportFileColumnDetailId
  UPDATE[dbo].[tblSMXMLTagAttribute]
  SET [intImportFileColumnDetailId] = @intImportFileColumnDetailId
       ,[intSequence] = 2
       ,[strTagAttribute] = 'periodType'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDefaultValue] = ' '
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intTagAttributeId = @intTagAttributeId
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 3 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  INSERT INTO [dbo].[tblSMXMLTagAttribute]
      ([intImportFileColumnDetailId],[intSequence],[strTagAttribute],[strTable],[strColumnName],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileColumnDetailId,3,'name',NULL,NULL,' ',1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 3 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  SELECT @intTagAttributeId = intTagAttributeId FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 3 AND intImportFileColumnDetailId = @intImportFileColumnDetailId
  UPDATE[dbo].[tblSMXMLTagAttribute]
  SET [intImportFileColumnDetailId] = @intImportFileColumnDetailId
       ,[intSequence] = 3
       ,[strTagAttribute] = 'name'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDefaultValue] = ' '
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intTagAttributeId = @intTagAttributeId
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 4 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  INSERT INTO [dbo].[tblSMXMLTagAttribute]
      ([intImportFileColumnDetailId],[intSequence],[strTagAttribute],[strTable],[strColumnName],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileColumnDetailId,4,'periodSeqNum',NULL,NULL,' ',1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 4 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  SELECT @intTagAttributeId = intTagAttributeId FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 4 AND intImportFileColumnDetailId = @intImportFileColumnDetailId
  UPDATE[dbo].[tblSMXMLTagAttribute]
  SET [intImportFileColumnDetailId] = @intImportFileColumnDetailId
       ,[intSequence] = 4
       ,[strTagAttribute] = 'periodSeqNum'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDefaultValue] = ' '
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intTagAttributeId = @intTagAttributeId
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 5 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  INSERT INTO [dbo].[tblSMXMLTagAttribute]
      ([intImportFileColumnDetailId],[intSequence],[strTagAttribute],[strTable],[strColumnName],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileColumnDetailId,5,'periodBeginDate',NULL,NULL,' ',1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 5 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  SELECT @intTagAttributeId = intTagAttributeId FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 5 AND intImportFileColumnDetailId = @intImportFileColumnDetailId
  UPDATE[dbo].[tblSMXMLTagAttribute]
  SET [intImportFileColumnDetailId] = @intImportFileColumnDetailId
       ,[intSequence] = 5
       ,[strTagAttribute] = 'periodBeginDate'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDefaultValue] = ' '
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intTagAttributeId = @intTagAttributeId
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 6 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  INSERT INTO [dbo].[tblSMXMLTagAttribute]
      ([intImportFileColumnDetailId],[intSequence],[strTagAttribute],[strTable],[strColumnName],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileColumnDetailId,6,'periodEndDate',NULL,NULL,' ',1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 6 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  SELECT @intTagAttributeId = intTagAttributeId FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 6 AND intImportFileColumnDetailId = @intImportFileColumnDetailId
  UPDATE[dbo].[tblSMXMLTagAttribute]
  SET [intImportFileColumnDetailId] = @intImportFileColumnDetailId
       ,[intSequence] = 6
       ,[strTagAttribute] = 'periodEndDate'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDefaultValue] = ' '
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intTagAttributeId = @intTagAttributeId
END

--Delete Rows Not Included in LEVEL 2   Attributes(6x)
DELETE FROM tblSMXMLTagAttribute WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId AND intSequence NOT IN (1,2,3,4,5,6)


--LEVEL 7   Attributes(2x)
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 7 AND strXMLTag = 'deptBase'
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 1 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  INSERT INTO [dbo].[tblSMXMLTagAttribute]
      ([intImportFileColumnDetailId],[intSequence],[strTagAttribute],[strTable],[strColumnName],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileColumnDetailId,1,'sysid',NULL,NULL,' ',1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 1 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  SELECT @intTagAttributeId = intTagAttributeId FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 1 AND intImportFileColumnDetailId = @intImportFileColumnDetailId
  UPDATE[dbo].[tblSMXMLTagAttribute]
  SET [intImportFileColumnDetailId] = @intImportFileColumnDetailId
       ,[intSequence] = 1
       ,[strTagAttribute] = 'sysid'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDefaultValue] = ' '
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intTagAttributeId = @intTagAttributeId
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 2 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  INSERT INTO [dbo].[tblSMXMLTagAttribute]
      ([intImportFileColumnDetailId],[intSequence],[strTagAttribute],[strTable],[strColumnName],[strDefaultValue],[ysnActive],[intConcurrencyId])
  VALUES 
      (@intImportFileColumnDetailId,2,'deptType',NULL,NULL,' ',1,1)
END
ELSE IF EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 2 AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
  SELECT @intTagAttributeId = intTagAttributeId FROM dbo.tblSMXMLTagAttribute WHERE intSequence = 2 AND intImportFileColumnDetailId = @intImportFileColumnDetailId
  UPDATE[dbo].[tblSMXMLTagAttribute]
  SET [intImportFileColumnDetailId] = @intImportFileColumnDetailId
       ,[intSequence] = 2
       ,[strTagAttribute] = 'deptType'
       ,[strTable] = NULL
       ,[strColumnName] = NULL
       ,[strDefaultValue] = ' '
       ,[ysnActive] = 1
       ,[intConcurrencyId] = 1
  WHERE intTagAttributeId = @intTagAttributeId
END

--Delete Rows Not Included in LEVEL 7   Attributes(2x)
DELETE FROM tblSMXMLTagAttribute WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId AND intSequence NOT IN (1,2)


GO