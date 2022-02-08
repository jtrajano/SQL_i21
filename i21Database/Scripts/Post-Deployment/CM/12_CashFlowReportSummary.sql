GO
	PRINT 'Start generating default Cash Flow Report Summary Groups'
GO
	
SET  IDENTITY_INSERT tblCMCashFlowReportSummaryGroup ON
	MERGE 
	INTO	dbo.tblCMCashFlowReportSummaryGroup
	WITH	(HOLDLOCK) 
	AS		SummaryGroupTable
	USING	(
			SELECT id = 1,  summaryGroup = '1: Total Cash', sort = 1000 UNION ALL 
			SELECT id = 2,  summaryGroup = '2: Total AR', sort = 1001  UNION ALL
			SELECT id = 3,  summaryGroup = '3: Total AP', sort = 1002  UNION ALL
			SELECT id = 4,  summaryGroup = '4: Total Sales Logistics Shipments', sort = 1003  UNION ALL
			SELECT id = 5,  summaryGroup = '5: Total Purchase Logistics Shipments', sort = 1004  UNION ALL
			SELECT id = 6,  summaryGroup = '6: Total Sales Contracts', sort = 1005  UNION ALL
			SELECT id = 7,  summaryGroup = '7: Total Purchase Contracts', sort = 1006

	) AS SummaryGroupHardCodedValues
		ON  SummaryGroupTable.intCashFlowReportSummaryGroupId = SummaryGroupHardCodedValues.id

	WHEN MATCHED THEN 
		UPDATE 
		SET 	SummaryGroupTable.strCashFlowReportSummaryGroup = SummaryGroupHardCodedValues.summaryGroup,
				SummaryGroupTable.intGroupSort = SummaryGroupHardCodedValues.sort
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			intCashFlowReportSummaryGroupId
			,strCashFlowReportSummaryGroup
			,intGroupSort
			,intConcurrencyId
		)
		VALUES (
			SummaryGroupHardCodedValues.id
			,SummaryGroupHardCodedValues.summaryGroup
			,SummaryGroupHardCodedValues.sort
			,1
		);
	SET  IDENTITY_INSERT tblCMCashFlowReportSummaryGroup OFF
	
GO
	PRINT 'Finished generating Cash Flow Report Summary Groups'

GO
	PRINT 'Start generating default Cash Flow Report Summary Codes'
GO
	
SET  IDENTITY_INSERT tblCMCashFlowReportSummaryCode ON
	MERGE 
	INTO	dbo.tblCMCashFlowReportSummaryCode
	WITH	(HOLDLOCK) 
	AS		SummaryCodeTable
	USING	(
			SELECT id = 1,   reportCode = 'CH-1001', report = 'Cash', reportDescription = 'Cash',														sort = 1000, operation = 'Add', groupId = 1 UNION ALL
			SELECT id = 2,   reportCode = 'AR-1001', report = 'AR', reportDescription = 'AR',															sort = 1001, operation = 'Add', groupId = 2 UNION ALL
			SELECT id = 3,   reportCode = 'AP-1001', report = 'AP', reportDescription = 'AP',															sort = 1002, operation = 'Subtract', groupId = 3 UNION ALL
			SELECT id = 4,   reportCode = 'LG-1001', report = 'Sales Logistics Shipments', reportDescription = 'Sales Logistics Shipments',				sort = 1003, operation = 'Add', groupId = 4 UNION ALL
			SELECT id = 5,   reportCode = 'LG-1002', report = 'Purchase Logistics Shipments', reportDescription = 'Purchase Logistics Shipments',		sort = 1004, operation = 'Subtract', groupId = 5 UNION ALL
			SELECT id = 6,   reportCode = 'CT-1001', report = 'Sales Contracts', reportDescription = 'Sales Contracts',									sort = 1005, operation = 'Add', groupId = 6 UNION ALL
			SELECT id = 7,   reportCode = 'CT-1002', report = 'Purchase Contracts', reportDescription = 'Purchase Contracts',							sort = 1006, operation = 'Subtract', groupId = 7

			--SELECT id = 1,   reportCode = 'CH-1001', report = 'Cash', reportDescription = 'Cash',														sort = 1000, operation = 'Add', groupId = 1 UNION ALL
			--SELECT id = 2,   reportCode = 'AR-1001', report = 'AR Goods', reportDescription = 'AR Goods',												sort = 1001, operation = 'Add', groupId = 2 UNION ALL
			--SELECT id = 3,   reportCode = 'AR-1002', report = 'AR Cost Billings', reportDescription = 'AR Cost Billings',								sort = 1002, operation = 'Add', groupId = 2 UNION ALL
			--SELECT id = 4,   reportCode = 'AR-1003', report = 'AR Miscellaneous', reportDescription = 'AR Miscellaneous',								sort = 1003, operation = 'Add', groupId = 2 UNION ALL
			--SELECT id = 5,   reportCode = 'AP-1001', report = 'AP Goods', reportDescription = 'AP Goods',												sort = 1004, operation = 'Subtract', groupId = 3 UNION ALL
			--SELECT id = 6,   reportCode = 'AP-1002', report = 'AP Costs', reportDescription = 'AP Costs',												sort = 1005, operation = 'Subtract', groupId = 3 UNION ALL
			--SELECT id = 7,   reportCode = 'AP-1003', report = 'AP Miscellaneous', reportDescription = 'AP Miscellaneous',								sort = 1006, operation = 'Subtract', groupId = 3 UNION ALL
			--SELECT id = 8,   reportCode = 'LG-1001', report = 'Logistics Shipments', reportDescription = 'Logistics Shipments',							sort = 1007, operation = 'Add', groupId = 4 UNION ALL
			--SELECT id = 9,   reportCode = 'SA-1001', report = 'Sales Contracts', reportDescription = 'Sales Contracts',									sort = 1008, operation = 'Add', groupId = 5 UNION ALL
			--SELECT id = 10,	 reportCode = 'SA-1002', report = 'Sales Cost Billings', reportDescription = 'Sales Cost Billings',							sort = 1009, operation = 'Add', groupId = 5 UNION ALL
			--SELECT id = 11,  reportCode = 'PU-1001', report = 'Purchase Contracts', reportDescription = 'Purchase Contracts',							sort = 1010, operation = 'Subtract', groupId = 6 UNION ALL
			--SELECT id = 12,  reportCode = 'PU-1002', report = 'Purchase Cost', reportDescription = 'Purchase Cost',										sort = 1011, operation = 'Subtract', groupId = 6 UNION ALL
			--SELECT id = 13,  reportCode = 'PP-1001', report = 'Physical Position', reportDescription = 'Physical Position',								sort = 1012, operation = 'Subtract', groupId = 2 UNION ALL
			--SELECT id = 14,  reportCode = 'PC-1001', report = 'Purchased Currency VS Physical', reportDescription = 'Purchased Currency VS Physical',	sort = 1013, operation = 'Add', groupId = 7 UNION ALL
			--SELECT id = 15,  reportCode = 'PO-1001', report = 'Purchased Currency Optimization', reportDescription = 'Purchased Currency Optimization', sort = 1014, operation = 'Add', groupId = 7 UNION ALL
			--SELECT id = 16,  reportCode = 'SC-1001', report = 'Sold Currency VS Physical', reportDescription = 'Sold Currency VS Physical',				sort = 1015, operation = 'Subtract', groupId = 7 UNION ALL
			--SELECT id = 17,  reportCode = 'SC-1002', report = 'Sold Currency Optimization', reportDescription = 'Sold Currency Optimization',			sort = 1016, operation = 'Subtract', groupId = 7 

	) AS SummaryCodeHardCodedValues
		ON  SummaryCodeTable.intCashFlowReportSummaryCodeId = SummaryCodeHardCodedValues.id

	WHEN MATCHED THEN 
		UPDATE 
		SET 	SummaryCodeTable.strCashFlowReportSummaryCode = SummaryCodeHardCodedValues.reportCode,
				SummaryCodeTable.strReport = SummaryCodeHardCodedValues.report,
				SummaryCodeTable.strReportDescription = SummaryCodeHardCodedValues.reportDescription,
				SummaryCodeTable.intReportSort = SummaryCodeHardCodedValues.sort,
				SummaryCodeTable.strOperation = SummaryCodeHardCodedValues.operation,
				SummaryCodeTable.intCashFlowReportSummaryGroupId = SummaryCodeHardCodedValues.groupId
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			intCashFlowReportSummaryCodeId
			,strCashFlowReportSummaryCode
			,strReport
			,strReportDescription
			,intReportSort
			,strOperation
			,intCashFlowReportSummaryGroupId
			,intConcurrencyId
		)
		VALUES (
			SummaryCodeHardCodedValues.id
			,SummaryCodeHardCodedValues.reportCode
			,SummaryCodeHardCodedValues.report
			,SummaryCodeHardCodedValues.reportDescription
			,SummaryCodeHardCodedValues.sort
			,SummaryCodeHardCodedValues.operation
			,SummaryCodeHardCodedValues.groupId
			,1
		);
	SET  IDENTITY_INSERT tblCMCashFlowReportSummaryCode OFF
	
GO

	PRINT 'Finished generating Cash Flow Report Summary Codes'
GO