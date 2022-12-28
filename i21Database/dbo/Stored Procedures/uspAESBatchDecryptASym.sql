CREATE PROCEDURE [dbo].[uspAESBatchDecryptASym]  
  @aesParam AESParam READONLY
AS  
BEGIN  
  
 SELECT [Id], 
		dbo.fnAESDecryptASym([Text]) 
 FROM @aesParam 
 ORDER BY [Id] ASC
      
END