
--GO
--CREATE PROCEDURE [dbo].[uspSMReplicationSetIdentityNotForReplication] 
--@tableName as nvarchar(100)
--AS
--BEGIN
--		Declare @int int;
--		set @int =object_id(@tableName)
--		EXEC sys.sp_identitycolumnforreplication @int, 1
			
--End

CREATE PROCEDURE [dbo].[uspSMReplicationSetIdentityNotForReplication] 
@parentDB NVARCHAR(100),
@type BIT
AS
BEGIN

 IF object_id('tempdb..#ListOfArticles') IS NOT NULL
	DROP TABLE #ListOfArticles

	   CREATE TABLE dbo.#ListOfArticles 
	   (   
		  strArticle NVARCHAR(100),
		  intId INT
	   ) 

   		DECLARE @sql NVARCHAR(MAX) = N'';
		DECLARE @insertSQL NVARCHAR(MAX) = '';
	
	   --PARENT
		IF( @type = 1)
			BEGIN
				SET @insertSQL = N'INSERT INTO #ListOfArticles
								SELECT DISTINCT Tab.strTableName, object_id(Tab.strTableName) FROM [parentDB].[dbo].[tblSMReplicationConfiguration] AS Con
								INNER JOIN tblSMReplicationConfigurationTable AS ConTab
								ON Con.intReplicationConfigurationId = ConTab.intReplicationConfigurationId
								INNER JOIN tblSMReplicationTable AS Tab
								ON ConTab.intReplicationTableId = Tab.intReplicationTableId
								WHERE strType = ''Parent'' AND ysnCommitted = 1 AND ysnEnabled = 1 '

			END
	   ELSE 
			BEGIN
			    SET @insertSQL = N'INSERT INTO #ListOfArticles
								SELECT DISTINCT Tab.strTableName, object_id(Tab.strTableName) FROM [parentDB].[dbo].[tblSMReplicationConfiguration] AS Con
								INNER JOIN tblSMReplicationConfigurationTable AS ConTab
								ON Con.intReplicationConfigurationId = ConTab.intReplicationConfigurationId
								INNER JOIN tblSMReplicationTable AS Tab
								ON ConTab.intReplicationTableId = Tab.intReplicationTableId
								WHERE strType = ''Subsidiary'' AND ysnCommitted = 1 AND ysnEnabled = 1 '

				
			END	

			SET @insertSQL =  Replace(@insertSQL, 'parentDB', @parentDB)
	        EXECUTE sp_executesql @insertSQL;



		SELECT @sql += N'exec sys.sp_identitycolumnforreplication '
				    + N''+CAST(intId AS NVARCHAR(MAX))+ ', 1 '
					FROM #ListOfArticles
		
				
    	EXEC  sp_executesql @sql;



  --DECLARE @int INT;
  ----DECLARE @sql NVARCHAR(MAX) = N'';
  --DECLARE @ListOfArticles TABLE(strArticle VARCHAR(100), intId INT);

  --INSERT INTO @ListOfArticles
  --      SELECT DISTINCT Tab.strTableName, object_id(Tab.strTableName) FROM tblSMReplicationConfiguration AS Con
		--INNER JOIN tblSMReplicationConfigurationTable AS ConTab
		--ON Con.intReplicationConfigurationId = ConTab.intReplicationConfigurationId
		--INNER JOIN tblSMReplicationTable AS Tab
		--ON ConTab.intReplicationTableId = Tab.intReplicationTableId
		--WHERE strType = 'Subsidiary' AND ysnCommitted = 1 AND ysnEnabled = 1


   
END
GO