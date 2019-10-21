------------------------------------------------------------------
/*
	XML example

	SET @strXML = '<root>'
	SET @strXML +=		'<toUpdate>' 
	SET @strXML +=			'<dblOriginalBasis>10000</dblOriginalBasis>' 
	SET @strXML +=			'<intTotalLots>10</intTotalLots>' 
	SET @strXML +=		'</toUpdate>' 
	SET @strXML +=		'<child>' 
	SET @strXML +=			'<tblCTSpreadArbitrage>' 
	SET @strXML +=				'<toUpdate>' 
	SET @strXML +=					'<intNoOfLot>8</intNoOfLot>' 
	SET @strXML +=				'</toUpdate>'
	SET @strXML +=			'</tblCTSpreadArbitrage>' 
	SET @strXML +=			'<tblCTPriceFixationDetail>' 
	SET @strXML +=				'<toUpdate>' 
	SET @strXML +=					'<intFx>5</intFx>' 
	SET @strXML +=				'</toUpdate>'
	SET @strXML +=			'</tblCTPriceFixationDetail>' 
	SET @strXML +=		'</child>' 
	SET @strXML += '</root>' 

	DECLARE @strTagRelaceXML NVARCHAR(MAX) =  
	'<root>
		<tags>
			<toFind>&lt;tblCTContractDetail&gt;130&lt;/tblCTContractDetail&gt;</toFind>
			<toReplace>&lt;tblCTContractDetail&gt;666&lt;/tblCTContractDetail&gt;</toReplace>
		</tags>
		<tags>
			<toFind>&lt;tblCTContractHeader&gt;114&lt;/tblCTContractHeader&gt;</toFind>
			<toReplace>&lt;tblCTContractHeader&gt;555&lt;/tblCTContractHeader&gt;</toReplace>
		</tags>
	</root>'
*/
------------------------------------------------------------------
CREATE PROCEDURE [dbo].[uspCTCreateADuplicateRecord]
	
		@strTblName			NVARCHAR(MAX),
		@intId				INT,
		@intNewRecId		INT OUTPUT,
		@strXML				NVARCHAR(MAX) = NULL,
		@strTagRelaceXML	NVARCHAR(MAX) = NULL

AS

BEGIN TRY
DECLARE 
		
		@idoc			INT,			@varXML			XML,			@strPrimaryColumn		NVARCHAR(50),		@strCondition			NVARCHAR(MAX),
		@strGetXML		NVARCHAR(MAX),	@intUniqueId	INT,			@strSetColumn			NVARCHAR(MAX),		@strSQL					NVARCHAR(MAX),
		@intChildRecId	INT,			@strChildTable	NVARCHAR(MAX),	@strForeignKeyColumn	NVARCHAR(MAX),		@ErrMsg					NVARCHAR(MAX),
		@strColName		NVARCHAR(100),	@strColValue	NVARCHAR(MAX),	@toFind					NVARCHAR(MAX),		@toReplace				NVARCHAR(MAX)
		
		
	EXEC sp_xml_preparedocument @idoc OUTPUT, @strXML

	SET @varXML = CAST(@strXML as XML)

	IF OBJECT_ID('tempdb..#ParentTableColUpdate') IS NOT NULL  	
		DROP TABLE #ParentTableColUpdate	

	SELECT	ROW_NUMBER() OVER (ORDER BY strColName ASC) intUniqueId,
			*
	INTO	#ParentTableColUpdate
	FROM(	
			SELECT	strColName	= C.value('local-name(.)', 'varchar(50)'),
					strColValue = C.value('(.)[1]', 'varchar(50)') 
			FROM	@varXML.nodes('/root/toUpdate/*') AS T(C)
		)t

	IF OBJECT_ID('tempdb..#ChildTables') IS NOT NULL  	
		DROP TABLE #ChildTables
	
	SELECT	ROW_NUMBER() OVER (ORDER BY strTblName ASC) intUniqueId,
			*
	INTO	#ChildTables
	FROM	(
				SELECT	strTblName = C.value('local-name(.)', 'varchar(50)')
				FROM	@varXML.nodes('/root/child/*') AS T(C)
			)t
	
	EXEC sp_xml_preparedocument @idoc OUTPUT, @strTagRelaceXML

	IF OBJECT_ID('tempdb..#TagsTable') IS NOT NULL  	
		DROP TABLE #TagsTable

	SELECT	ROW_NUMBER() OVER (ORDER BY toFind ASC) intUniqueId,*
	INTO	#TagsTable
	FROM	OPENXML(@idoc, 'root/tags',2)
	WITH
	(
			toFind			NVARCHAR(MAX),
			toReplace		NVARCHAR(MAX)
	)  

	SELECT	@strPrimaryColumn	=	USG.COLUMN_NAME 
	FROM	INFORMATION_SCHEMA.TABLE_CONSTRAINTS CST, 
			INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE USG 
	WHERE   USG.CONSTRAINT_NAME =	CST.CONSTRAINT_NAME
    AND		USG.TABLE_NAME		=	CST.TABLE_NAME
    AND		CONSTRAINT_TYPE		=	'PRIMARY KEY'
    AND		USG.TABLE_NAME		=	@strTblName
    
    IF	ISNULL(@strPrimaryColumn,'') = ''
    BEGIN
		RAISERROR('PRIMARY KEY column not available for the table.',16,1)
    END
    
    SELECT	@strCondition = @strPrimaryColumn +' = ' + LTRIM(@intId)
    
    SELECT	TOP 1 @strSetColumn = 
			STUFF(													
			   (SELECT											
					', ' + strColName	+ ' = ' + 
					CASE	WHEN	CL.DATA_TYPE IN (SELECT * FROM dbo.fnSplitString('varbinary,text,varchar,datetime,nchar,date,char,ntext,nvarchar',','))
							THEN 	''''+strColValue+''''
							ELSE	strColValue
					END					
					FROM	#ParentTableColUpdate	CU
					JOIN	INFORMATION_SCHEMA.COLUMNS CL ON CL.COLUMN_NAME = CU.strColName AND CL.TABLE_NAME = @strTblName
					FOR XML PATH(''), TYPE									
			   ).value('.','varchar(max)')											
			   ,1,2, ''											
		  ) 											
	FROM #ParentTableColUpdate CH
    
    EXEC	uspCTGetTableDataInXML		@strTblName,	@strCondition,	@strGetXML OUTPUT,	''

	SELECT @intUniqueId= MIN(intUniqueId) FROM #TagsTable
	
	WHILE	ISNULL(@intUniqueId,0) > 0
	BEGIN
			SELECT	@toFind = toFind, @toReplace = toReplace FROM #TagsTable WHERE intUniqueId = @intUniqueId
			SELECT	@strGetXML = REPLACE(@strGetXML,@toFind,@toReplace)
			
			SELECT	@intUniqueId= MIN(intUniqueId) FROM #TagsTable WHERE intUniqueId > @intUniqueId
	END

	SELECT @varXML = @strGetXML
	SELECT @intUniqueId= MIN(intUniqueId) FROM #ParentTableColUpdate
	
	WHILE	ISNULL(@intUniqueId,0) > 0
	BEGIN
			SELECT	@strColName = strColName,@strColValue = strColValue FROM #ParentTableColUpdate WHERE intUniqueId = @intUniqueId
			
			SELECT @strSQL = N'SET  @varXML.modify(''replace value of (/'+@strTblName+'s/'+@strTblName+'/'+@strColName+'/text())[1] with sql:variable("@strColValue")'')'
			EXEC sp_executesql @strSQL,N'@varXML XML OUTPUT,@strColValue NVARCHAR(MAX)',@varXML = @varXML OUTPUT,@strColValue = @strColValue
			
			SELECT	@intUniqueId= MIN(intUniqueId) FROM #ParentTableColUpdate WHERE intUniqueId > @intUniqueId
	END

	SELECT @strGetXML = CAST(@varXML AS NVARCHAR(MAX))

	EXEC	uspCTInsertINTOTableFromXML @strTblName,	@strGetXML,		@intNewRecId OUTPUT
	
	IF ISNULL(@strSetColumn,'') <> ''
	BEGIN
		SELECT @strSQL = 'UPDATE ' + @strTblName + ' SET ' + @strSetColumn + ' WHERE ' + @strPrimaryColumn + ' = ' + LTRIM(@intNewRecId)
		EXEC sp_executesql @strSQL
	END
	
	SELECT @intUniqueId = NULL
	SELECT @intUniqueId= MIN(intUniqueId) FROM #ChildTables
	
	WHILE	ISNULL(@intUniqueId,0) > 0
	BEGIN
			SELECT	@strChildTable = strTblName FROM #ChildTables WHERE intUniqueId = @intUniqueId
			
			SELECT	@strForeignKeyColumn = c1.name
			FROM	sys.foreign_keys fk
			INNER	JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
			INNER	JOIN sys.columns c1 ON fkc.parent_column_id = c1.column_id AND fkc.parent_object_id = c1.object_id
			INNER	JOIN sys.columns c2 ON fkc.referenced_column_id = c2.column_id AND fkc.referenced_object_id = c2.object_id
			WHERE	OBJECT_NAME(fk.parent_object_id) = @strChildTable AND OBJECT_NAME(fk.referenced_object_id) = @strTblName

			SELECT	@strCondition = @strPrimaryColumn +' = ' + LTRIM(@intId)
	
			EXEC	uspCTGetTableDataInXML @strChildTable,@strCondition,@strGetXML OUTPUT,''
			
			SELECT	@strGetXML = REPLACE(@strGetXML,'<'+@strForeignKeyColumn+'>'+LTRIM(@intId)+'</'+@strForeignKeyColumn+'>','<'+@strForeignKeyColumn+'>'+LTRIM(@intNewRecId)+'</'+@strForeignKeyColumn+'>')
			EXEC	uspCTInsertINTOTableFromXML @strChildTable,@strGetXML,@intChildRecId OUTPUT
			
			SELECT	@intUniqueId= MIN(intUniqueId) FROM #ChildTables WHERE intUniqueId > @intUniqueId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH