﻿CREATE FUNCTION [dbo].[fnCTGetFreightRateMatrixFromCommodity]
(
	@intLoadingPortId AS NVARCHAR(100)
	,@intDestinationPortId AS  NVARCHAR(100)
	,@intCommodityId AS INT
	,@strOrigin AS NVARCHAR(100)
)
RETURNS NUMERIC(18 , 6)
AS 
BEGIN
	DECLARE 
		@dblRate NUMERIC(18, 6),
		--@intLoadingPortId INT = NULL,
		--@intDestinationPortId INT = NULL,
		@intFreightRateMatrixId INT = NULL
	
	--SELECT @intLoadingPortId = intCityId from tblSMCity where strCity = @strLoadingPortId
	--SELECT @intDestinationPortId = intCityId from tblSMCity where strCity = @strDestinationPortId
	SELECT  TOP 1 @intFreightRateMatrixId = FRM.intFreightRateMatrixId
            FROM tblLGFreightRateMatrix FRM
            JOIN tblSMCity LP ON LP.strCity = FRM.strOriginPort
            JOIN tblSMCity DP ON DP.strCity = FRM.strDestinationCity
			WHERE LP.intCityId = @intLoadingPortId
                AND DP.intCityId = @intDestinationPortId
                AND GETDATE() >= FRM.dtmValidFrom
                AND GETDATE() <= FRM.dtmValidTo
                AND ISNULL(FRM.ysnOffer, 0) = 1
	
	SELECT TOP 1  @dblRate = CASE WHEN ISNULL(ctq.dblWeight, 0) = 0 THEN 0 ELSE (frm.dblTotalCostPerContainer / ctq.dblWeight) END
                FROM tblLGFreightRateMatrix frm
                JOIN tblLGContainerType cnt ON cnt.intContainerTypeId = frm.intContainerTypeId
                JOIN tblLGContainerTypeCommodityQty ctq ON ctq.intContainerTypeId = cnt.intContainerTypeId
				INNER JOIN vyuLGContainerTypeNotMapped LGC ON LGC.intContainerTypeId = cnt.intContainerTypeId and ctq.intCommodityAttributeId = LGC.intCommodityAttributeId
                WHERE ctq.intCommodityId = @intCommodityId             
                     AND frm.intFreightRateMatrixId = @intFreightRateMatrixId
					 AND LGC.strOrigin = @strOrigin

	RETURN CASE WHEN ISNULL(@dblRate, 0) > 0 THEN @dblRate ELSE 0.00 END
END