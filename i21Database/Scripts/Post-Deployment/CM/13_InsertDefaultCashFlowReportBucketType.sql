GO
PRINT 'Start generating default Cash Flow Report Bucket Types'
GO
	
SET  IDENTITY_INSERT tblCMCashFlowReportBucketType ON
	MERGE 
	INTO	dbo.tblCMCashFlowReportBucketType
	WITH	(HOLDLOCK) 
	AS		BucketTypeTable
	USING	(
			SELECT id = 1,  bucketType = 'Current' UNION ALL 
			SELECT id = 2,  bucketType = '1 - 7' UNION ALL 
			SELECT id = 3,  bucketType = '8 - 14' UNION ALL 
			SELECT id = 4,  bucketType = '15 - 21' UNION ALL 
			SELECT id = 5,  bucketType = '22 - 29' UNION ALL 
			SELECT id = 6,  bucketType = '30 - 60' UNION ALL 
			SELECT id = 7,  bucketType = '60 - 90' UNION ALL 
			SELECT id = 8,  bucketType = '90 - 120' UNION ALL 
			SELECT id = 9,	bucketType = '120+'
	) AS BucketTypeHardCodedValues
		ON  BucketTypeTable.intCashFlowReportBucketTypeId = BucketTypeHardCodedValues.id
	WHEN MATCHED THEN 
		UPDATE 
		SET 	
			BucketTypeTable.strCashFlowReportBucketType = BucketTypeHardCodedValues.bucketType
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			intCashFlowReportBucketTypeId
			,strCashFlowReportBucketType
			,intConcurrencyId
		)
		VALUES (
			BucketTypeHardCodedValues.id
			,BucketTypeHardCodedValues.bucketType
			,1
		);
	SET  IDENTITY_INSERT tblCMCashFlowReportBucketType OFF
	
GO
PRINT 'Finished generating default Cash Flow Report Bucket Types'

