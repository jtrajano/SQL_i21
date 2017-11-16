CREATE PROCEDURE [dbo].[uspCTGetUnsavedAOPDetail]
	@intItemId INT,
	@strYear NVARCHAR(50)

AS

BEGIN TRY

	DECLARE @ErrMsg	NVARCHAR(MAX)

	SELECT	CAST(ROW_NUMBER() OVER (ORDER BY IM.intItemId,BI.intItemId) AS INT) AS intUniqueId,
			IM.intCommodityId,
			IM.intItemId,
			BI.intItemId AS intBasisItemId,
			(SELECT TOP 1 dblVolume FROM vyuCTAOP WHERE intItemId = IM.intItemId AND strYear = @strYear) AS dblVolume,
			(SELECT TOP 1 intVolumeUOMId FROM vyuCTAOP WHERE intItemId = IM.intItemId AND strYear = @strYear) AS intVolumeUOMId,
			(SELECT TOP 1 intCurrencyId  FROM vyuCTAOP WHERE intItemId = IM.intItemId AND strYear = @strYear) AS intCurrencyId,
			(SELECT TOP 1 intWeightUOMId FROM vyuCTAOP WHERE intItemId = IM.intItemId AND strYear = @strYear) AS intWeightUOMId,
			--(SELECT TOP 1 intPriceUOMId  FROM vyuCTAOP WHERE intItemId = IM.intItemId AND strYear = @strYear) AS intPriceUOMId,
			BI.strItemNo AS strBasisItemNo,
			CO.strCommodityCode,
			IM.strItemNo

	FROM	tblICItem			IM 
	JOIN	tblICCommodity		CO	ON	CO.intCommodityId = IM.intCommodityId CROSS 
	JOIN	(
				SELECT	intItemId,strItemNo 
				FROM	tblICItem			
				WHERE	ysnBasisContract = 1
			) BI	
	WHERE	BI.intItemId NOT IN (SELECT ISNULL(intBasisItemId,0) FROM vyuCTAOP WHERE intItemId = @intItemId AND strYear = @strYear) AND IM.intItemId = @intItemId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
