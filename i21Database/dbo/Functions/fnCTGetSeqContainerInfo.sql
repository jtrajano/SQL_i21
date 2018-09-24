CREATE FUNCTION [dbo].[fnCTGetSeqContainerInfo]
(
	@intCommodityId		INT,
	@intContainerTypeId	INT,
	@strCountry			NVARCHAR(50)
)

RETURNS	@returntable	TABLE
(
    dblBulkQuantity	    NUMERIC(18,6),
    dblBagQuantity	    NUMERIC(18,6),
    strContainerType    NVARCHAR(200),
    strContainerUOM	    NVARCHAR(100)
)

AS
BEGIN
	DECLARE @intCountryId	INT
	SELECT	@intCountryId	=	intCountryID FROM tblSMCountry WHERE strCountry = @strCountry

    IF EXISTS(SELECT TOP 1 1 FROM tblLGContainerType WHERE intContainerTypeId = ISNULL(@intContainerTypeId,0)) AND @intCountryId IS NOT NULL
    BEGIN
	   INSERT INTO @returntable(dblBulkQuantity,dblBagQuantity,strContainerType,strContainerUOM)	
	   SELECT 	dblBulkQuantity,dblBagQuantity,strContainerType,RM.strUnitMeasure
	   FROM 
	   (
			SELECT	CQ.intContainerTypeId,
					CQ.intCommodityAttributeId,
					CQ.intUnitMeasureId,
					CQ.dblBulkQuantity ,
					CQ.dblQuantity AS dblBagQuantity,
					CQ.intCommodityId,
					CA.intCountryID AS intCountryId,
					CT.strContainerType

			FROM		tblLGContainerTypeCommodityQty	CQ	
			JOIN		tblLGContainerType				CT	ON	CT.intContainerTypeId		=	CQ.intContainerTypeId
			JOIN		tblICCommodityAttribute			CA	ON	CQ.intCommodityAttributeId	=	CA.intCommodityAttributeId
	    )CQ	
	    JOIN	tblICUnitMeasure	RM	ON	RM.intUnitMeasureId		=	CQ.intUnitMeasureId	
	    WHERE	CQ.intCommodityId			=	@intCommodityId 
	    AND		CQ.intContainerTypeId		=	@intContainerTypeId 
	    AND		CQ.intCountryId				=	@intCountryId
    END

    RETURN;
END