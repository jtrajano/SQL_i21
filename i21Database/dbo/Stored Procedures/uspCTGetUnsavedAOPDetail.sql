CREATE PROCEDURE [dbo].[uspCTGetUnsavedAOPDetail]
	@intItemId INT,
	@intCompanyLocationId INT,
	@strYear NVARCHAR(50)

AS

BEGIN TRY

	DECLARE @ErrMsg	NVARCHAR(MAX)

	SELECT	BI.intItemId AS intBasisItemId,
			BI.strItemNo AS strBasisItemNo,
			intUniqueId = BI.intItemId

	FROM	tblICItem			BI 	
	WHERE	ysnBasisContract = 1

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
