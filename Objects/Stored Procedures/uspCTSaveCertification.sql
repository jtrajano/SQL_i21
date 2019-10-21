CREATE PROCEDURE [dbo].[uspCTSaveCertification]
	
	@intCertificationId INT
	
AS

BEGIN TRY
	
	DECLARE	@ErrMsg	NVARCHAR(MAX)

	UPDATE CD
	SET CD.strCertifications = STUFF((
	SELECT ', ' + IC.strCertificationName 
	FROM	tblCTContractCertification	CF
	JOIN	tblICCertification			IC	ON	IC.intCertificationId	=	CF.intCertificationId
	WHERE CF.intContractDetailId = x.intContractDetailId
	FOR XML PATH(''), TYPE).value('.[1]', 'nvarchar(max)'), 1, 2, '')
	FROM tblCTContractCertification AS x
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = x.intContractDetailId
	WHERE x.intCertificationId = @intCertificationId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH