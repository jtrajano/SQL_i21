CREATE PROCEDURE [dbo].[uspCTBeforeSaveBrokerageCommission]
		
	@intBrkgCommnId	INT,
	@intUserId		INT,
	@strXML			NVARCHAR(MAX)
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg	NVARCHAR(MAX)

	IF @strXML = 'Delete'
	BEGIN

	   UPDATE CC
	   SET CC.strStatus = NULL
	   FROM tblCTBrkgCommnDetail BD
	   JOIN	 tblCTContractCost CC ON BD.intContractCostId = CC.intContractCostId
	   WHERE BD.intBrkgCommnId = @intBrkgCommnId

	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH