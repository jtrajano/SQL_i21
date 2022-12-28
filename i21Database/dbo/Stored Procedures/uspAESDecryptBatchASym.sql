CREATE PROCEDURE [dbo].[uspAESDecryptBatchASym]  
  @aesParam AESParam READONLY
AS  
BEGIN  
  
 SELECT [Id], 
		dbo.fnAESDecryptASym([Text]) 
 FROM @aesParam 
 ORDER BY [Id] ASC
      
END