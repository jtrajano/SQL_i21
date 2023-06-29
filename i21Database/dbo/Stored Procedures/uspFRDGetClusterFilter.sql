CREATE PROCEDURE [dbo].[uspFRDGetClusterFilter]    
 @intRowDetailId INT  ,           
 @result   NVARCHAR(MAX) = '' OUTPUT    
AS    
  
 CREATE TABLE #TmpAccount(  
  strAccountUsed NVARCHAR(MAX)     
 )  
  
 DECLARE @strAccountUsed AS NVARCHAR(MAX)        
 DECLARE @intAccountGroupClusterId AS INT      
  
 SET @intAccountGroupClusterId = (SELECT intAccountGroupClusterId FROM tblFRRow where intRowId = (SELECT TOP 1 intRowId FROM tblFRRowDesign WHERE intRowDetailId = @intRowDetailId))    
  
 SET @strAccountUsed = CONVERT(NVARCHAR(MAX),(SELECT '[ID]  =  ' + '''' + strAccountId + '''' + ' Or '  
  FROM tblGLAccountGroupClusterDetail  T0    
  INNER JOIN tblGLAccount T1 ON  T0.intAccountId = T1.intAccountId    
  WHERE intAccountGroupClusterId = @intAccountGroupClusterId AND   
  T0.intAccountGroupId in (SELECT intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup IN (SELECT strCriteria FROM tblFRRowDesignFilterAccount WHERE intRowDetailId = @intRowDetailId))   
  ORDER BY strAccountId    
  FOR XML PATH (''), TYPE)    
 )    
  
 SET @strAccountUsed = (    
  SELECT  RTRIM(LEFT(@strAccountUsed,(LEN(@strAccountUsed) - 3)))     
   )    
  
 INSERT INTO #TmpAccount  
 SELECT @strAccountUsed  
  
 SELECT @strAccountUsed  
  
 SET @result  = CAST(ISNULL(@strAccountUsed,'') as nvarchar(max))  