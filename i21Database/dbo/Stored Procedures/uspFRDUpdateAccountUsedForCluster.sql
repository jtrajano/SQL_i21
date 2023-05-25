CREATE PROCEDURE  [dbo].[uspFRDUpdateAccountUsedForCluster]          
@intRowDetailId INT	 ,      
@intAccountGroupClusterId INT,
@intAccountGroupId INT
           
AS          
BEGIN          
          
SET QUOTED_IDENTIFIER OFF          
SET ANSI_NULLS ON          
SET NOCOUNT ON          
        
 
 DECLARE @strAccountUsed AS NVARCHAR(MAX)    
 DECLARE @Rowcount AS INT  = 0        
                     
	SET @Rowcount  = (
		SELECT COUNT(0) FROM tblGLAccountGroupClusterDetail WHERE  intAccountGroupClusterId = @intAccountGroupClusterId and intAccountGroupId = @intAccountGroupId 
	)

	IF @Rowcount = 0 
		BEGIN
	
			INSERT INTO tblFRRowDesignFilterAccount (intRowDetailId,intRowId,intRefNoId,strName,strCondition,strCriteria,strCriteriaBetween,strJoin,intConcurrencyId)
			SELECT 
			@intRowDetailId,
			0,
			0,
			'Group',
			'=',
			(SELECT TOP 1 strAccountGroup FROM tblGLAccountGroup WHERE intAccountGroupClusterId = @intAccountGroupClusterId   AND intAccountGroupId = intAccountGroupId),
			'',
			'',
			1
			FROM tblGLAccountGroupClusterDetail  T0
			INNER JOIN tblGLAccount T1 ON  T0.intAccountId = T1.intAccountId
			WHERE intAccountGroupClusterId =  @intAccountGroupClusterId and T0.intAccountGroupId =  @intAccountGroupId 
	
		END
	ELSE
		BEGIN
			
			SET @strAccountUsed = CONVERT(NVARCHAR(MAX),(SELECT '[ID]  =  ' + '''' + strAccountId + '''' + ' Or ' 
				FROM tblGLAccountGroupClusterDetail  T0
				INNER JOIN tblGLAccount T1 ON  T0.intAccountId = T1.intAccountId
				WHERE intAccountGroupClusterId =  @intAccountGroupClusterId and T0.intAccountGroupId =  @intAccountGroupId
				ORDER BY strAccountId
				FOR XML PATH (''), TYPE)
			)

			SET @strAccountUsed = (
				SELECT TRIM(LEFT(@strAccountUsed,(LEN(@strAccountUsed) - 3))) 
			)

			UPDATE tblFRRowDesign SET strAccountsUsed = @strAccountUsed  WHERE intRowDetailId = @intRowDetailId
						
			--FILTER ACCOUNTS

			INSERT INTO tblFRRowDesignFilterAccount (intRowDetailId,intRowId,intRefNoId,strName,strCondition,strCriteria,strCriteriaBetween,strJoin,intConcurrencyId)
			SELECT 
			@intRowDetailId,
			(SELECT TOP 1 intRowId FROM tblFRRowDesign WHERE intRowDetailId = @intRowDetailId),
			(SELECT TOP 1 intRefNo FROM tblFRRowDesign WHERE intRowDetailId = @intRowDetailId),
			'ID',
			'=',
			strAccountId,
			NULL,
			'Or',
			1
			FROM tblGLAccountGroupClusterDetail  T0
			INNER JOIN tblGLAccount T1 ON  T0.intAccountId = T1.intAccountId
			WHERE intAccountGroupClusterId =  @intAccountGroupClusterId and T0.intAccountGroupId =  @intAccountGroupId 
		END

 END                          