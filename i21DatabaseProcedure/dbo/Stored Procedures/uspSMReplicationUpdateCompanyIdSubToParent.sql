CREATE PROCEDURE uspSMReplicationUpdateCompanyIdSubToParent
@result INT OUTPUT,
@intCompanyId INT,
@parentDB NVARCHAR(MAX)

AS
BEGIN

DECLARE @addConstraint nvarchar(max)= N'';
DECLARE @dropConstraint nvarchar(max)= N'';
--DECLARE @num int= 1;
DECLARE @table nvarchar(MAX);
DECLARE @dbotable nvarchar(MAX);
DECLARE @Constraint nvarchar(MAX); 
--DECLARE @ListOfArticles TABLE(strArticle NVARCHAR(MAX));


    DECLARE @INSERTSQL NVARCHAR(MAX) = '';

	 IF OBJECT_ID('tempdb..#ListOfArticles') IS NOT NULL
	   DROP TABLE #ListOfArticles

	   CREATE TABLE dbo.#ListOfArticles 
	   (   
		strArticle NVARCHAR(MAX)
	   ) 

	SET @INSERTSQL = N'INSERT INTO #ListOfArticles
		    SELECT DISTINCT Tab.strTableName FROM [parentDB].[dbo].[tblSMReplicationConfiguration] AS Con
			INNER JOIN [parentDB].[dbo].[tblSMReplicationConfigurationTable] AS ConTab
			ON Con.intReplicationConfigurationId = ConTab.intReplicationConfigurationId
			INNER JOIN [parentDB].[dbo].[tblSMReplicationTable] AS Tab
			ON ConTab.intReplicationTableId = Tab.intReplicationTableId
			WHERE strType = ''Subsidiary'' AND ysnCommitted = 1 AND ysnEnabled = 1 ';

			SET @INSERTSQL = REPLACE(@INSERTSQL,'parentDB',@parentDB)
			EXECUTE sp_executesql @INSERTSQL;

								

  WHILE  (SELECT COUNT(*) FROM #ListOfArticles) != 0
    BEGIN

			SELECT TOP 1 @table = strArticle FROM #ListOfArticles;		
			SET @dbotable = N'dbo.'+@table;
			SET @Constraint = N'df_'+@table+'_intCompanyId';


			IF EXISTS(SELECT 1 FROM sys.columns 
					WHERE name = N'intCompanyId'
					AND object_id = object_id(@dbotable))
			BEGIN
				SET @addConstraint = N''
				SET @dropConstraint = N''

					IF EXISTS ( SELECT 1 
								FROM sys.default_constraints 
								WHERE object_id = OBJECT_ID(@Constraint) 
								AND parent_object_id = OBJECT_ID(@table)
							)
						BEGIN
							--Create Query for adding articles
							SELECT @dropConstraint += Replace(Replace(N'ALTER TABLE @tbl DROP constraint df_@tbl_intCompanyId','@tbl', @table),'@num', @intCompanyId);  
							SELECT @addConstraint += Replace(Replace(N'ALTER TABLE @tbl ADD constraint df_@tbl_intCompanyId DEFAULT @num For intCompanyId','@tbl', @table),'@num', @intCompanyId);
				
							EXEC (@dropConstraint)
							EXEC (@addConstraint)
						END
					ELSE
						BEGIN
							SELECT @addConstraint += Replace(Replace(N'ALTER TABLE @tbl ADD constraint df_@tbl_intCompanyId DEFAULT @num For intCompanyId','@tbl', @table),'@num', @intCompanyId)
							EXEC (@addConstraint)
						END
             
			END



    DELETE from #ListOfArticles Where strArticle = @table
  END

END