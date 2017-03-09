﻿
GO
--HEADER
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileHeader WHERE strLayoutTitle = 'Radiant - ISM')
BEGIN
	
	INSERT INTO [dbo].[tblSMImportFileHeader]
           ([strLayoutTitle]			,[strFileType]    ,[strFieldDelimiter]	,[strXMLType]
           ,[strXMLInitiater]			,[ysnActive]      ,[intConcurrencyId])
     VALUES
           ('Radiant - ISM'				,'XML'			  ,NULL		            ,'Inbound'
           ,'<?xml version="1.0" encoding="utf-8"?>'		,1		          ,0)
END

DECLARE @intImportFileHeaderId INT
SELECT @intImportFileHeaderId = intImportFileHeaderId FROM dbo.tblSMImportFileHeader WHERE strLayoutTitle = 'Radiant - ISM'

--LEVEL 1
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'NAXML-MovementReport' AND intLevel = 1
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,1
			   ,0			 		    ,'NAXML-MovementReport'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,0
			   ,NULL					    ,1							   ,1)
END

--LEVEL 2
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'TransmissionHeader' AND intLevel = 2
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,2
			   ,1			 		        ,'TransmissionHeader'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'					   ,1
			   ,NULL					    ,1							   ,1)
END

--LEVEL 3
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'StoreLocationID' AND intLevel = 3
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,3
			   ,1			 				,'StoreLocationID'			   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,2
			   ,NULL					    ,1							   ,1)
END

--LEVEL 4
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'VendorName' AND intLevel = 4
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,4
			   ,2			 				,'VendorName'					,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,2
			   ,NULL					    ,1							   ,1)
END

--LEVEL 5
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'VendorModelVersion' AND intLevel = 5
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,5
			   ,3			 				,'VendorModelVersion'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,2
			   ,NULL					    ,1							   ,1)
END

--LEVEL 6
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'Extension' AND intLevel = 6
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,6
			   ,4			 				,'Extension'				   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'					   ,2
			   ,NULL					    ,1							   ,1)
END

--LEVEL 7
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'radiant:StoreName' AND intLevel = 7
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,7
			   ,1			 				,'radiant:StoreName'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,6
			   ,NULL					    ,1							   ,1)
END

--LEVEL 8
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'radiant:BusinessDate' AND intLevel = 8
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,8
			   ,2			 				,'radiant:BusinessDate'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,6
			   ,NULL					    ,1							   ,1)
END

--LEVEL 9
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'ItemSalesMovement' AND intLevel = 9
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,9
			   ,2			 				,'ItemSalesMovement'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'						,1
			   ,NULL					    ,1							   ,1)
END

--LEVEL 10
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MovementHeader' AND intLevel = 10
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,10
			   ,1			 				,'MovementHeader'			   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'					   ,9
			   ,NULL					    ,1							   ,1)
END

--LEVEL 11
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'ReportSequenceNumber' AND intLevel = 11
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,11
			   ,1			 				,'ReportSequenceNumber'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,10
			   ,NULL					    ,1							   ,1)
END

--LEVEL 12
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'PrimaryReportPeriod' AND intLevel = 12
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,12
			   ,2			 				,'PrimaryReportPeriod'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,10
			   ,NULL					    ,1							   ,1)
END

--LEVEL 13
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'SecondaryReportPeriod' AND intLevel = 13
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,13
			   ,3			 				,'SecondaryReportPeriod'	   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,10
			   ,NULL					    ,1							   ,1)
END

--LEVEL 14
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'BusinessDate' AND intLevel = 14
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,14
			   ,4			 				,'BusinessDate'		           ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,10
			   ,NULL					    ,1							   ,1)
END

--LEVEL 15
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'BeginDate' AND intLevel = 15
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,15
			   ,5			 				,'BeginDate'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,10
			   ,NULL					    ,1							   ,1)
END

--LEVEL 16
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'BeginTime' AND intLevel = 16
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,16
			   ,6			 				,'BeginTime'		           ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,10
			   ,NULL					    ,1							   ,1)
END

--LEVEL 17
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'EndDate' AND intLevel = 17
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,17
			   ,7			 				,'EndDate'		               ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,10
			   ,NULL					    ,1							   ,1)
END

--LEVEL 18
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'EndTime' AND intLevel = 18
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,18
			   ,8			 				,'EndTime'		               ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,10
			   ,NULL					    ,1							   ,1)
END

--LEVEL 19
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'SalesMovementHeader' AND intLevel = 19
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,19
			   ,2			 				,'SalesMovementHeader'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'					   ,9
			   ,NULL					    ,1							   ,1)
END

--LEVEL 20
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'RegisterID' AND intLevel = 20
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,20
			   ,1			 				,'RegisterID'		           ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,19
			   ,NULL					    ,1							   ,1)
END

--LEVEL 21
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'CashierID' AND intLevel = 21
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,21
			   ,2			 				,'CashierID'		           ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,19
			   ,NULL					    ,1							   ,1)
END

--LEVEL 22
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'TillID' AND intLevel = 22
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,22
			   ,3			 				,'TillID'		               ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,19
			   ,NULL					    ,1							   ,1)
END

--LEVEL 23
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'EmployeeNumber' AND intLevel = 23
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,23
			   ,4			 				,'EmployeeNumber'		       ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,19
			   ,NULL					    ,1							   ,1)
END

--LEVEL 24
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'ISMDetail' AND intLevel = 24
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,24
			   ,3			 				,'ISMDetail'				   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'					   ,9
			   ,NULL					    ,1							   ,1)
END

--LEVEL 25
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'ItemCode' AND intLevel = 25
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,25
			   ,1			 				,'ItemCode'					   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'					   ,24
			   ,NULL					    ,1							   ,1)
END

--LEVEL 26
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'POSCodeFormat' AND intLevel = 26
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,26
			   ,1			 				,'POSCodeFormat'			   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,25
			   ,NULL					    ,1							   ,1)
END

--LEVEL 27
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'POSCode' AND intLevel = 27
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,27
			   ,2			 				,'POSCode'					   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,25
			   ,NULL					    ,1							   ,1)
END

--LEVEL 28
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'POSCodeModifier' AND intLevel = 28
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,28
			   ,3			 				,'POSCodeModifier'			   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,25
			   ,NULL					    ,1							   ,1)
END

--LEVEL 29
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'InventoryItemID' AND intLevel = 29
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,29
			   ,4			 				,'InventoryItemID'			   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,25
			   ,NULL					    ,1							   ,1)
END

--LEVEL 30
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'ItemID' AND intLevel = 30
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,30
			   ,2			 				,'ItemID'					   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,24
			   ,NULL					    ,1							   ,1)
END

--LEVEL 31
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'Description' AND intLevel = 31
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,31
			   ,3			 				,'Description'				   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,24
			   ,NULL					    ,1							   ,1)
END

--LEVEL 32
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MerchandiseCode' AND intLevel = 32
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,32
			   ,4			 				,'MerchandiseCode'			   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,24
			   ,NULL					    ,1							   ,1)
END

--LEVEL 33
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'SellingUnits' AND intLevel = 33
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,33
			   ,5			 				,'SellingUnits'				   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,24
			   ,NULL					    ,1							   ,1)
END

--LEVEL 34
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'ISMSellPriceSummary' AND intLevel = 34
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,34
			   ,6			 				,'ISMSellPriceSummary'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'					   ,24
			   ,NULL					    ,1							   ,1)
END

--LEVEL 35
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'ActualSalesPrice' AND intLevel = 35
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,35
			   ,1			 				,'ActualSalesPrice'			   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,34
			   ,NULL					    ,1							   ,1)
END

--LEVEL 36
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'ISMSalesTotals' AND intLevel = 36
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,36
			   ,2			 				,'ISMSalesTotals'			   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'					   ,34
			   ,NULL					    ,1							   ,1)
END

--LEVEL 37
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'SalesQuantity' AND intLevel = 37
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,37
			   ,1			 				,'SalesQuantity'			   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,36
			   ,NULL					    ,1							   ,1)
END

--LEVEL 38
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'SalesAmount' AND intLevel = 38
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,38
			   ,2			 				,'SalesAmount'			       ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,36
			   ,NULL					    ,1							   ,1)
END

--LEVEL 39
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'DiscountAmount' AND intLevel = 39
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,39
			   ,3			 				,'DiscountAmount'			   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,36
			   ,NULL					    ,1							   ,1)
END

--LEVEL 40
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'DiscountCount' AND intLevel = 40
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,40
			   ,4			 				,'DiscountCount'			   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,36
			   ,NULL					    ,1							   ,1)
END

--LEVEL 41
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'PromotionAmount' AND intLevel = 41
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,41
			   ,5			 				,'PromotionAmount'			   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,36
			   ,NULL					    ,1							   ,1)
END

--LEVEL 42
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'PromotionCount' AND intLevel = 42
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,42
			   ,6			 				,'PromotionCount'			   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,36
			   ,NULL					    ,1							   ,1)
END

--LEVEL 43
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'RefundAmount' AND intLevel = 43
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,43
			   ,7			 				,'RefundAmount'			       ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,36
			   ,NULL					    ,1							   ,1)
END

--LEVEL 44
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'RefundCount' AND intLevel = 44
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,44
			   ,8			 				,'RefundCount'			       ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,36
			   ,NULL					    ,1							   ,1)
END

--LEVEL 45
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'TransactionCount' AND intLevel = 45
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,45
			   ,9			 				,'TransactionCount'			   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,36
			   ,NULL					    ,1							   ,1)
END

DECLARE @intImportFileColumnDetailId INT

--LEVEL 1, Attributes(2x)
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId 
AND intLevel = 1 AND strXMLTag = 'NAXML-MovementReport'
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'xmlns:radiant' AND intSequence = 1
AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN

		INSERT INTO [dbo].[tblSMXMLTagAttribute]
			   ([intImportFileColumnDetailId]	,[intSequence]			   ,[strTagAttribute]
			   ,[strTable]					   ,[strColumnName]			   ,[strDefaultValue]
			   ,[ysnActive]					   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileColumnDetailId	,1						   ,'xmlns:radiant'
			   ,NULL							,NULL					   ,'http://www.radiantsystems.com/NAXML-Extension'
			   ,1							   ,1)

END
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'xmlns' AND intSequence = 2
AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN

		INSERT INTO [dbo].[tblSMXMLTagAttribute]
			   ([intImportFileColumnDetailId]	,[intSequence]			   ,[strTagAttribute]
			   ,[strTable]					   ,[strColumnName]			   ,[strDefaultValue]
			   ,[ysnActive]					   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileColumnDetailId	,2						   ,'xmlns'
			   ,NULL							,NULL					   ,'http://www.naxml.org/POSBO/Vocabulary/2003-10-16'
			   ,1							    ,1)

END

--LEVEL 26 Attributes(1x)
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId 
AND intLevel = 26 AND strXMLTag = 'POSCodeFormat'
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'format' AND intSequence = 1
AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN

		INSERT INTO [dbo].[tblSMXMLTagAttribute]
			   ([intImportFileColumnDetailId]	,[intSequence]			   ,[strTagAttribute]
			   ,[strTable]					   ,[strColumnName]			   ,[strDefaultValue]
			   ,[ysnActive]					   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileColumnDetailId	,1						   ,'format'
			   ,'tblSTPriceBookStaging'		   ,'strPOSDescription'		   ,NULL
			   ,1							   ,1)
END

GO