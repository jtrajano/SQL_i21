CREATE PROCEDURE [dbo].[uspSMDisconReplicationSetRangeStart]
 @rangeStart AS INT

 AS
 BEGIN
	 IF object_id('tempdb..#ListOfArticles') IS NOT NULL
	    DROP TABLE #ListOfArticles

	   CREATE TABLE dbo.#ListOfArticles 
	   (   
		  strArticle NVARCHAR(MAX)
	   ) 

	   DECLARE @sql NVARCHAR(MAX) = N'';
	   DECLARE @insertSQL NVARCHAR(MAX) = '';

	    SET @insertSQL = N'INSERT INTO #ListOfArticles
		SELECT DISTINCT Tab.strTableName FROM [tblSMReplicationConfiguration] AS Con
		INNER JOIN [tblSMReplicationConfigurationTable] AS ConTab
		ON Con.intReplicationConfigurationId = ConTab.intReplicationConfigurationId
		INNER JOIN [tblSMReplicationTable] AS Tab
		ON ConTab.intReplicationTableId = Tab.intReplicationTableId
		AND strType = ''Parent''
		OR strTableName like ''%tblSC%''
		ORDER BY strTableName '

	
		EXECUTE sp_executesql @insertSQL;

		SELECT @sql+= N' DBCC CHECKIDENT('+''+articles.strArticle+'' + N',''RESEED'','+ CAST(@rangeStart AS nvarchar(MAX)) + ' )'
		FROM #ListOfArticles AS articles

		EXEC  sp_executesql @sql;   
			
END



