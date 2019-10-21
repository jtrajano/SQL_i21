CREATE PROCEDURE [dbo].[uspSMDisconReplicationSetRangeStart]
 @rangeStart AS INT

 AS
 BEGIN

  IF OBJECT_ID('tempdb..#DisconArticles') IS NOT NULL
		DROP TABLE #DisconArticles

		CREATE TABLE #DisconArticles
		(
		    id INT IDENTITY(1,1) PRIMARY KEY,
			strArticle NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		)

		DECLARE @insertSQL NVARCHAR(MAX) = '';
		DECLARE @IDENT_RANGE INT = @rangeStart --(SELECT intRange FROM tblRange WHERE strServer = @@SERVERNAME)
					
		IF (@IDENT_RANGE IS NULL)
			BEGIN
				PRINT 'SERVER NOT FOUND ON RANGE TABLES!!!'
				RETURN;
			END

		SET @insertSQL = N'INSERT INTO #DisconArticles (strArticle) 
			SELECT DISTINCT strTableName FROM tblSMDisconReplicationArticle ORDER BY strTableName '
			--insert articles
			EXECUTE sp_executesql @insertSQL;

			--DECLARE @totalRows INT = (SELECT COUNT(*) FROM #DisconArticles)
			WHILE((SELECT COUNT(*) FROM #DisconArticles) > 0)
				BEGIN
					DECLARE @CURRENT_IDENT INT = @rangeStart;
					DECLARE @ID INT = (SELECT TOP 1 id FROM #DisconArticles)
					DECLARE @article NVARCHAR(MAX) = (SELECT TOP 1 strArticle FROM #DisconArticles)
					DECLARE @IDENT_NAME NVARCHAR(MAX) = (SELECT name FROM sys.columns WHERE [object_id] = OBJECT_ID(@article) AND is_identity = 1)
					DECLARE @seed_query NVARCHAR(MAX) = N'';
				
				DECLARE @paramdef NVARCHAR(MAX) = N'@CURRENT_IDENT nvarchar(max) OUTPUT'

				declare @query nvarchar(max) =	N'SELECT @CURRENT_IDENT = MAX(@IDENT_NAME) FROM ' +
												' @article  WHERE ' +
												' @IDENT_NAME BETWEEN  @IDENT_RANGE   AND  ((@IDENT_RANGE + 100000000) - 1)';

				SET @query = REPLACE(REPLACE(REPLACE(@query,'@IDENT_NAME', @IDENT_NAME),'@IDENT_RANGE',@IDENT_RANGE),'@article',@article) --REPLACE(REPLACE(REPLACE(REPLACE(@query,'@CURRENT_IDENT',@CURRENT_IDENT),'@article',@article),'@IDENT_NAME',@IDENT_NAME),'@IDENT_RANGE',@IDENT_RANGE)
			    exec sp_executesql @query,@paramdef,@CURRENT_IDENT OUTPUT
			
				IF (@CURRENT_IDENT IS NULL OR @CURRENT_IDENT = 0) -- 0 means no record
					BEGIN
						--SET IDENTITY
					SET @seed_query = N' DBCC CHECKIDENT('+''+ @article +'' + N',''RESEED'','+ CAST((@IDENT_RANGE + 1) AS nvarchar(MAX)) + ' )'
					
					END
				ELSE 
					BEGIN
						SET @seed_query = N' DBCC CHECKIDENT('+''+ @article +'' + N',''RESEED'','+ CAST(@CURRENT_IDENT AS nvarchar(MAX)) + ' )'
						
					END

						EXEC sp_executesql @seed_query

				
				
				DELETE #DisconArticles WHERE id = @ID

				END



	 --IF object_id('tempdb..#ListOfArticles') IS NOT NULL
	 --   DROP TABLE #ListOfArticles

	 --  CREATE TABLE dbo.#ListOfArticles 
	 --  (   
		--  strArticle NVARCHAR(MAX)
	 --  ) 

	 --  DECLARE @sql NVARCHAR(MAX) = N'';
	 --  DECLARE @insertSQL NVARCHAR(MAX) = '';



	 -- SET @insertSQL = N'INSERT INTO #ListOfArticles
		--		SELECT DISTINCT strTableName FROM tblSMDisconReplicationArticle ORDER BY strTableName '

	
		--EXECUTE sp_executesql @insertSQL;

		--SELECT @sql+= N' DBCC CHECKIDENT('+''+articles.strArticle+'' + N',''RESEED'','+ CAST(@rangeStart AS nvarchar(MAX)) + ' )'
		--FROM #ListOfArticles AS articles

		--EXEC  sp_executesql @sql;   
			
END



