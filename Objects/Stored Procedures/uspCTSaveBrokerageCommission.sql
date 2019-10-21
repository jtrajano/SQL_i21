CREATE PROCEDURE [dbo].[uspCTSaveBrokerageCommission]
 
 @intBrkgCommnId	INT

AS

BEGIN TRY

    DECLARE @ErrMsg	NVARCHAR(MAX)

    UPDATE  CC
    SET	  CC.strStatus	   =		CASE	WHEN	   BCD.dblReqstdAmount IS NOT NULL AND BCD.dblRcvdPaidAmount IS NOT NULL
												THEN	 'Received/Paid'
											WHEN	   BCD.dblReqstdAmount IS NOT NULL AND BCD.dblRcvdPaidAmount IS NULL
												THEN	 'Requested'
											ELSE	   CC.strStatus
									END

    FROM	  tblCTBrkgCommnDetail	 BCD
    JOIN	  tblCTContractCost		 CC ON CC.intContractCostId	=   BCD.intContractCostId
    WHERE	  BCD.intBrkgCommnId  =	 @intBrkgCommnId
	
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH