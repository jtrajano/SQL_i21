CREATE PROCEDURE [dbo].[uspSMDisconReplicationSetIdentityNotForReplication] 

AS
BEGIN

 IF object_id('tempdb..#ListOfArticles') IS NOT NULL
	DROP TABLE #ListOfArticles

	   CREATE TABLE dbo.#ListOfArticles 
	   (   
		  strArticle NVARCHAR(MAX),
		  intId INT
	   ) 

   		DECLARE @sql NVARCHAR(MAX) = N'';
		DECLARE @insertSQL NVARCHAR(MAX) = '';
	

		 BEGIN
				--SET @insertSQL = N'INSERT INTO #ListOfArticles
				--				SELECT DISTINCT Tab.strTableName, object_id(Tab.strTableName) FROM [tblSMReplicationConfiguration] AS Con
				--				INNER JOIN [tblSMReplicationConfigurationTable] AS ConTab
				--				ON Con.intReplicationConfigurationId = ConTab.intReplicationConfigurationId
				--				INNER JOIN [tblSMReplicationTable] AS Tab
				--				ON ConTab.intReplicationTableId = Tab.intReplicationTableId
				--				WHERE strType = ''Parent'' OR strTableName LIKE ''%tblSC%'' '


				SET @insertSQL = N'INSERT INTO #ListOfArticles
					SELECT strTableName FROM tblSMDisconReplicationArticle ORDER BY strTableName '
	    END

			      
	   EXECUTE sp_executesql @insertSQL;



	   SELECT @sql += N'exec sys.sp_identitycolumnforreplication '
				    + N''+CAST(intId AS NVARCHAR(MAX))+ ', 1 '
					FROM #ListOfArticles
		
				
       EXEC  sp_executesql @sql;





   
END



