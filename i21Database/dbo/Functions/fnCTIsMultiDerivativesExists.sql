CREATE FUNCTION [dbo].[fnCTIsMultiDerivativesExists]
(
	@intContractDetailId	INT
)
RETURNS BIT
AS 
BEGIN 
	DECLARE	 @ysnMultiDerivatives BIT
	
    SELECT	 @ysnMultiDerivatives = CASE 
									WHEN ISNULL(
													(
														SELECT COUNT(1)
														FROM tblRKAssignFuturesToContractSummary SM
														WHERE SM.intContractDetailId = @intContractDetailId
													), 0
												) > 1
										THEN CAST(1 AS BIT)
										ELSE CAST(0 AS BIT)
									END
	
	RETURN	@ysnMultiDerivatives
END
GO

