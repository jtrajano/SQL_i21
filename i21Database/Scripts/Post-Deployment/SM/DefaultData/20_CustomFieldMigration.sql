GO
	PRINT N'BEGIN Custom Field Migration'
GO
	-- INSERT to tblSMCustomTab FROM tblSMCustomField
	INSERT INTO tblSMCustomTab (
		intScreenId, 
		strTabName, 
		strLayout, 
		ysnBuild,
		intConcurrencyId
	)
	SELECT	
		A.intScreenId, 
		B.strTabName,
		B.strLayout,
		B.ysnBuild,
		B.intConcurrencyId
	FROM tblSMScreen A LEFT OUTER JOIN tblSMCustomField B
		ON A.strScreenName = B.strScreen 
	WHERE ysnCustomTab = 1 AND ysnBuild = 1 

	-- INSERT 'Id' for each Custom Field
	INSERT INTO tblSMCustomFieldDetail (
		intCustomFieldId,
		intSort,
		strFieldName,
		strControlType,
		strFieldSize,
		strLabelName,
		strFieldType,
		strLocation,
		ysnBuild,
		ysnModified,
		intConcurrencyId
	) 
	SELECT
		intCustomFieldId,
		1,
		'Id',
		'Integer',
		'0',
		'Id',
		'Integer',
		'Column 1',
		ysnBuild,
		1,
		1
	FROM tblSMCustomField 

	-- INSERT to tblSMCustomTabDetail from tblSMCustomFieldDetail
	INSERT INTO tblSMCustomTabDetail (
		intCustomTabId,
		intFlex,
		intSort,
		intTextLength,
		intWidth,
		intConcurrencyId,
		strControlName,
		strControlType,
		strFieldName,
		strLocation,
		ysnBuild,
		ysnModified
	)
	SELECT 
		D.intCustomTabId,
		1 intFlex,
		A.intSort,
		CAST(ISNULL(A.strFieldSize, 0) AS INT) intTextLength,
		NULL intWidth,
		A.intConcurrencyId,
		A.strLabelName,
		CASE WHEN A.strControlType = 'Numeric' THEN A.strFieldType
			 ELSE A.strControlType
		END strControlType,
		A.strFieldName,
		A.strLocation,
		A.ysnBuild,
		A.ysnModified
	FROM tblSMCustomFieldDetail A 
		INNER JOIN tblSMCustomField B ON A.intCustomFieldId = B.intCustomFieldId 
		INNER JOIN tblSMScreen C ON B.strScreen = C.strScreenName AND ysnCustomTab = 1
		INNER JOIN tblSMCustomTab D ON D.intScreenId = C.intScreenId

	-- INSERT to tblSMComboBoxValue from tblSMCustomFieldValue
	INSERT INTO tblSMComboBoxValue (
		intCustomTabDetailId,
		intSort,
		strValue,
		intConcurrencyId
	)
	SELECT
		F.intCustomTabDetailId,
		A.intSort,
		A.strValue,
		A.intConcurrencyId
	FROM tblSMCustomFieldValue A 
		INNER JOIN tblSMCustomFieldDetail B ON A.intCustomFieldDetailId = B.intCustomFieldDetailId
		INNER JOIN tblSMCustomField C ON C.intCustomFieldId = B.intCustomFieldId
		INNER JOIN tblSMScreen D ON C.strScreen = D.strScreenName AND ysnCustomTab = 1
		INNER JOIN tblSMCustomTab E ON D.intScreenId = E.intScreenId
		INNER JOIN tblSMCustomTabDetail F ON E.intCustomTabId = F.intCustomTabId AND B.strFieldName = F.strFieldName

	DECLARE @ScreenTemp TABLE (
		[intScreenId]		[int] PRIMARY KEY,
		[intCustomTabId]	[int],
		[strTableName]		NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
	) 

	INSERT INTO @ScreenTemp (
		intScreenId,
		intCustomTabId,
		strTableName
	)
	SELECT	
		A.intScreenId, 
		C.intCustomTabId,
		REPLACE(REPLACE(A.strTableName, 'tbl', 'cst'), 'cstEM', 'cst') strTableName
	FROM tblSMScreen A 
		LEFT OUTER JOIN tblSMCustomField B ON A.strScreenName = B.strScreen 
		INNER JOIN tblSMCustomTab C ON C.intScreenId = A.intScreenId
	WHERE ysnCustomTab = 1 AND B.ysnBuild = 1 

	WHILE EXISTS(SELECT TOP (1) 1 FROM @ScreenTemp)
	BEGIN
		DECLARE @screenId		AS INT
		DECLARE @customTabId	AS INT
		DECLARE @tableName		AS NVARCHAR(100)

		SELECT TOP 1 
			@screenId		= intScreenId,
			@customTabId	= intCustomTabId,
			@tableName		= strTableName
		FROM @ScreenTemp

		--INSERT to tblSMTransaction, tblSMTabRow and tblSMFieldValue
		EXEC ('
			 INSERT INTO tblSMTransaction (
				intScreenId, 
				strRecordNo, 
				intConcurrencyId
			 )
			 SELECT 
			'+	@screenId  + ',
				intId,
				0 
			 FROM ' + @tableName + ' A LEFT OUTER JOIN tblSMTransaction B
				ON B.intScreenId = '+	@screenId  + ' AND CAST(B.strRecordNo AS INT) = A.intId
			 WHERE ISNULL(intTransactionId, 0) = 0	 

			 INSERT INTO tblSMTabRow (
				intCustomTabId,
				intTransactionId,
				intSort,
				intConcurrencyId
			 )
			 SELECT
			 '+	@customTabId  + ',
				B.intTransactionId,
				0,
				1
			 FROM ' + @tableName + ' A INNER JOIN tblSMTransaction B
				ON B.intScreenId = '+	@screenId  + ' AND CAST(B.strRecordNo AS INT) = A.intId	 

			 DECLARE @columnsOnly AS NVARCHAR(MAX),
					 @columnsWithCast AS NVARCHAR(MAX),
					 @query AS NVARCHAR(MAX)

			SELECT @columnsOnly = STUFF((
				SELECT '','' + REPLACE(QUOTENAME(
					A.name), ''intId'', ''Id'') 
				FROM sys.columns A 
					INNER JOIN sys.tables B ON A.object_id = B.object_id
				WHERE B.name = ''' + @tableName + ''' --AND A.name <> ''intId''
				FOR XML PATH('''')) , 1, 1, '''')	
		
			SELECT @columnsWithCast = STUFF((
				SELECT 
					'',ISNULL(CAST('' + QUOTENAME(
					A.name) + CASE WHEN LEFT(A.name, 3) = ''str'' THEN '' COLLATE SQL_Latin1_General_CP1_CS_AS '' ELSE '''' END +
					'' AS NVARCHAR(255)), '''''''') AS '' + REPLACE(QUOTENAME(
				A.name), ''intId'', ''Id'')
				FROM sys.columns A 
					INNER JOIN sys.tables B ON A.object_id = B.object_id
				
				WHERE B.name = ''' + @tableName + ''' 
				FOR XML PATH('''')) , 1, 1, '''')	

			SET @columnsWithCast = ''intId,'' + @columnsWithCast 
			SET @query = 
				   ''INSERT INTO tblSMFieldValue (
						intTabRowId,
						intCustomTabDetailId,
						strValue,
						intConcurrencyId
					 )
					 SELECT 
						E.intTabRowId,
						C.intCustomTabDetailId,
						value,
						1
					 FROM 
					 (
						SELECT 	
							'' + @columnsWithCast + ''
						FROM ' + @tableName + ' 
					 ) A
					 UNPIVOT
					 (
						value
						FOR field IN ('' + @columnsOnly + '')
					 ) B
					 INNER JOIN tblSMCustomTabDetail C ON B.field COLLATE SQL_Latin1_General_CP1_CS_AS = C.strFieldName AND C.intCustomTabId = ' + @customTabId + '
					 INNER JOIN tblSMTransaction D ON B.intId = CAST(D.strRecordNo AS INT) AND D.intScreenId = ' + @screenId + '
					 INNER JOIN tblSMTabRow E ON D.intTransactionId = E.intTransactionId AND E.intCustomTabId = ' + @customTabId + '
				   ''
			EXEC sp_executesql @query;
		')

		DELETE TOP (1) FROM @ScreenTemp
	END

	DELETE FROM tblSMCustomField
GO
	PRINT N'Custom Field Migration'
GO

	