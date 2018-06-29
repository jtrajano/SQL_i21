CREATE  PROCEDURE [dbo].[uspSMRepSnapshotAddArticleParentToSub]
@result int OUTPUT,
 @publication  As sysname

 As
 Begin
		--DECLARE @result int;
		DECLARE @ListOfArticles TABLE(strArticle NVARCHAR(MAX));
		DECLARE @sql NVARCHAR(MAX) = N'';

		INSERT INTO @ListOfArticles
	    SELECT DISTINCT Tab.strTableName FROM tblSMReplicationConfiguration AS Con
		INNER JOIN tblSMReplicationConfigurationTable AS ConTab
		ON Con.intReplicationConfigurationId = ConTab.intReplicationConfigurationId
		INNER JOIN tblSMReplicationTable AS Tab
		ON ConTab.intReplicationTableId = Tab.intReplicationTableId
		WHERE strType = 'Parent' AND ysnEnabled = 1 



		--Create Query for adding articles
			SELECT @sql += N'exec sp_addarticle '
			+ N'@publication = '''+@publication+N''','
			+ N'@article = '''+ strArticle + N''','
			+ N'@source_owner = ''dbo'', '
			+ N'@source_object = ''' + strArticle + N''', '	
			+ N'@type = ''logbased'', ' 
			+ N'@description = null, ' 
			+ N'@creation_script = null, '
			+ N'@pre_creation_cmd = ''truncate'',  ' 
			+ N'@schema_option = 0x000000000803509, '
			+ N'@identityrangemanagementoption = ''manual'', '							
			+ N'@destination_table = ''' + strArticle + N''', '	
			+ N'@destination_owner = ''dbo'',' 		
			+ N'@vertical_partition = ''false''' 											
			FROM 	@ListOfArticles 

		--Executed Created Query
		exec @result = sp_executesql @sql;
		--select @result			
			
End

