
GO

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileHeader] WHERE [strLayoutTitle] = 'Nucleus - MSM')
INSERT INTO [dbo].[tblSMImportFileHeader]
           ([strLayoutTitle]			,[strFileType]    ,[strFieldDelimiter]	,[strXMLType]
           ,[strXMLInitiater]			,[ysnActive]      ,[intConcurrencyId])
     VALUES
           ('Nucleus - MSM'				,'XML'			  ,NULL		            ,'Inbound'
           ,'<?xml version="1.0"?>'		,1		          ,0)

DECLARE @intImportFileHeaderId INT

SELECT @intImportFileHeaderId = intImportFileHeaderId FROM [dbo].[tblSMImportFileHeader] WHERE [strLayoutTitle] = 'Nucleus - MSM'


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

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MiscellaneousSummaryMovement' AND intLevel = 6
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,6
			   ,2			 				,'MiscellaneousSummaryMovement'		   ,'tblSTPriceBookStaging'
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
			   ,1			 				,'MovementHeader'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'						,6
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

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'SalesMovementHeader' AND intLevel = 15
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,15
			   ,2			 				,'SalesMovementHeader'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'						,6
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'RegisterID' AND intLevel = 16
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,16
			   ,1			 				,'RegisterID'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,15
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'CashierID' AND intLevel = 17
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,17
			   ,2			 				,'CashierID'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,15
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MSMDetail' AND intLevel = 18
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,18
			   ,3			 				,'MSMDetail'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'						,6
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MiscellaneousSummaryCodes' AND intLevel = 19
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,19
			   ,1			 				,'MiscellaneousSummaryCodes'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'						,18
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MiscellaneousSummaryCode' AND intLevel = 20
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,20
			   ,1			 				,'MiscellaneousSummaryCode'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						,19
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MiscellaneousSummarySubCode' AND intLevel = 21
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,21
			   ,2			 				,'MiscellaneousSummarySubCode'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						,19
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MSMSalesTotals' AND intLevel = 22
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,22
			   ,2			 				,'MSMSalesTotals'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'						,18
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MiscellaneousSummaryAmount' AND intLevel = 23
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,23
			   ,1			 				,'MiscellaneousSummaryAmount'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						,22
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MiscellaneousSummaryCount' AND intLevel = 24
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,24
			   ,2			 				,'MiscellaneousSummaryCount'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						,22
			   ,NULL					    ,1							   ,1)
END

GO