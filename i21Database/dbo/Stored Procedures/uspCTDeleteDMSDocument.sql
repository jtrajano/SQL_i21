CREATE PROCEDURE [dbo].[uspCTDeleteDMSDocument]
  @intContractHeader INT,
  @intContractDetailId INT,
  @strFileName NVARCHAR(50)
AS
 
BEGIN
 
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
 
BEGIN TRY
 
 DECLARE @transCount INT;
 DECLARE @voucherBillDetailIds AS Id;
 DECLARE @transactionId NVARCHAR(100);
 
 
 
 SET @transCount = @@TRANCOUNT;
 IF @transCount = 0 BEGIN TRANSACTION
 
 
 SET  @transactionId = ( SELECT  TOP 1 intTransactionId FROM tblSMTransaction WHERE intRecordId = @intContractHeader
 AND intScreenId = (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.Contract') )

 IF @intContractDetailId <> @intContractHeader
 BEGIN 
	 DELETE FROM tblSMDocument where intTransactionId = @transactionId 
	 AND strName LIKE (@strFileName
	 --'%Contract%' + (SELECT strContractNumber+'-'+CAST(B.intContractSeq AS NVARCHAR(50))+'.pdf' from tblCTContractHeader A
	 --INNER JOIN tblCTContractDetail B ON A.intContractHeaderId = B.intContractHeaderId
	 --where B.intContractDetailId = @intContractDetailId  )
	 )
 END

 ELSE
 BEGIN
	DELETE from tblSMDocument where intTransactionId = @transactionId 
	and strName IN (SELECT 'Contract-'+strContractNumber+'.pdf' from tblCTContractHeader where intContractHeaderId = @intContractHeader)
 END
 

 IF @transCount = 0 COMMIT TRANSACTION
 
END TRY
BEGIN CATCH 
 DECLARE @ErrorMerssage NVARCHAR(MAX)
 SELECT @ErrorMerssage = ERROR_MESSAGE()         
 RAISERROR(@ErrorMerssage, 11, 1);
 ROLLBACK TRANSACTION;
 RETURN 0 
END CATCH  
 
RETURN 1                       
                       
END