CREATE  PROCEDURE [dbo].[uspSMRepAddArticleParentToSub]
@result int OUTPUT,
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
		WHERE strType = 'Parent' AND ysnEnabled = 1 AND (ysnInitOnly != 1 OR ysnInitOnly IS null)

			



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
		
											
					FROM @ListOfArticles; 

				--Executed Created Query
				exec @result = sp_executesql @sql;
				--select @result			
			
End

