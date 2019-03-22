


GO

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileHeader WHERE strLayoutTitle = 'Nucleus - ISM')
BEGIN
	
	INSERT INTO [dbo].[tblSMImportFileHeader]
           ([strLayoutTitle]			,[strFileType]    ,[strFieldDelimiter]	,[strXMLType]
           ,[strXMLInitiater]			,[ysnActive]      ,[intConcurrencyId])
     VALUES
           ('Nucleus - ISM'				,'XML'			  ,NULL		            ,'Inbound'
           ,'<?xml version="1.0"?>'		,1		          ,0)
END

DECLARE @intImportFileHeaderId INT
SELECT @intImportFileHeaderId = intImportFileHeaderId FROM dbo.tblSMImportFileHeader WHERE strLayoutTitle = 'Nucleus - ISM'

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
			   ,NULL			 		    ,'NAXML-MovementReport'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,0
			   ,NULL					    ,1							   ,1)
END

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
			   ,1			 		    ,'TransmissionHeader'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'					   ,1
			   ,NULL					    ,1							   ,1)
END

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


IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'ItemSalesMovement' AND intLevel = 6
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,6
			   ,2			 				,'ItemSalesMovement'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'						,1
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MovementHeader' AND intLevel = 7
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,7
			   ,1			 				,'MovementHeader'			   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'					   ,6
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'ReportSequenceNumber' AND intLevel = 8
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,8
			   ,1			 				,'ReportSequenceNumber'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,7
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'PrimaryReportPeriod' AND intLevel = 9
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,9
			   ,2			 				,'PrimaryReportPeriod'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,7
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'SecondaryReportPeriod' AND intLevel = 10
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,10
			   ,3			 				,'SecondaryReportPeriod'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,7
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'BeginDate' AND intLevel = 11
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,11
			   ,4			 				,'BeginDate'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,7
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'BeginTime' AND intLevel = 12
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,12
			   ,5			 				,'BeginTime'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,7
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'EndDate' AND intLevel = 13
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,13
			   ,6			 				,'EndDate'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,7
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'EndTime' AND intLevel = 14
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,14
			   ,7			 				,'EndTime'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,7
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'ISMDetail' AND intLevel = 15
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,15
			   ,2			 				,'ISMDetail'					,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'						,6
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'ItemCode' AND intLevel = 16
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,16
			   ,1			 				,'ItemCode'					,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,15
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'POSCodeFormat' AND intLevel = 17
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,17
			   ,1			 				,'POSCodeFormat'					,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,16
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'POSCode' AND intLevel = 18
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,18
			   ,2			 				,'POSCode'					,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,16
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'POSCodeModifier' AND intLevel = 19
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,19
			   ,3			 				,'POSCodeModifier'					,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,16
			   ,NULL					    ,1							   ,1)
END


IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'ItemID' AND intLevel = 20
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,20
			   ,2			 				,'ItemID'					,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,15
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'Description' AND intLevel = 21
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,21
			   ,3			 				,'Description'					,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,15
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MerchandiseCode' AND intLevel = 22
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,22
			   ,4			 				,'MerchandiseCode'					,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,15
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'SellingUnits' AND intLevel = 23
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,23
			   ,5			 				,'SellingUnits'					,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,15
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'ISMReasonSummary' AND intLevel = 24
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,24
			   ,6			 				,'ISMReasonSummary'			,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,15
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'ISMReason' AND intLevel = 25
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,25
			   ,1			 				,'ISMReason'			,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,24
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'ISMSalesTotals' AND intLevel = 26
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,26
			   ,2			 				,'ISMSalesTotals'			,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,24
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'SalesQuantity' AND intLevel = 27
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,27
			   ,1			 				,'SalesQuantity'			,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,26
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'SalesAmount' AND intLevel = 28
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,28
			   ,2			 				,'SalesAmount'			,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,26
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'TransactionCount' AND intLevel = 29
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,29
			   ,3			 				,'TransactionCount'			,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,26
			   ,NULL					    ,1							   ,1)
END

DECLARE @intImportFileColumnDetailId INT
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId 
AND intLevel = 17 AND strXMLTag = 'POSCodeFormat'

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