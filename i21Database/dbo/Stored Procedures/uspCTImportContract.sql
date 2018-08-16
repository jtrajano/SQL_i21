CREATE PROCEDURE [dbo].[uspCTImportContract]
	
	@TableFromImport	NVARCHAR(100),
	@TableToImport		NVARCHAR(100),
	@ValidationSP		NVARCHAR(100),
	@intRowId			INT,
	@intId				INT OUTPUT
AS
--DECLARE @TableFromImport NVARCHAR(100) = 'HeaderNew',
--	   @TableToImport NVARCHAR(100) = 'tblCTContractHeader',


BEGIN TRY
    DECLARE   @intExcelAndTableColumnMapId  INT,
			  @Query					    NVARCHAR(MAX),
			  @Join							NVARCHAR(MAX) = '',
			  @LeftJoin						NVARCHAR(MAX) = '',
			  @Insertlist				    NVARCHAR(MAX) = '',
			  @SelectList				    NVARCHAR(MAX) = '',
			  @strExcelColumnName		    NVARCHAR(100),
			  @strTableCoulmnName		    NVARCHAR(100),
			  @strRefTable				    NVARCHAR(100),
			  @strRefTableIdCol			    NVARCHAR(100),
			  @strRefCoulumnToCmpr		    NVARCHAR(100),
			  @strJoinType				    NVARCHAR(100),
			  @strSpecialJoin			    NVARCHAR(MAX),
			  @Alias					    NVARCHAR(100),
			  @SelColumn				    NVARCHAR(100),
			  @ErrMsg					    NVARCHAR(MAX)

  --  SELECT @Query = '
  --  IF NOT EXISTS(SELECT *FROM sysobjects SO Inner Join syscolumns SC ON SO.id=SC.id WHERE SO.type=''U'' AND SO.name='''+@TableFromImport+''' and SC.name=''intConcurrencyId'')	
  --  BEGIN	
		-- ALTER TABLE '+@TableFromImport+'	
		--ADD	  intConcurrencyId INT NULL,
		--	  intId INT
  --  END'	

  --  EXEC sp_executesql @Query

  --  SELECT @Query = 'UPDATE '+@TableFromImport+' SET intConcurrencyId = 1'

  --  EXEC sp_executesql @Query

    SELECT @Query = 'SELECT DISTINCT * INTO #tempExcelContractHeader FROM ' + @TableFromImport + ' EX '

    SELECT @intExcelAndTableColumnMapId = MIN(intExcelAndTableColumnMapId) FROM tblCTExcelAndTableColumnMap WHERE strTableName = @TableToImport
    WHILE ISNULL(@intExcelAndTableColumnMapId,0) > 0
    BEGIN
	   SELECT    @strExcelColumnName	=	strExcelColumnName 
				,@strTableCoulmnName	=	strTableCoulmnName
				,@strRefTable			=	strRefTable
				,@strRefTableIdCol		=	strRefTableIdCol
				,@strRefCoulumnToCmpr	=	strRefCoulumnToCmpr
				,@strJoinType			=	strJoinType
				,@strSpecialJoin		=	strSpecialJoin
	   FROM		tblCTExcelAndTableColumnMap
	   WHERE	intExcelAndTableColumnMapId	=   @intExcelAndTableColumnMapId
	   
	   SELECT	 @strJoinType = CASE WHEN ISNULL(@strJoinType,'') <> '' THEN 'LEFT JOIN' ELSE @strJoinType END -- To trigger proper validation

	   IF @strJoinType LIKE  '%JOIN%'
	   BEGIN
		  SELECT @Alias = SUBSTRING(@strTableCoulmnName,4,LEN(@strTableCoulmnName) - 5)
		  SELECT @SelColumn = @Alias + '.' + @strRefTableIdCol
	   
		  IF @strJoinType = 'JOIN'
		  BEGIN
			 IF ISNULL(@strSpecialJoin,'') <> ''
				SELECT  @Join += ' ' + @strSpecialJoin + ' '
			 ELSE
				SELECT  @Join += ' JOIN ' + @strRefTable + ' ' + @Alias + ' ON LTRIM(RTRIM(EX.[' + @strExcelColumnName + '])) = ' + @Alias + '.[' + @strRefCoulumnToCmpr + ']  COLLATE Latin1_General_CI_AS '
		  END
		  ELSE
		  BEGIN
			 IF ISNULL(@strSpecialJoin,'') <> ''
				SELECT  @LeftJoin += ' ' + @strSpecialJoin + ' '
			 ELSE
				SELECT  @LeftJoin += ' LEFT JOIN ' + @strRefTable + ' ' + @Alias + ' ON LTRIM(RTRIM(EX.[' + @strExcelColumnName + '])) = ' + @Alias + '.[' + @strRefCoulumnToCmpr + ']  COLLATE Latin1_General_CI_AS '
		  END
	   END
	   ELSE
	   BEGIN
		  SELECT @Alias = 'EX'
		  SELECT @SelColumn = @Alias + '.[' + @strExcelColumnName + ']'
	   END

	   SELECT  @SelColumn = CASE WHEN SUBSTRING(@strTableCoulmnName,1,3) = 'dbl' THEN  'CAST(' + @SelColumn + ' AS NUMERIC(18,6)) '
						    WHEN SUBSTRING(@strTableCoulmnName,1,3) = 'int' THEN  'CAST(' + @SelColumn + ' AS INT) '
						    WHEN SUBSTRING(@strTableCoulmnName,1,3) = 'ysn' THEN  'CAST(' + @SelColumn + ' AS BIT) '
						    WHEN SUBSTRING(@strTableCoulmnName,1,3) = 'str' THEN  'CAST(' + @SelColumn + ' AS NVARCHAR(MAX)) '
						    ELSE @SelColumn END + ' AS ' + @strTableCoulmnName
	   SELECT  @Insertlist += CASE WHEN @Insertlist = '' THEN '[' + @strTableCoulmnName + ']' ELSE ', [' + @strTableCoulmnName+ ']' END
	   SELECT  @SelectList += CASE WHEN @SelectList = '' THEN @SelColumn  ELSE ', ' + @SelColumn  END


	   SELECT @intExcelAndTableColumnMapId = MIN(intExcelAndTableColumnMapId) FROM tblCTExcelAndTableColumnMap WHERE strTableName = @TableToImport AND intExcelAndTableColumnMapId > @intExcelAndTableColumnMapId
    END


    SELECT @Query = REPLACE(@Query,'*',@SelectList) + @Join + @LeftJoin + ' WHERE EX.intRowId = ' + LTRIM(@intRowId) 

    SELECT @Query += ' DECLARE @XML NVARCHAR(MAX) '  
				+' EXEC uspCTGetTableDataInXML ''#tempExcelContractHeader'',NULL,@XML OUTPUT ' 
				--+' SELECT @XML' 
				+' SELECT @XML = REPLACE(@XML,''tempExcelContractHeader'','''+@TableToImport+''') ' 
				+' SELECT @XML = REPLACE(@XML,''</'+@TableToImport+'>'',''<intCreatedById>1</intCreatedById><dtmCreated>'+LTRIM(GETDATE())+'</dtmCreated></'+@TableToImport+'>'') ' 
				+' EXEC ['+@ValidationSP+'] @XML,''Added'''
				+' EXEC uspCTInsertINTOTableFromXML '''+@TableToImport+''',@XML, @intId OUTPUT ' 
			 
    --SELECT @Query
    EXEC sp_executesql @Query,N'@intId INT OUTPUT',@intId = @intId OUTPUT

    --SELECT @intId


END TRY
BEGIN CATCH
    SET @ErrMsg = ERROR_MESSAGE()      
    RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
END CATCH