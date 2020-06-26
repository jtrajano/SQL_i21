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
    strContainerType    NVARCHAR(200) COLLATE Latin1_General_CI_AS,
    strContainerUOM	    NVARCHAR(100) COLLATE Latin1_General_CI_AS
)

AS
BEGIN
	DECLARE @intCountryId	INT,@ysnLoadContainerTypeByOrigin BIT
	SELECT	@intCountryId	=	intCountryID FROM tblSMCountry WHERE strCountry = @strCountry
	SELECT	@ysnLoadContainerTypeByOrigin	=	ysnLoadContainerTypeByOrigin FROM tblLGCompanyPreference

    IF EXISTS(SELECT TOP 1 1 FROM tblLGContainerType WHERE intContainerTypeId = ISNULL(@intContainerTypeId,0)) AND @intCountryId IS NOT NULL AND ISNULL(@ysnLoadContainerTypeByOrigin,0) = 1
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
	ELSE
	BEGIN
		INSERT INTO @returntable(dblBulkQuantity,dblBagQuantity,strContainerType,strContainerUOM)
		SELECT NULL,NULL,strContainerType,NULL FROM tblLGContainerType WHERE intContainerTypeId	=	@intContainerTypeId 
	END
    RETURN;
END