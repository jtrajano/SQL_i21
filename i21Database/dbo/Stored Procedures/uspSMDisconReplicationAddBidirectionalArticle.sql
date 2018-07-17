CREATE  PROCEDURE [dbo].[uspSMDisconReplicationAddBidirectionalArticle]
@result int output,
@publication  As sysname

 AS

 BEGIN
 IF object_id('tempdb..#ListOfArticles') IS NOT NULL
	DROP TABLE #ListOfArticles

   CREATE TABLE dbo.#ListOfArticles 
   (   
    strArticle NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
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

				
				EXEC @result = sp_executesql @sql;	
		
END
