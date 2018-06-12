
--GO


--CREATE PROCEDURE [dbo].[uspSMReplicationSetRangeStart]
-- @tableName as nvarchar(100),
-- @rangeStart as int
-- As
-- Begin
--		DECLARE @result int;
--		DECLARE @sql NVARCHAR(MAX) = N'';
--		SET @sql += Replace(Replace(N'DBCC CHECKIDENT(@tbl, RESEED, @num)','@tbl', @tableName),'@num', @rangeStart)
                    
--		--Executed Created Query
--		EXEC @result = sp_executesql @sql;			
			
--End

--GO


CREATE PROCEDURE [dbo].[uspSMReplicationSetRangeStart]
 @parentDB NVARCHAR(50),
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
		SELECT DISTINCT Tab.strTableName FROM [parentDB].[dbo].[tblSMReplicationConfiguration] AS Con
		INNER JOIN [parentDB].[dbo].[tblSMReplicationConfigurationTable] AS ConTab
		ON Con.intReplicationConfigurationId = ConTab.intReplicationConfigurationId
		INNER JOIN [parentDB].[dbo].[tblSMReplicationTable] AS Tab
		ON ConTab.intReplicationTableId = Tab.intReplicationTableId
		WHERE strType = ''Subsidiary'' AND ysnCommitted = 1 AND ysnEnabled = 1 '

		SET @insertSQL =  Replace(@insertSQL, 'parentDB', @parentDB)
		EXECUTE sp_executesql @insertSQL;

		SELECT @sql+= N' DBCC CHECKIDENT('+''+articles.strArticle+'' + N',''RESEED'','+ CAST(@rangeStart AS nvarchar(MAX)) + ' )'
		FROM #ListOfArticles AS articles

		EXEC  sp_executesql @sql;   
			
END


