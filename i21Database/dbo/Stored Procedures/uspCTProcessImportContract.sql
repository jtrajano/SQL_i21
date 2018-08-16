CREATE PROCEDURE [dbo].[uspCTProcessImportContract]
	
	@intUserId				INT,
	@TableFromImport		NVARCHAR(100),
	@TableToImport			NVARCHAR(100),
	@ValidationSP			NVARCHAR(100),
	@ParentTableFromImport	NVARCHAR(100)

 AS
 BEGIN TRY
	DECLARE	 @ErrMsg	NVARCHAR(MAX),
			 @Query		NVARCHAR(MAX)

    SELECT @Query = '
    IF NOT EXISTS(SELECT *FROM sysobjects SO Inner Join syscolumns SC ON SO.id=SC.id WHERE SO.type=''U'' AND SO.name='''+@TableFromImport+''' and SC.name=''intRowId'')	
    BEGIN	
		ALTER	TABLE '+@TableFromImport+'	
		ADD		intRowId INT IDENTITY(1,1),
				intGeneratedId INT,
				intParentRowId INT,
				intConcurrencyId INT NULL,
				dtmImported    DATETIME,
				strErrorMsg	  NVARCHAR(MAX)
    END'	

    EXEC sp_executesql  @Query

    SELECT @Query = 'UPDATE '+@TableFromImport+' SET intConcurrencyId = 1'

    EXEC sp_executesql @Query

    SELECT @Query = '
    DECLARE		@intRowId		  INT,
				@intGeneratedId	  INT,
				@ErrMsg			  NVARCHAR(MAX)

    SELECT @intRowId = MIN(intRowId) FROM '+@TableFromImport+' WHERE intGeneratedId IS NULL

    WHILE	ISNULL(@intRowId,0) > 0
    BEGIN
	   BEGIN TRY

	   EXEC uspCTImportContract '+@TableFromImport+','+@TableToImport+','+@ValidationSP+', @intRowId,@intGeneratedId OUTPUT

		  UPDATE	'+@TableFromImport+'
		  SET	dtmImported	=	  GETDATE(),
				intGeneratedId =	  @intGeneratedId
		  WHERE	intRowId	     =	  @intRowId
	   END TRY
	   BEGIN CATCH
		  SET @ErrMsg = ERROR_MESSAGE() 
		  UPDATE	'+@TableFromImport+'
		  SET	dtmImported	=	  GETDATE(),
				strErrorMsg	=	  @ErrMsg
		  WHERE	intRowId		=	  @intRowId
	   END CATCH

	   SELECT @intRowId = MIN(intRowId) FROM '+@TableFromImport+' WHERE intGeneratedId IS NULL AND intRowId > @intRowId
    END
    '
    --SELECT @query
    EXEC sp_executesql @query

 END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH
