﻿


GO

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileHeader] WHERE [strLayoutTitle] = 'Passport - MSM')
INSERT INTO [dbo].[tblSMImportFileHeader]
           ([strLayoutTitle]			,[strFileType]    ,[strFieldDelimiter]	,[strXMLType]
           ,[strXMLInitiater]			,[ysnActive]      ,[intConcurrencyId])
     VALUES
           ('Passport - MSM'				,'XML'			  ,NULL		            ,'Inbound'
           ,'<?xml version="1.0"?>'		,1		          ,0)

DECLARE @intImportFileHeaderId INT

SELECT @intImportFileHeaderId = intImportFileHeaderId FROM [dbo].[tblSMImportFileHeader] WHERE [strLayoutTitle] = 'Passport - MSM'


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

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'BusinessDate' AND intLevel = 11
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,11
			   ,4			 				,'BusinessDate'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,7
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'BeginDate' AND intLevel = 12
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,12
			   ,5			 				,'BeginDate'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,7
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'BeginTime' AND intLevel = 13
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,13
			   ,6			 				,'BeginTime'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,7
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'EndDate' AND intLevel = 14
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,14
			   ,7			 				,'EndDate'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,7
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'EndTime' AND intLevel = 15
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,15
			   ,8			 				,'EndTime'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL							,7
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MSMDetail' AND intLevel = 16
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,16
			   ,2			 				,'MSMDetail'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'						,6
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MiscellaneousSummaryCodes' AND intLevel = 17
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,17
			   ,1			 				,'MiscellaneousSummaryCodes'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'						,16
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MiscellaneousSummaryCode' AND intLevel = 18
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,18
			   ,1			 				,'MiscellaneousSummaryCode'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						,17
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MiscellaneousSummarySubCode' AND intLevel = 19
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,19
			   ,2			 				,'MiscellaneousSummarySubCode'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						,17
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MiscellaneousSummarySubCodeModifier' AND intLevel = 20
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,20
			   ,3			 				,'MiscellaneousSummarySubCodeModifier'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						,17
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MSMSalesTotals' AND intLevel = 21
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,21
			   ,2			 				,'MSMSalesTotals'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'						,16
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'Tender' AND intLevel = 22
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,22
			   ,1			 				,'Tender'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'						,21
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'TenderCode' AND intLevel = 23
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,23
			   ,1			 				,'TenderCode'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						,22
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'TenderSubCode' AND intLevel = 24
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,24
			   ,2			 				,'TenderSubCode'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						,22
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MiscellaneousSummaryAmount' AND intLevel = 25
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,25
			   ,2			 				,'MiscellaneousSummaryAmount'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						,21
			   ,NULL					    ,1							   ,1)
END

IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'MiscellaneousSummaryCount' AND intLevel = 26
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,26
			   ,3			 				,'MiscellaneousSummaryCount'		   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						,21
			   ,NULL					    ,1							   ,1)
END

GO