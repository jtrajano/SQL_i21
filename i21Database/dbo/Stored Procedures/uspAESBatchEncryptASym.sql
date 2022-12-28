CREATE PROCEDURE [dbo].[uspAESBatchEncryptASym]  
  @aesParam AESParam READONLY
AS  
BEGIN  
  
 SELECT [Id], 
		dbo.fnAESEncryptASym([Text]) 
 FROM @aesParam 
 ORDER BY [Id] ASC
      
END