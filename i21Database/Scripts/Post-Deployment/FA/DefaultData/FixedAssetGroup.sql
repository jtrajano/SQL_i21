GO
	PRINT 'Start generating default fixed asset groups'
GO
	
SET  IDENTITY_INSERT tblFAFixedAssetGroup ON
	MERGE 
	INTO	dbo.tblFAFixedAssetGroup
	WITH	(HOLDLOCK) 
	AS		AssetGroupTable
	USING	(
			SELECT id = 1,  code = 'PPE', description = 'Property plant and equipment' UNION ALL 
			SELECT id = 2,  code = 'F&F', description = 'Furniture and Fixtures' UNION ALL
			SELECT id = 3,  code = 'L',   description = 'Land' UNION ALL
			SELECT id = 4,  code = 'B',   description = 'Buildings' UNION ALL
			SELECT id = 5,  code = 'CE',  description = 'Computer equipment' UNION ALL
			SELECT id = 6,  code = 'CS',  description = 'Computer software' UNION ALL
			SELECT id = 7,  code = 'CIP', description = 'Construction in progress' UNION ALL
			SELECT id = 8,  code = 'IA',  description = 'Intangible assets' UNION ALL
			SELECT id = 9,  code = 'M',   description = 'Machinery' UNION ALL
			SELECT id = 10, code = 'V',   description = 'Vehicles'

	) AS AssetGroupHardCodedValues
		ON  AssetGroupTable.intAssetGroupId = AssetGroupHardCodedValues.id

	-- When id is matched, make sure the code and description are updated
	WHEN MATCHED THEN 
		UPDATE 
		SET 	AssetGroupTable.strGroupCode = AssetGroupHardCodedValues.code,
				AssetGroupTable.strGroupDescription = AssetGroupHardCodedValues.description
	-- When id is missing, then do an insert. 
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			intAssetGroupId
			,strGroupCode
			,strGroupDescription
			,intConcurrencyId
		)
		VALUES (
			AssetGroupHardCodedValues.id
			,AssetGroupHardCodedValues.code
			,AssetGroupHardCodedValues.description
			,1
		);
	--WHEN NOT MATCHED BY SOURCE THEN
	--DELETE;
	SET  IDENTITY_INSERT tblFAFixedAssetGroup OFF
	
	GO
		PRINT 'Finished generating default fixed asset groups'

