  
CREATE PROCEDURE [dbo].[uspRKSavePnsOptionsMatched]  
	 @strXml nVarchar(Max)
AS  
BEGIN TRY  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  
  
DECLARE @idoc int   
Declare @intOptionsMatchPnSHeaderId int  
Declare @strTranNo nVarchar(50)  
Declare @dtmMatchDate  datetime  
Declare @intMatchQty int  
Declare @intLFutOptTransactionId int  
Declare @intSFutOptTransactionId int  
Declare @ErrMsg nvarchar(Max)

EXEC sp_xml_preparedocument @idoc OUTPUT, @strXml    
  
 BEGIN TRANSACTION		
  
 INSERT INTO tblRKOptionsMatchPnSHeader 
		(
			intConcurrencyId
		)
 VALUES
		(
		   1		
		 )

SELECT @intOptionsMatchPnSHeaderId = SCOPE_IDENTITY();  

SELECT @strTranNo=isnull(max(strTranNo),0) from tblRKOptionsMatchPnS   
 
   INSERT INTO tblRKOptionsMatchPnS
		(	
		intOptionsMatchPnSHeaderId,
		strTranNo,	
		dtmMatchDate,
		intMatchQty,
		intLFutOptTransactionId,
		intSFutOptTransactionId,
		intConcurrencyId		
		)  

 SELECT  
	@intOptionsMatchPnSHeaderId as intOptionsMatchPnSHeaderId,
	@strTranNo + ROW_NUMBER()over(order by intLFutOptTransactionId)strTranNo,
	dtmMatchDate,
	intMatchQty,
	intLFutOptTransactionId,
	intSFutOptTransactionId,
	1 as intConcurrencyId		
  FROM OPENXML(@idoc,'root/Transaction', 2)      
 WITH    
 ( 
	[intOptionsMatchPnSHeaderId] int ,
	[dtmMatchDate]  DATETIME  , 
    [intMatchQty] int , 
	[intLFutOptTransactionId] INT,
	[intSFutOptTransactionId] INT
 )   
   
Commit Tran  
  
EXEC sp_xml_removedocument @idoc   
  
END TRY    
    
BEGIN CATCH    
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION        
 SET @ErrMsg = ERROR_MESSAGE()    
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc    
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')    
    
END CATCH