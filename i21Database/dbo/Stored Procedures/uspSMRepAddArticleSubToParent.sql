CREATE  PROCEDURE [dbo].[uspSMRepAddArticleSubToParent]
@result int output,
 @publication  As sysname
 As
 Begin
		--DECLARE @result int;
		DECLARE @ListOfArticles TABLE(strArticle VARCHAR(100));
		DECLARE @sql NVARCHAR(MAX) = N'';

			INSERT INTO @ListOfArticles
		SELECT DISTINCT Tab.strTableName FROM tblSMReplicationConfiguration AS Con
		INNER JOIN tblSMReplicationConfigurationTable AS ConTab
		ON Con.intReplicationConfigurationId = ConTab.intReplicationConfigurationId
		INNER JOIN tblSMReplicationTable AS Tab
		ON ConTab.intReplicationTableId = Tab.intReplicationTableId
		WHERE strType = 'Subsidiary' AND ysnCommitted = 1 AND ysnEnabled = 1



			--Create Query for adding articles
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
					INNER JOIN @ListOfArticles as articles
					ON systables.name = articles.strArticle
					WHERE is_replicated = 0;

				--Executed Created Query
				EXEC @result = sp_executesql @sql;			
			
End

