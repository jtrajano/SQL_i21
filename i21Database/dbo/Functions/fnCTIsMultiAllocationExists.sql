CREATE FUNCTION [dbo].[fnCTIsMultiAllocationExists]
(
	@intContractDetailId	INT
)
RETURNS BIT
AS 
BEGIN 
	DECLARE	 @ysnMultiAllocation BIT
	
	SELECT	 @ysnMultiAllocation = CASE		WHEN 
											ISNULL	(
														(
															SELECT COUNT(1)
															FROM tblLGAllocationDetail
															WHERE @intContractDetailId IN (intPContractDetailId,intSContractDetailId)
														), 0
													) > 1
											THEN CAST(1 AS BIT)
											ELSE CAST(0 AS BIT)
									END
	
	RETURN	@ysnMultiAllocation
END
GO