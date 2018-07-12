
/****** Object:  StoredProcedure [dbo].[uspSMRepAddArticleSubToParent]    Script Date: 01/06/2018 1:48:54 PM ******/

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
    strArticle NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
   ) 
  
 
		--DECLARE @result int;
		--DECLARE @ListOfArticles TABLE(strArticle NVARCHAR(100));
	--	DECLARE @ListOfArticles dbo.SubsidiaryType ;
		DECLARE @sql NVARCHAR(MAX) = N'';
		DECLARE @insertSQL NVARCHAR(MAX) = '';
	
	 SET @insertSQL = N'INSERT INTO #ListOfArticles
		SELECT DISTINCT Tab.strTableName FROM [parentDB].[dbo].[tblSMReplicationConfiguration] AS Con
		INNER JOIN [parentDB].[dbo].[tblSMReplicationConfigurationTable] AS ConTab
		ON Con.intReplicationConfigurationId = ConTab.intReplicationConfigurationId
		INNER JOIN [parentDB].[dbo].[tblSMReplicationTable] AS Tab
		ON ConTab.intReplicationTableId = Tab.intReplicationTableId
		WHERE strType = ''Subsidiary'' OR (strType = ''Parent'' AND strTableName LIKE ''%tblGL%'') AND ysnCommitted = 1 AND ysnEnabled = 1 AND (ysnInitOnly = 0 OR ysnInitOnly IS null )'
	

		
		--SET @insertSQL = 'Exec('' ' + Replace(@insertSQL, 'parentDB', @parentDB) + ' '')'
		SET @insertSQL =  Replace(@insertSQL, 'parentDB', @parentDB)
		
        EXECUTE sp_executesql @insertSQL;
		
					SELECT @sql += N'exec sp_addarticle '
					+ N'@publication = '''+@publication+''','
					+ N'@article = '''+ strArticle + ''','
					+ N'@source_owner = ''dbo'', '
					+ N'@source_object = ''' + strArticle + ''', '	
					+ N'@type = ''logbased'', ' 
					+ N'@description = '''', ' 
					+ N'@creation_script = '''', '
					+ N'@pre_creation_cmd = ''truncate'',  ' 
					+ N'@schema_option = 0x000000000803509F, '
					+ N'@identityrangemanagementoption = ''manual'', '							
					+ N'@destination_table = ''' + strArticle + ''', '	
					+ N'@destination_owner = ''dbo'', ' 
					+ N'@force_invalidate_snapshot = 1, ' 
					+ N'@status = 24, '
					+ N'@vertical_partition = ''false'', '
					+ N'@ins_cmd = ''CALL [sp_MSins_dbo'+strArticle+']'', ' 
					+ N'@del_cmd = ''CALL [sp_MSdel_dbo'+strArticle+']'',  ' 
					+ N'@upd_cmd = ''SCALL [sp_MSupd_dbo'+strArticle+']'';'	
		
											
					FROM #ListOfArticles; 

					SELECT @sql;
				EXEC @result = sp_executesql @sql;	
		
END