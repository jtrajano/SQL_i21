
GO
--HEADER
IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileHeader] WHERE [strLayoutTitle] = 'Commander - Trans Log')
INSERT INTO [dbo].[tblSMImportFileHeader]
           ([strLayoutTitle]			,[strFileType]    ,[strFieldDelimiter]	,[strXMLType]
           ,[strXMLInitiater]			,[ysnActive]      ,[intConcurrencyId])
     VALUES
           ('Commander - Trans Log'				,'XML'			  ,NULL		            ,'Inbound'
           ,'<?xml version="1.0"?>'	  ,1		            ,0)

DECLARE @intImportFileHeaderId INT
SELECT @intImportFileHeaderId = intImportFileHeaderId FROM [dbo].[tblSMImportFileHeader] WHERE [strLayoutTitle] = 'Commander - Trans Log'

--LEVEL 1
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'transSet' AND intLevel = 1
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,1
			   ,0			 		        ,'transSet'		               ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'						   ,0
			   ,NULL					    ,1							   ,1)
END

--LEVEL 2
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'openedTime' AND intLevel = 2
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,2
			   ,1			 		        ,'openedTime'				   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL					   ,1
			   ,NULL					    ,1							   ,1)
END

--LEVEL 3
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'closedTime' AND intLevel = 3
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,3
			   ,2			 				,'closedTime'			       ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,1
			   ,NULL					    ,1							   ,1)
END

--LEVEL 4
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'startTotals' AND intLevel = 4
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,4
			   ,3			 				,'startTotals'				   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'					   ,1
			   ,NULL					    ,1							   ,1)
END

--LEVEL 5
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'insideSales' AND intLevel = 5
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,5
			   ,1			 				,'insideSales'		           ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,4
			   ,NULL					    ,1							   ,1)
END

--LEVEL 6
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'insideGrand' AND intLevel = 6
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,6
			   ,2			 				,'insideGrand'		           ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL					       ,4
			   ,NULL					    ,1							   ,1)
END

--LEVEL 7
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'outsideSales' AND intLevel = 7
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,7
			   ,3			 				,'outsideSales'		           ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,4
			   ,NULL					    ,1							   ,1)
END

--LEVEL 8
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'outsideGrand' AND intLevel = 8
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,8
			   ,4			 				,'outsideGrand'		           ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,4
			   ,NULL					    ,1							   ,1)
END

--LEVEL 9
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'overallSales' AND intLevel = 9
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,9
			   ,5			 				,'overallSales'                ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL					       ,4
			   ,NULL					    ,1							   ,1)
END

--LEVEL 10
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'overallGrand' AND intLevel = 10
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,10
			   ,6			 				,'overallGrand'		           ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL					       ,4
			   ,NULL					    ,1							   ,1)
END

--LEVEL 11
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trans' AND intLevel = 11
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,11
			   ,4			 				,'trans'		               ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'					   ,1
			   ,NULL					    ,1							   ,1)
END

--LEVEL 12
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trHeader' AND intLevel = 12
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,12
			   ,1			 				,'trHeader'		               ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'					   ,11
			   ,NULL					    ,1							   ,1)
END

--LEVEL 13
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'termMsgSN' AND intLevel = 13
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,13
			   ,1			 				,'termMsgSN'	               ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,12
			   ,NULL					    ,1							   ,1)
END

--LEVEL 14
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trTickNum' AND intLevel = 14
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,14
			   ,2			 				,'trTickNum'		           ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'					   ,12
			   ,NULL					    ,1							   ,1)
END

--LEVEL 15
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'posNum' AND intLevel = 15
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,15
			   ,1			 				,'posNum'		               ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,14
			   ,NULL					    ,1							   ,1)
END

--LEVEL 16
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trSeq' AND intLevel = 16
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,16
			   ,2			 				,'trSeq'		               ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,14
			   ,NULL					    ,1							   ,1)
END

--LEVEL 17
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'period' AND intLevel = 17
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,17
			   ,3			 				,'period'		               ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,12
			   ,NULL					    ,1							   ,1)
END

--LEVEL 18
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'date' AND intLevel = 18
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,18
			   ,4			 				,'date'		                   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,12
			   ,NULL					    ,1							   ,1)
END

--LEVEL 19
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'duration' AND intLevel = 19
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,19
			   ,5			 				,'duration'		               ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL					       ,12
			   ,NULL					    ,1							   ,1)
END

--LEVEL 20
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'till' AND intLevel = 20
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,20
			   ,6			 				,'till'		                   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,12
			   ,NULL					    ,1							   ,1)
END

--LEVEL 21
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'cashier' AND intLevel = 21
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,21
			   ,7			 				,'cashier'		               ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,12
			   ,NULL					    ,1							   ,1)
END

--LEVEL 22
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'storeNumber' AND intLevel = 22
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,22
			   ,8			 				,'storeNumber'		           ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,12
			   ,NULL					    ,1							   ,1)
END

--LEVEL 23
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trFuelOnlyCst' AND intLevel = 23
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,23
			   ,9			 				,'trFuelOnlyCst'		       ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,12
			   ,NULL					    ,1							   ,1)
END

--LEVEL 24
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trValue' AND intLevel = 24
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,24
			   ,2			 				,'trValue'		               ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'					   ,11
			   ,NULL					    ,1							   ,1)
END

--LEVEL 25
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trTotNoTax' AND intLevel = 25
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,25
			   ,1			 				,'trTotNoTax'				   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL					       ,24
			   ,NULL					    ,1							   ,1)
END

--LEVEL 26
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trTotWTax' AND intLevel = 26
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,26
			   ,2			 				,'trTotWTax'	               ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,24
			   ,NULL					    ,1							   ,1)
END

--LEVEL 27
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trTotTax' AND intLevel = 27
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,27
			   ,3			 				,'trTotTax'                    ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,24
			   ,NULL					    ,1							   ,1)
END

--LEVEL 28
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trTax' AND intLevel = 28
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId]			,[intLevel]
			   ,[intPosition]				,[strXMLTag]							,[strTable]
			   ,[strColumnName]				,[strDataType]							,[intLength]
			   ,[strDefaultValue]			,[ysnActive]							,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL									,28
			   ,4			 				,'trTax'								,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL									,24
			   ,NULL					    ,1										,1)
END

--LEVEL 29
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trCurrTot' AND intLevel = 29
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,29
			   ,5			 				,'trCurrTot'				   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL					       ,24
			   ,NULL					    ,1							   ,1)
END

--LEVEL 30
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trSTotalizer' AND intLevel = 30
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,30
			   ,6			 				,'trSTotalizer'				   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL					       ,24
			   ,NULL					    ,1							   ,1)
END

--LEVEL 31
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trGTotalizer' AND intLevel = 31
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,31
			   ,7			 				,'trGTotalizer'				   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,24
			   ,NULL					    ,1							   ,1)
END

--LEVEL 32
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trLines' AND intLevel = 32
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,32
			   ,3			 				,'trLines'					   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'					   ,11
			   ,NULL					    ,1							   ,1)
END

--LEVEL 33
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trLine' AND intLevel = 33
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,33
			   ,1			 				,'trLine'					   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'					   ,32
			   ,NULL					    ,1							   ,1)
END

--LEVEL 34
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trlTaxes' AND intLevel = 34
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,34
			   ,1			 				,'trlTaxes'					   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,33
			   ,NULL					    ,1							   ,1)
END

--LEVEL 35
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trlFlags' AND intLevel = 35
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,35
			   ,2			 				,'trlFlags'		               ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,33
			   ,NULL					    ,1							   ,1)
END

--LEVEL 36
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trlUpdDepCust' AND intLevel = 36
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,36
			   ,1			 				,'trlUpdDepCust'               ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,35
			   ,NULL					    ,1							   ,1)
END

--LEVEL 37
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trlCatCust' AND intLevel = 37
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,37
			   ,2			 				,'trlCatCust'				   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,35
			   ,NULL					    ,1							   ,1)
END

--LEVEL 38
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trlFuelOnly' AND intLevel = 38
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,38
			   ,3			 				,'trlFuelOnly'				   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,35
			   ,NULL					    ,1							   ,1)
END

--LEVEL 39
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trlFuelSale' AND intLevel = 39
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,39
			   ,4			 				,'trlFuelSale'				   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,35
			   ,NULL					    ,1							   ,1)
END

--LEVEL 40
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trlDept' AND intLevel = 40
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,40
			   ,3			 				,'trlDept'				       ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,33
			   ,NULL					    ,1							   ,1)
END

--LEVEL 41
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trlCat' AND intLevel = 41
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,41
			   ,4			 				,'trlCat'				       ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,33
			   ,NULL					    ,1							   ,1)
END

--LEVEL 42
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trlNetwCode' AND intLevel = 42
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,42
			   ,5			 				,'trlNetwCode'				   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,33
			   ,NULL					    ,1							   ,1)
END

--LEVEL 43
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trlQty' AND intLevel = 43
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,43
			   ,6			 				,'trlQty'				       ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,33
			   ,NULL					    ,1							   ,1)
END

--LEVEL 44
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trlSign' AND intLevel = 44
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,44
			   ,7			 				,'trlSign'				       ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,33
			   ,NULL					    ,1							   ,1)
END

--LEVEL 45
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trlUnitPrice' AND intLevel = 45
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,45
			   ,8			 				,'trlUnitPrice'				   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,33
			   ,NULL					    ,1							   ,1)
END

--LEVEL 46
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trlLineTot' AND intLevel = 46
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,46
			   ,9			 				,'trlLineTot'				   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,33
			   ,NULL					    ,1							   ,1)
END

--LEVEL 47
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trlDesc' AND intLevel = 47
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,47
			   ,9			 				,'trlDesc'				       ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,33
			   ,NULL					    ,1							   ,1)
END

--LEVEL 48
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trPaylines' AND intLevel = 48
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,48
			   ,4			 				,'trPaylines'				   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'					   ,11
			   ,NULL					    ,1							   ,1)
END

--LEVEL 49
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trPayline' AND intLevel = 49
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,49
			   ,1			 				,'trPayline'				   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,'Header'					   ,48
			   ,NULL					    ,1							   ,1)
END

--LEVEL 50
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trpPaycode' AND intLevel = 50
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,50
			   ,1			 				,'trpPaycode'				   ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,49
			   ,NULL					    ,1							   ,1)
END

--LEVEL 51
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE strXMLTag = 'trpAmt' AND intLevel = 51
AND intImportFileHeaderId = @intImportFileHeaderId)
BEGIN
		INSERT INTO [dbo].[tblSMImportFileColumnDetail]
			   ([intImportFileHeaderId]		,[intImportFileRecordMarkerId] ,[intLevel]
			   ,[intPosition]				,[strXMLTag]				   ,[strTable]
			   ,[strColumnName]				,[strDataType]				   ,[intLength]
			   ,[strDefaultValue]			,[ysnActive]				   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileHeaderId		,NULL						   ,51
			   ,2			 				,'trpAmt'				       ,'tblSTPriceBookStaging'
			   ,NULL		 			    ,NULL						   ,49
			   ,NULL					    ,1							   ,1)
END




DECLARE @intImportFileColumnDetailId INT

--LEVEL 11, Attributes(2x)
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId 
AND intLevel = 11 AND strXMLTag = 'trans'
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'type' AND intSequence = 1
AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN

		INSERT INTO [dbo].[tblSMXMLTagAttribute]
			   ([intImportFileColumnDetailId]	,[intSequence]			   ,[strTagAttribute]
			   ,[strTable]					   ,[strColumnName]			   ,[strDefaultValue]
			   ,[ysnActive]					   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileColumnDetailId	,1						   ,'type'
			   ,NULL							,NULL					   ,'NULL'
			   ,1							   ,1)

END
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'recalled' AND intSequence = 2
AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN

		INSERT INTO [dbo].[tblSMXMLTagAttribute]
			   ([intImportFileColumnDetailId]	,[intSequence]			   ,[strTagAttribute]
			   ,[strTable]					   ,[strColumnName]			   ,[strDefaultValue]
			   ,[ysnActive]					   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileColumnDetailId	,2						   ,'recalled'
			   ,NULL							,NULL					   ,'NULL'
			   ,1							    ,1)

END

--LEVEL 13, Attributes(2x)
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId 
AND intLevel = 13 AND strXMLTag = 'termMsgSN'
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'type' AND intSequence = 1
AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN

		INSERT INTO [dbo].[tblSMXMLTagAttribute]
			   ([intImportFileColumnDetailId]	,[intSequence]			   ,[strTagAttribute]
			   ,[strTable]					   ,[strColumnName]			   ,[strDefaultValue]
			   ,[ysnActive]					   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileColumnDetailId	,1						   ,'type'
			   ,NULL							,NULL					   ,'NULL'
			   ,1							   ,1)

END
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'term' AND intSequence = 2
AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN

		INSERT INTO [dbo].[tblSMXMLTagAttribute]
			   ([intImportFileColumnDetailId]	,[intSequence]			   ,[strTagAttribute]
			   ,[strTable]					   ,[strColumnName]			   ,[strDefaultValue]
			   ,[ysnActive]					   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileColumnDetailId	,2						   ,'term'
			   ,NULL							,NULL					   ,'NULL'
			   ,1							    ,1)

END

--LEVEL 17, Attributes(3x)
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId 
AND intLevel = 17 AND strXMLTag = 'period'
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'level' AND intSequence = 1
AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN

		INSERT INTO [dbo].[tblSMXMLTagAttribute]
			   ([intImportFileColumnDetailId]	,[intSequence]			   ,[strTagAttribute]
			   ,[strTable]					   ,[strColumnName]			   ,[strDefaultValue]
			   ,[ysnActive]					   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileColumnDetailId	,1						   ,'level'
			   ,NULL							,NULL					   ,'NULL'
			   ,1							   ,1)

END
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'seq' AND intSequence = 2
AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN

		INSERT INTO [dbo].[tblSMXMLTagAttribute]
			   ([intImportFileColumnDetailId]	,[intSequence]			   ,[strTagAttribute]
			   ,[strTable]					   ,[strColumnName]			   ,[strDefaultValue]
			   ,[ysnActive]					   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileColumnDetailId	,2						   ,'seq'
			   ,NULL							,NULL					   ,'NULL'
			   ,1							   ,1)

END
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'name' AND intSequence = 3
AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN

		INSERT INTO [dbo].[tblSMXMLTagAttribute]
			   ([intImportFileColumnDetailId]	,[intSequence]			   ,[strTagAttribute]
			   ,[strTable]					   ,[strColumnName]			   ,[strDefaultValue]
			   ,[ysnActive]					   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileColumnDetailId	,3						   ,'name'
			   ,NULL							,NULL					   ,'NULL'
			   ,1							   ,1)

END

--LEVEL 21, Attributes(5x)
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId 
AND intLevel = 21 AND strXMLTag = 'cashier'
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'sysid' AND intSequence = 1
AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN

		INSERT INTO [dbo].[tblSMXMLTagAttribute]
			   ([intImportFileColumnDetailId]	,[intSequence]			   ,[strTagAttribute]
			   ,[strTable]					   ,[strColumnName]			   ,[strDefaultValue]
			   ,[ysnActive]					   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileColumnDetailId	,1						   ,'sysid'
			   ,NULL							,NULL					   ,'NULL'
			   ,1							   ,1)

END
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'empNum' AND intSequence = 2
AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN

		INSERT INTO [dbo].[tblSMXMLTagAttribute]
			   ([intImportFileColumnDetailId]	,[intSequence]			   ,[strTagAttribute]
			   ,[strTable]					   ,[strColumnName]			   ,[strDefaultValue]
			   ,[ysnActive]					   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileColumnDetailId	,2						   ,'empNum'
			   ,NULL							,NULL					   ,'NULL'
			   ,1							   ,1)

END
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'posNum' AND intSequence = 3
AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN

		INSERT INTO [dbo].[tblSMXMLTagAttribute]
			   ([intImportFileColumnDetailId]	,[intSequence]			   ,[strTagAttribute]
			   ,[strTable]					   ,[strColumnName]			   ,[strDefaultValue]
			   ,[ysnActive]					   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileColumnDetailId	,3						   ,'posNum'
			   ,NULL							,NULL					   ,'NULL'
			   ,1							   ,1)

END
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'period' AND intSequence = 4
AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN

		INSERT INTO [dbo].[tblSMXMLTagAttribute]
			   ([intImportFileColumnDetailId]	,[intSequence]			   ,[strTagAttribute]
			   ,[strTable]					   ,[strColumnName]			   ,[strDefaultValue]
			   ,[ysnActive]					   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileColumnDetailId	,4						   ,'period'
			   ,NULL							,NULL					   ,'NULL'
			   ,1							   ,1)

END
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'drawer' AND intSequence = 5
AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN

		INSERT INTO [dbo].[tblSMXMLTagAttribute]
			   ([intImportFileColumnDetailId]	,[intSequence]			   ,[strTagAttribute]
			   ,[strTable]					   ,[strColumnName]			   ,[strDefaultValue]
			   ,[ysnActive]					   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileColumnDetailId	,5						   ,'drawer'
			   ,NULL							,NULL					   ,'NULL'
			   ,1							   ,1)

END

--LEVEL 29, Attributes(1x)
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId 
AND intLevel = 29 AND strXMLTag = 'trCurrTot'
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'locale' AND intSequence = 1
AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN

		INSERT INTO [dbo].[tblSMXMLTagAttribute]
			   ([intImportFileColumnDetailId]	,[intSequence]			   ,[strTagAttribute]
			   ,[strTable]					   ,[strColumnName]			   ,[strDefaultValue]
			   ,[ysnActive]					   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileColumnDetailId	,1						   ,'locale'
			   ,NULL							,NULL					   ,'NULL'
			   ,1							   ,1)

END

--LEVEL 33, Attributes(1x)
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId 
AND intLevel = 33 AND strXMLTag = 'trLine'
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'locale' AND intSequence = 1
AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN

		INSERT INTO [dbo].[tblSMXMLTagAttribute]
			   ([intImportFileColumnDetailId]	,[intSequence]			   ,[strTagAttribute]
			   ,[strTable]					   ,[strColumnName]			   ,[strDefaultValue]
			   ,[ysnActive]					   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileColumnDetailId	,1						   ,'type'
			   ,NULL							,NULL					   ,'NULL'
			   ,1							   ,1)

END

--LEVEL 40, Attributes(2x)
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId 
AND intLevel = 40 AND strXMLTag = 'trlDept'
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'number' AND intSequence = 1
AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN

		INSERT INTO [dbo].[tblSMXMLTagAttribute]
			   ([intImportFileColumnDetailId]	,[intSequence]			   ,[strTagAttribute]
			   ,[strTable]					   ,[strColumnName]			   ,[strDefaultValue]
			   ,[ysnActive]					   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileColumnDetailId	,1						   ,'number'
			   ,NULL							,NULL					   ,'NULL'
			   ,1							   ,1)

END
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'type' AND intSequence = 2
AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN

		INSERT INTO [dbo].[tblSMXMLTagAttribute]
			   ([intImportFileColumnDetailId]	,[intSequence]			   ,[strTagAttribute]
			   ,[strTable]					   ,[strColumnName]			   ,[strDefaultValue]
			   ,[ysnActive]					   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileColumnDetailId	,2						   ,'type'
			   ,NULL							,NULL					   ,'NULL'
			   ,1							   ,1)

END

--LEVEL 41, Attributes(1x)
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId 
AND intLevel = 41 AND strXMLTag = 'trlCat'
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'number' AND intSequence = 1
AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN

		INSERT INTO [dbo].[tblSMXMLTagAttribute]
			   ([intImportFileColumnDetailId]	,[intSequence]			   ,[strTagAttribute]
			   ,[strTable]					   ,[strColumnName]			   ,[strDefaultValue]
			   ,[ysnActive]					   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileColumnDetailId	,1						   ,'number'
			   ,NULL							,NULL					   ,'NULL'
			   ,1							   ,1)

END

--LEVEL 49, Attributes(3x)
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId 
AND intLevel = 49 AND strXMLTag = 'trPayline'
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'type' AND intSequence = 1
AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN

		INSERT INTO [dbo].[tblSMXMLTagAttribute]
			   ([intImportFileColumnDetailId]	,[intSequence]			   ,[strTagAttribute]
			   ,[strTable]					   ,[strColumnName]			   ,[strDefaultValue]
			   ,[ysnActive]					   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileColumnDetailId	,1						   ,'type'
			   ,NULL							,NULL					   ,'NULL'
			   ,1							   ,1)

END
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'sysid' AND intSequence = 2
AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN

		INSERT INTO [dbo].[tblSMXMLTagAttribute]
			   ([intImportFileColumnDetailId]	,[intSequence]			   ,[strTagAttribute]
			   ,[strTable]					   ,[strColumnName]			   ,[strDefaultValue]
			   ,[ysnActive]					   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileColumnDetailId	,2						   ,'sysid'
			   ,NULL							,NULL					   ,'NULL'
			   ,1							   ,1)

END
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'locale' AND intSequence = 3
AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN

		INSERT INTO [dbo].[tblSMXMLTagAttribute]
			   ([intImportFileColumnDetailId]	,[intSequence]			   ,[strTagAttribute]
			   ,[strTable]					   ,[strColumnName]			   ,[strDefaultValue]
			   ,[ysnActive]					   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileColumnDetailId	,3						   ,'locale'
			   ,NULL							,NULL					   ,'NULL'
			   ,1							   ,1)

END

--LEVEL 50, Attributes(4x)
SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId 
AND intLevel = 50 AND strXMLTag = 'trpPaycode'
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'mop' AND intSequence = 1
AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN

		INSERT INTO [dbo].[tblSMXMLTagAttribute]
			   ([intImportFileColumnDetailId]	,[intSequence]			   ,[strTagAttribute]
			   ,[strTable]					   ,[strColumnName]			   ,[strDefaultValue]
			   ,[ysnActive]					   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileColumnDetailId	,1						   ,'mop'
			   ,NULL							,NULL					   ,'NULL'
			   ,1							   ,1)

END
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'cat' AND intSequence = 2
AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN

		INSERT INTO [dbo].[tblSMXMLTagAttribute]
			   ([intImportFileColumnDetailId]	,[intSequence]			   ,[strTagAttribute]
			   ,[strTable]					   ,[strColumnName]			   ,[strDefaultValue]
			   ,[ysnActive]					   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileColumnDetailId	,2						   ,'cat'
			   ,NULL							,NULL					   ,'NULL'
			   ,1							   ,1)

END
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'nacstendercode' AND intSequence = 3
AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN

		INSERT INTO [dbo].[tblSMXMLTagAttribute]
			   ([intImportFileColumnDetailId]	,[intSequence]			   ,[strTagAttribute]
			   ,[strTable]					   ,[strColumnName]			   ,[strDefaultValue]
			   ,[ysnActive]					   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileColumnDetailId	,3						   ,'nacstendercode'
			   ,NULL							,NULL					   ,'NULL'
			   ,1							   ,1)

END
IF NOT EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE strTagAttribute = 'nacstendersubcode' AND intSequence = 4
AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN

		INSERT INTO [dbo].[tblSMXMLTagAttribute]
			   ([intImportFileColumnDetailId]	,[intSequence]			   ,[strTagAttribute]
			   ,[strTable]					   ,[strColumnName]			   ,[strDefaultValue]
			   ,[ysnActive]					   ,[intConcurrencyId])
		 VALUES
			   (@intImportFileColumnDetailId	,4						   ,'nacstendersubcode'
			   ,NULL							,NULL					   ,'NULL'
			   ,1							   ,1)

END

GO