CREATE  PROCEDURE [dbo].[uspSMRepAddArticleSubToParent]
@result int output,
@publication  As sysname,
@parentDB NVARCHAR(100)

 AS
 BEGIN
 IF object_id('tempdb..#ListOfArticles') IS NOT NULL
	DROP TABLE #ListOfArticles

   CREATE TABLE dbo.#ListOfArticles 
   (   
    strArticle NVARCHAR(100)
   ) 
  
 
		--DECLARE @result int;
		--DECLARE @ListOfArticles TABLE(strArticle NVARCHAR(100));
	--	DECLARE @ListOfArticles dbo.SubsidiaryType ;
		DECLARE @sql NVARCHAR(MAX) = N'';
		DECLARE @insertSQL NVARCHAR(MAX) = '';
	

	  SET @insertSQL = N'INSERT INTO #ListOfArticles
		SELECT DISTINCT Tab.strTableName FROM [parentDB].[dbo].[tblSMReplicationConfiguration] AS Con
		INNER JOIN tblSMReplicationConfigurationTable AS ConTab
		ON Con.intReplicationConfigurationId = ConTab.intReplicationConfigurationId
		INNER JOIN tblSMReplicationTable AS Tab
		ON ConTab.intReplicationTableId = Tab.intReplicationTableId
		WHERE strType = ''Subsidiary'' AND ysnCommitted = 1 AND ysnEnabled = 1 '

		
		--SET @insertSQL = 'Exec('' ' + Replace(@insertSQL, 'parentDB', @parentDB) + ' '')'
		SET @insertSQL =  Replace(@insertSQL, 'parentDB', @parentDB)
		
        EXECUTE sp_executesql @insertSQL;
		
		
					SELECT @sql += N'exec sp_addarticle '
					+ N'@publication = '''+@publication+N''','
					+ N'@article = '''+ strArticle + N''','
					+ N'@source_owner = ''dbo'', '
					+ N'@source_object = ''' + strArticle + N''', '	
					+ N'@type = ''logbased'', ' 
					+ N'@description = '''', ' 
					+ N'@creation_script = '''', '
					+ N'@pre_creation_cmd = ''truncate'',  ' 
					+ N'@schema_option = 0x000000000803509F, '
					+ N'@identityrangemanagementoption = ''manual'', '							
					+ N'@destination_table = ''' + strArticle + N''', '	
					+ N'@destination_owner = ''dbo'', ' 
					+ N'@force_invalidate_snapshot = 1, ' 
					+ N'@status = 24, '
					+ N'@vertical_partition = ''false'', '
					+ N'@ins_cmd = ''CALL [sp_MSins_dbo'+strArticle+N']'', ' 
					+ N'@del_cmd = ''CALL [sp_MSdel_dbo'+strArticle+N']'',  ' 
					+ N'@upd_cmd = ''SCALL [sp_MSupd_dbo'+strArticle+N']'';'	
					FROM sys.tables as systables
					INNER JOIN #ListOfArticles as articles
					ON systables.name = articles.strArticle
					WHERE is_replicated = 0;

					
				EXEC @result = sp_executesql @sql;	
		
END