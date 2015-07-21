GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMAlterCobolWrite]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMAlterCobolWrite
GO

GO
CREATE PROCEDURE uspTMAlterCobolWrite 
AS
BEGIN
	IF (EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND  TABLE_NAME = 'tblTMCOBOLWRITE'))
	BEGIN
		EXEC ('

			IF (EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = ''dbo'' AND  TABLE_NAME = ''tblTMCOBOLWRITE_backup''))  
			BEGIN  
				DROP TABLE tblTMCOBOLWRITE_backup
			END

			CREATE TABLE tblTMCOBOLWRITE_backup
			(
				[CustomerNumber]             NVARCHAR(100)   
			   ,[SiteNumber]                 CHAR (4)        
			   ,[MeterReading]               DECIMAL (18, 6) 
			   ,[InvoiceNumber]              NVARCHAR(25)    
			   ,[BulkPlantNumber]            NVARCHAR(50)    
			   ,[InvoiceDate]                CHAR (8)        
			   ,[ItemNumber]                 NVARCHAR(50)    
			   ,[ItemAvailableForTM]         CHAR (1)        
			   ,[ReversePreviousDelivery]    CHAR (1)        
			   ,[PerformerID]                NVARCHAR(100)   
			   ,[InvoiceLineNumber]          DECIMAL (18, 6) 
			   ,[ExtendedAmount]             DECIMAL (18, 6) 
			   ,[QuantityDelivered]          DECIMAL (18, 6) 
			   ,[ActualPercentAfterDelivery] DECIMAL (18, 6) 
			   ,[InvoiceType]                CHAR (1)        
			   ,[SalesPersonID]              NVARCHAR(100)   
			)

			INSERT INTO tblTMCOBOLWRITE_backup
			SELECT 
				[CustomerNumber]            
				,[SiteNumber]                
				,[MeterReading]              
				,[InvoiceNumber]             
				,[BulkPlantNumber]           
				,[InvoiceDate]               
				,[ItemNumber]                
				,[ItemAvailableForTM]        
				,[ReversePreviousDelivery]   
				,[PerformerID]               
				,[InvoiceLineNumber]         
				,[ExtendedAmount]            
				,[QuantityDelivered]         
				,[ActualPercentAfterDelivery]
				,[InvoiceType]               
				,[SalesPersonID]             
			FROM tblTMCOBOLWRITE

			DROP TABLE tblTMCOBOLWRITE
		
		')
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
		CREATE TABLE [dbo].[tblTMCOBOLWRITE] (
			[CustomerNumber]             CHAR (10)       CONSTRAINT [DEF_tblTMCOBOLWRITE_CustomerNumber] DEFAULT ((0)) NOT NULL,
			[SiteNumber]                 CHAR (4)        CONSTRAINT [DEF_tblTMCOBOLWRITE_SiteNumber] DEFAULT ((0)) NOT NULL,
			[MeterReading]               DECIMAL (18, 6) CONSTRAINT [DEF_tblTMCOBOLWRITE_MeterReading] DEFAULT ((0)) NULL,
			[InvoiceNumber]              CHAR (8)        CONSTRAINT [DEF_tblTMCOBOLWRITE_InvoiceNumber] DEFAULT ((0)) NOT NULL,
			[BulkPlantNumber]            CHAR (3)        CONSTRAINT [DEF_tblTMCOBOLWRITE_BulkPlantNumber] DEFAULT ((0)) NOT NULL,
			[InvoiceDate]                CHAR (8)        CONSTRAINT [DEF_tblTMCOBOLWRITE_InvoiceDate] DEFAULT ((0)) NULL,
			[ItemNumber]                 CHAR (13)       CONSTRAINT [DEF_tblTMCOBOLWRITE_ItemNumber] DEFAULT ((0)) NULL,
			[ItemAvailableForTM]         CHAR (1)        CONSTRAINT [DEF_tblTMCOBOLWRITE_ItemAvailableForTM] DEFAULT ((0)) NULL,
			[ReversePreviousDelivery]    CHAR (1)        CONSTRAINT [DEF_tblTMCOBOLWRITE_ReversePreviousDelivery] DEFAULT ((0)) NULL,
			[PerformerID]                CHAR (3)        CONSTRAINT [DEF_tblTMCOBOLWRITE_PerformerID] DEFAULT ((0)) NULL,
			[InvoiceLineNumber]          DECIMAL (18, 6) CONSTRAINT [DEF_tblTMCOBOLWRITE_InvoiceLineNumber] DEFAULT ((0)) NOT NULL,
			[ExtendedAmount]             DECIMAL (18, 6) CONSTRAINT [DEF_tblTMCOBOLWRITE_ExtendedAmount] DEFAULT ((0)) NULL,
			[QuantityDelivered]          DECIMAL (18, 6) CONSTRAINT [DEF_tblTMCOBOLWRITE_QuantityDelivered] DEFAULT ((0)) NULL,
			[ActualPercentAfterDelivery] DECIMAL (18, 6) CONSTRAINT [DEF_tblTMCOBOLWRITE_ActualPercentAfterDelivery] DEFAULT ((0)) NULL,
			[InvoiceType]                CHAR (1)        CONSTRAINT [DEF_tblTMCOBOLWRITE_InvoiceType] DEFAULT ((0)) NULL,
			[SalesPersonID]              CHAR (3)        CONSTRAINT [DEF_tblTMCOBOLWRITE_SalesPersonID] DEFAULT ((0)) NULL,
			CONSTRAINT [PK_tblTMCOBOLWRITE] PRIMARY KEY CLUSTERED ([BulkPlantNumber] ASC, [CustomerNumber] ASC, [InvoiceLineNumber] ASC, [InvoiceNumber] ASC, [SiteNumber] ASC)
		);


		
		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Customer Number',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'CustomerNumber'
		
		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Site Number',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'SiteNumber'
		
		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Meter Reading',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'MeterReading'
		
		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Invoice Number',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'InvoiceNumber'
		
		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Bulk Plant Number',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'BulkPlantNumber'
		
		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Invoice Date',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'InvoiceDate'
		
		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Item Number',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'ItemNumber'
		
		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Item Available for TM Option (Y/N)',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'ItemAvailableForTM'
		
		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Reverse Previous Delivery Option (Y/N)',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'ReversePreviousDelivery'
		
		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Performer ID',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'PerformerID'
		
		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Invoice Line Number',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'InvoiceLineNumber'
		
		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Extended Amount',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'ExtendedAmount'
		
		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Quantity Delivered',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'QuantityDelivered'
		
		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Actual Percent After Delivery',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'ActualPercentAfterDelivery'
		
		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Invoice Type',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'InvoiceType'
		
		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Sales Person ID',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'SalesPersonID'

		EXEC ('
			INSERT INTO tblTMCOBOLWRITE(
				[CustomerNumber]            
				,[SiteNumber]                
				,[MeterReading]              
				,[InvoiceNumber]             
				,[BulkPlantNumber]           
				,[InvoiceDate]               
				,[ItemNumber]                
				,[ItemAvailableForTM]        
				,[ReversePreviousDelivery]   
				,[PerformerID]               
				,[InvoiceLineNumber]         
				,[ExtendedAmount]            
				,[QuantityDelivered]         
				,[ActualPercentAfterDelivery]
				,[InvoiceType]               
				,[SalesPersonID]        
			)
			SELECT 
				[CustomerNumber]            
				,[SiteNumber]                
				,[MeterReading]              
				,[InvoiceNumber]             
				,[BulkPlantNumber]           
				,[InvoiceDate]               
				,[ItemNumber]                
				,[ItemAvailableForTM]        
				,[ReversePreviousDelivery]   
				,[PerformerID]               
				,[InvoiceLineNumber]         
				,[ExtendedAmount]            
				,[QuantityDelivered]         
				,[ActualPercentAfterDelivery]
				,[InvoiceType]               
				,[SalesPersonID]             
			FROM tblTMCOBOLWRITE_backup
			')
	END
	ELSE
	BEGIN
		CREATE TABLE [dbo].[tblTMCOBOLWRITE] (
			[CustomerNumber]             NVARCHAR(100)   CONSTRAINT [DEF_tblTMCOBOLWRITE_CustomerNumber] DEFAULT ((0)) NOT NULL,
			[SiteNumber]                 CHAR (4)        CONSTRAINT [DEF_tblTMCOBOLWRITE_SiteNumber] DEFAULT ((0)) NOT NULL,
			[MeterReading]               DECIMAL (18, 6) CONSTRAINT [DEF_tblTMCOBOLWRITE_MeterReading] DEFAULT ((0)) NULL,
			[InvoiceNumber]              NVARCHAR(25)    CONSTRAINT [DEF_tblTMCOBOLWRITE_InvoiceNumber] DEFAULT ((0)) NOT NULL,
			[BulkPlantNumber]            NVARCHAR(50)    CONSTRAINT [DEF_tblTMCOBOLWRITE_BulkPlantNumber] DEFAULT ((0)) NOT NULL,
			[InvoiceDate]                CHAR (8)        CONSTRAINT [DEF_tblTMCOBOLWRITE_InvoiceDate] DEFAULT ((0)) NULL,
			[ItemNumber]                 NVARCHAR(50)    CONSTRAINT [DEF_tblTMCOBOLWRITE_ItemNumber] DEFAULT ((0)) NULL,
			[ItemAvailableForTM]         CHAR (1)        CONSTRAINT [DEF_tblTMCOBOLWRITE_ItemAvailableForTM] DEFAULT ((0)) NULL,
			[ReversePreviousDelivery]    CHAR (1)        CONSTRAINT [DEF_tblTMCOBOLWRITE_ReversePreviousDelivery] DEFAULT ((0)) NULL,
			[PerformerID]                NVARCHAR(100)   CONSTRAINT [DEF_tblTMCOBOLWRITE_PerformerID] DEFAULT ((0)) NULL,
			[InvoiceLineNumber]          DECIMAL (18, 6) CONSTRAINT [DEF_tblTMCOBOLWRITE_InvoiceLineNumber] DEFAULT ((0)) NOT NULL,
			[ExtendedAmount]             DECIMAL (18, 6) CONSTRAINT [DEF_tblTMCOBOLWRITE_ExtendedAmount] DEFAULT ((0)) NULL,
			[QuantityDelivered]          DECIMAL (18, 6) CONSTRAINT [DEF_tblTMCOBOLWRITE_QuantityDelivered] DEFAULT ((0)) NULL,
			[ActualPercentAfterDelivery] DECIMAL (18, 6) CONSTRAINT [DEF_tblTMCOBOLWRITE_ActualPercentAfterDelivery] DEFAULT ((0)) NULL,
			[InvoiceType]                CHAR (1)        CONSTRAINT [DEF_tblTMCOBOLWRITE_InvoiceType] DEFAULT ((0)) NULL,
			[SalesPersonID]              NVARCHAR(100)   CONSTRAINT [DEF_tblTMCOBOLWRITE_SalesPersonID] DEFAULT ((0)) NULL,
			CONSTRAINT [PK_tblTMCOBOLWRITE] PRIMARY KEY CLUSTERED ([BulkPlantNumber] ASC, [CustomerNumber] ASC, [InvoiceLineNumber] ASC, [InvoiceNumber] ASC, [SiteNumber] ASC)
		);
		
		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Customer Number',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'CustomerNumber'

		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Site Number',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'SiteNumber'

		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Meter Reading',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'MeterReading'

		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Invoice Number',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'InvoiceNumber'

		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Bulk Plant Number',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'BulkPlantNumber'

		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Invoice Date',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'InvoiceDate'

		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Item Number',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'ItemNumber'

		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Item Available for TM Option (Y/N)',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'ItemAvailableForTM'
		
		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Reverse Previous Delivery Option (Y/N)',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'ReversePreviousDelivery'
		
		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Performer ID',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'PerformerID'
		
		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Invoice Line Number',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'InvoiceLineNumber'
		
		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Extended Amount',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'ExtendedAmount'
		
		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Quantity Delivered',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'QuantityDelivered'
		
		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Actual Percent After Delivery',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'ActualPercentAfterDelivery'
		
		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Invoice Type',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'InvoiceType'
		
		EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Sales Person ID',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblTMCOBOLWRITE',
			@level2type = N'COLUMN',
			@level2name = N'SalesPersonID'

		EXEC ('
			INSERT INTO tblTMCOBOLWRITE(
				[CustomerNumber]            
				,[SiteNumber]                
				,[MeterReading]              
				,[InvoiceNumber]             
				,[BulkPlantNumber]           
				,[InvoiceDate]               
				,[ItemNumber]                
				,[ItemAvailableForTM]        
				,[ReversePreviousDelivery]   
				,[PerformerID]               
				,[InvoiceLineNumber]         
				,[ExtendedAmount]            
				,[QuantityDelivered]         
				,[ActualPercentAfterDelivery]
				,[InvoiceType]               
				,[SalesPersonID]        
			)
			SELECT 
				[CustomerNumber]            
				,[SiteNumber]                
				,[MeterReading]              
				,[InvoiceNumber]             
				,[BulkPlantNumber]           
				,[InvoiceDate]               
				,[ItemNumber]                
				,[ItemAvailableForTM]        
				,[ReversePreviousDelivery]   
				,[PerformerID]               
				,[InvoiceLineNumber]         
				,[ExtendedAmount]            
				,[QuantityDelivered]         
				,[ActualPercentAfterDelivery]
				,[InvoiceType]               
				,[SalesPersonID]             
			FROM tblTMCOBOLWRITE_backup
			')
		
	END
END
GO