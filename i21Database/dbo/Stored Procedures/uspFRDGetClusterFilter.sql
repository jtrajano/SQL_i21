CREATE PROCEDURE [dbo].[uspFRDGetClusterFilter]            
 @intRowDetailId INT  ,             
 @intSourcesType INT = 0 ,             
 @intCurrencyId INT = 0,        
 @result   NVARCHAR(MAX) = '' OUTPUT            
AS            
        
--intSourcesType        
        
--0 = Main        
--1 = Drilldown        
--2 = PrintEach        
          
 CREATE TABLE #TmpAccount(          
  strAccountUsed NVARCHAR(MAX)             
 )          
          
 DECLARE @strAccountUsed AS NVARCHAR(MAX)                
 DECLARE @intAccountGroupClusterId AS INT              
 DECLARE @intRowId AS INT              
 DECLARE @intRowIdDtl AS INT              
        
        
-- Main Report      
 IF @intSourcesType = 0         
 BEGIN         
 SET @intAccountGroupClusterId = (SELECT intAccountGroupClusterId FROM tblFRRow where intRowId = (SELECT TOP 1 intRowId FROM tblFRRowDesign WHERE intRowDetailId = @intRowDetailId))            
 SET @strAccountUsed = CONVERT(NVARCHAR(MAX),(SELECT '[ID]  =  ' + '''' + strAccountId + '''' + ' Or '          
  FROM tblGLAccountGroupClusterDetail  T0            
  INNER JOIN tblGLAccount T1 ON  T0.intAccountId = T1.intAccountId            
  WHERE intAccountGroupClusterId = @intAccountGroupClusterId AND           
  T0.intAccountGroupId in (SELECT intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup IN (SELECT strCriteria FROM tblFRRowDesignFilterAccount WHERE intRowDetailId = @intRowDetailId))           
  ORDER BY strAccountId            
  FOR XML PATH (''), TYPE)            
 )            
 END      
  
 --Print Each      
 IF @intSourcesType = 2    
 BEGIN         
 SET @intAccountGroupClusterId = (SELECT intAccountGroupClusterId FROM tblFRRow where intRowId = (SELECT TOP 1 intRowId FROM tblFRRowDesignPrintEach WHERE intRowDetailId = @intRowDetailId))            
 SET @intRowId  = (SELECT TOP 1 intRowId  FROM tblFRRowDesignPrintEach WHERE intRowDetailId = @intRowDetailId)         
 SET @intRowIdDtl = ( SELECT TOP 1 intRowDetailId FROM tblFRRowDesign WHERE intRowId = @intRowId  AND strAccountsUsed = (SELECT TOP 1 strAccountsUsed FROM tblFRRowDesignPrintEach WHERE intRowId = @intRowId AND intRowDetailId = @intRowDetailId))         
        
 SET @strAccountUsed = CONVERT(NVARCHAR(MAX),(SELECT '[ID]  =  ' + '''' + strAccountId + '''' + ' Or '          
  FROM tblGLAccountGroupClusterDetail  T0            
  INNER JOIN tblGLAccount T1 ON  T0.intAccountId = T1.intAccountId            
  WHERE intAccountGroupClusterId = @intAccountGroupClusterId AND           
  T0.intAccountGroupId in (SELECT intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup IN (SELECT strCriteria FROM tblFRRowDesignFilterAccount WHERE intRowDetailId = @intRowIdDtl))           
  ORDER BY strAccountId            
  FOR XML PATH (''), TYPE)            
 )            
 END            
   
  -- Currencies  source type 3    
 IF @intSourcesType = 3      
 BEGIN         
 SET @intAccountGroupClusterId = (SELECT intAccountGroupClusterId FROM tblFRRow where intRowId = (SELECT TOP 1 intRowId FROM tblFRRowDesignCurrencies WHERE intRowDetailId = @intRowDetailId))            
 SET @intRowId  = (SELECT TOP 1 intRowId  FROM tblFRRowDesignCurrencies WHERE intRowDetailId = @intRowDetailId)         
 SET @intRowIdDtl = ( SELECT TOP 1 intRowDetailId FROM tblFRRowDesign WHERE intRowId = @intRowId  AND strAccountsUsed = (SELECT TOP 1 strAccountsUsed FROM tblFRRowDesignCurrencies WHERE intRowId = @intRowId AND intRowDetailId = @intRowDetailId))         
        
 SET @strAccountUsed = CONVERT(NVARCHAR(MAX),(SELECT '[ID]  =  ' + '''' + strAccountId + '''' + ' Or '          
  FROM tblGLAccountGroupClusterDetail  T0            
  INNER JOIN tblGLAccount T1 ON  T0.intAccountId = T1.intAccountId            
  WHERE intAccountGroupClusterId = @intAccountGroupClusterId AND           
  T0.intAccountGroupId in (SELECT intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup IN (SELECT strCriteria FROM tblFRRowDesignFilterAccount WHERE intRowDetailId = @intRowIdDtl))           
  ORDER BY strAccountId            
  FOR XML PATH (''), TYPE)            
 )            
 END      
     
  -- Currencies      
 IF @intCurrencyId <> 0    
 BEGIN         
 SET @intAccountGroupClusterId = (SELECT intAccountGroupClusterId FROM tblFRRow where intRowId = (SELECT TOP 1 intRowId FROM tblFRRowDesignCurrencies WHERE intRowDetailId = @intRowDetailId))            
 SET @intRowId  = (SELECT TOP 1 intRowId  FROM tblFRRowDesignCurrencies WHERE intRowDetailId = @intRowDetailId)         
 SET @intRowIdDtl = ( SELECT TOP 1 intRowDetailId FROM tblFRRowDesign WHERE intRowId = @intRowId  AND strAccountsUsed = (SELECT TOP 1 strAccountsUsed FROM tblFRRowDesignCurrencies WHERE intRowId = @intRowId AND intRowDetailId = @intRowDetailId))         
        
 SET @strAccountUsed = CONVERT(NVARCHAR(MAX),(SELECT '[ID]  =  ' + '''' + strAccountId + '''' + ' Or '          
  FROM tblGLAccountGroupClusterDetail  T0            
  INNER JOIN tblGLAccount T1 ON  T0.intAccountId = T1.intAccountId            
  WHERE intAccountGroupClusterId = @intAccountGroupClusterId AND           
  T0.intAccountGroupId in (SELECT intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup IN (SELECT strCriteria FROM tblFRRowDesignFilterAccount WHERE intRowDetailId = @intRowIdDtl))           
  ORDER BY strAccountId            
  FOR XML PATH (''), TYPE)            
 )            
    
 END           
           
 SET @strAccountUsed = (            
  SELECT  RTRIM(LEFT(@strAccountUsed,(LEN(@strAccountUsed) - 3)))             
   )            
          
 INSERT INTO #TmpAccount          
 SELECT @strAccountUsed          
          
 SELECT @strAccountUsed          
          
 SET @result  = CAST(ISNULL(@strAccountUsed,'') as nvarchar(max)) 