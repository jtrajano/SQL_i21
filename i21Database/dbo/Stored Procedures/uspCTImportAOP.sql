CREATE PROCEDURE [dbo].[uspCTImportAOP]
@intExternalId		INT,
	@strScreenName		NVARCHAR(50),
	@intUserId		INT,
	@XML				NVARCHAR(MAX)
AS
BEGIN TRY

    DECLARE	 @ErrMsg				NVARCHAR(MAX),
			 @strYear				NVARCHAR(200),
			 @dtmFromDate			DATETIME,
			 @dtmToDate			DATETIME,
			 @strBook				NVARCHAR(200),
			 @strSubBook			NVARCHAR(200),
			 @strCommodity			NVARCHAR(200),
			 @strCompanyLocation	NVARCHAR(200),
			 @strItem				NVARCHAR(200),
			 @dblVolume			NUMERIC(18, 6),
			 @strVolumeUOM			NVARCHAR(200),
			 @strCurrency			NVARCHAR(200),
			 @strWeightUOM			NVARCHAR(200),
			 @strPriceUOM			NVARCHAR(200),
			 @dblComponent1		NUMERIC(18, 6),
			 @dblComponent2		NUMERIC(18, 6),
			 @dblComponent3		NUMERIC(18, 6),
			 @dblComponent4		NUMERIC(18, 6),
			 @dblComponent5		NUMERIC(18, 6),
			 @dblComponent6		NUMERIC(18, 6),
			 @dblComponent7		NUMERIC(18, 6),
			 @dblComponent8		NUMERIC(18, 6),
			 @dblComponent9		NUMERIC(18, 6),
			 @dblComponent10		NUMERIC(18, 6),
			 @intAOPId			INT,
			 @intBookId			INT,
			 @intSubBookId			INT,
			 @intCommodityId		INT,
			 @intCompanyLocationId	INT,
			 @intItemId			INT,
			 @intVolumeUOMId		INT,
			 @intCurrencyId		INT,
			 @intWeightUOMId		INT,
			 @intPriceUOMId		INT

    DECLARE	 @Detail TABLE
    (
	   intItemId	    INT, 
	   dblCost	    NUMERIC(18,6),
	   intAOPDetailId  INT
    )

    UPDATE  B
    SET	  B.intAOPId  =   A.intAOPId
    FROM	  tblCTAOP	   A
    JOIN	  tblCTImportAOP  B   ON  A.strYear	  =	  B.strYear 
						  AND A.dtmFromDate	  =	  B.dtmFromDate
						  AND A.dtmToDate	  =	  B.dtmToDate
    WHERE	ISNULL(ysnImported,0)	=	0

	SELECT	@strYear			 = AO.strYear,
			@dtmFromDate		 = AO.dtmFromDate,
			@dtmToDate		 = AO.dtmToDate,
			@strBook			 = AO.strBook,
			@strSubBook		 = AO.strSubBook,
			@strCommodity		 = AO.strCommodity,
			@strCompanyLocation = AO.strCompanyLocation,
			@strItem			 = AO.strItem,
			@dblVolume		 = AO.dblVolume,
			@strVolumeUOM		 = AO.strVolumeUOM,
			@strCurrency		 = AO.strCurrency,
			@strWeightUOM		 = AO.strWeightUOM,
			@strPriceUOM		 = AO.strPriceUOM,
			@dblComponent1	 = AO.dblComponent1,
			@dblComponent2	 = AO.dblComponent2,
			@dblComponent3	 = AO.dblComponent3,
			@dblComponent4	 = AO.dblComponent4,
			@dblComponent5	 = AO.dblComponent5,
			@dblComponent6	 = AO.dblComponent6,
			@dblComponent7	 = AO.dblComponent7,
			@dblComponent8	 = AO.dblComponent8,
			@dblComponent9	 = AO.dblComponent9,
			@dblComponent10	 = AO.dblComponent10,

			@intBookId		 = BK.intBookId,
			@intSubBookId		 = SB.intSubBookId,
			@intCommodityId	 = CO.intCommodityId,
			@intCompanyLocationId=CL.intCompanyLocationId,
			@intItemId		 = IM.intItemId,
			@intVolumeUOMId	 = VM.intItemUOMId,
			@intCurrencyId	 = CY.intCurrencyID,
			@intWeightUOMId	 = WM.intItemUOMId,
			@intPriceUOMId	 = PM.intItemUOMId,

			@intAOPId		 =	intAOPId

	FROM		 tblCTImportAOP			AO
	LEFT JOIN	 tblICCommodity			CO  ON  CO.strCommodityCode =		AO.strCommodity
	LEFT JOIN	 tblSMCompanyLocation	CL  ON  CL.strLocationName  =		AO.strCompanyLocation
	LEFT JOIN	 tblICItem				IM  ON  IM.strItemNo		=		AO.strItem
	LEFT JOIN	 tblICUnitMeasure		VU  ON  VU.strUnitMeasure   =		AO.strVolumeUOM
	LEFT JOIN	 tblICItemUOM			VM  ON  VM.intItemId		=		IM.intItemId
											AND VM.intUnitMeasureId =		VU.intUnitMeasureId
	LEFT JOIN	 tblICUnitMeasure		WU  ON  WU.strUnitMeasure   =		AO.strWeightUOM
	LEFT JOIN	 tblICItemUOM			WM  ON  WM.intItemId		=		IM.intItemId
											AND WM.intUnitMeasureId =		WU.intUnitMeasureId
	LEFT JOIN	 tblICUnitMeasure		PU  ON  PU.strUnitMeasure   =		AO.strPriceUOM
	LEFT JOIN	 tblICItemUOM			PM  ON  PM.intItemId		=		IM.intItemId
											AND PM.intUnitMeasureId =		PU.intUnitMeasureId
	LEFT JOIN	 tblSMCurrency			CY  ON  CY.strCurrency		=		AO.strCurrency
	LEFT JOIN	 tblCTBook				BK  ON  BK.strBook			=		AO.strBook
	LEFT JOIN	 tblCTSubBook			SB  ON  SB.strSubBook		=		AO.strSubBook
											AND SB.intBookId		=		BK.intBookId
	WHERE		 intImportAOPId	 = @intExternalId

    INSERT INTO @Detail
    SELECT M.intItemId, Cost AS dblCost,D.intAOPDetailId
    FROM tblCTImportAOP 
    UNPIVOT 
    (
		  Cost FOR strComponent  IN 
		  (
			 dblComponent1,dblComponent2,dblComponent3,dblComponent4,dblComponent5,dblComponent6,dblComponent7,dblComponent8,dblComponent9
		  )
    ) unpvt
    JOIN tblCTComponentMap M ON M.strComponent = REPLACE(unpvt.strComponent,'dbl','') COLLATE Latin1_General_CI_AS
    LEFT JOIN tblCTAOPDetail D ON D.intBasisItemId = M.intItemId AND D.intAOPId = ISNULL(unpvt.intAOPId,0) AND D.intItemId = @intItemId
    WHERE intImportAOPId	 = @intExternalId

    IF @intAOPId IS NULL
    BEGIN
	   IF @strYear IS NULL
	   BEGIN
		  SET @ErrMsg = 'Year is missing.'
		  RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')    
	   END
	   IF @dblVolume IS NULL
	   BEGIN
		  SET @ErrMsg = 'Volume is missing.'
		  RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')    
	   END
	   IF @strVolumeUOM IS NULL
	   BEGIN
		  SET @ErrMsg = 'Volume UOM is missing.'
		  RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')    
	   END
	   IF @strCurrency IS NULL
	   BEGIN
		  SET @ErrMsg = 'Currency is missing.'
		  RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')    
	   END
	   IF @strWeightUOM IS NULL
	   BEGIN
		  SET @ErrMsg = 'Weight UOM is missing.'
		  RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')    
	   END
	   IF @strItem IS NULL
	   BEGIN
		  SET @ErrMsg = 'Item is missing.'
		  RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')    
	   END


	   INSERT INTO tblCTAOP(strYear,dtmFromDate,dtmToDate,intBookId,intSubBookId,intConcurrencyId)
	   SELECT @strYear,@dtmFromDate,@dtmToDate,@intBookId,@intSubBookId,1

	   SELECT @intAOPId = SCOPE_IDENTITY()

	   INSERT INTO tblCTAOPDetail(intAOPId,intCommodityId,intCompanyLocationId,intItemId,dblVolume,intVolumeUOMId,intCurrencyId,intWeightUOMId,intPriceUOMId,intConcurrencyId,intBasisItemId,dblCost)
	   SELECT @intAOPId,@intCommodityId,@intCompanyLocationId,@intItemId,@dblVolume,@intVolumeUOMId,@intCurrencyId,@intWeightUOMId,@intPriceUOMId,1,M.intItemId, M.dblCost
	   FROM @Detail M
	   WHERE intAOPDetailId	 IS NULL
    END
    ELSE
    BEGIN
	   UPDATE AD
	   SET AD.dblCost = D.dblCost
	   FROM @Detail D
	   JOIN tblCTAOPDetail AD ON AD.intAOPDetailId = D.intAOPDetailId
	   WHERE D.intAOPDetailId IS NOT NULL

	   INSERT INTO tblCTAOPDetail(intAOPId,intCommodityId,intCompanyLocationId,intItemId,dblVolume,intVolumeUOMId,intCurrencyId,intWeightUOMId,intPriceUOMId,intConcurrencyId,intBasisItemId,dblCost)
	   SELECT @intAOPId,@intCommodityId,@intCompanyLocationId,@intItemId,@dblVolume,@intVolumeUOMId,@intCurrencyId,@intWeightUOMId,@intPriceUOMId,1,M.intItemId, M.dblCost
	   FROM @Detail M
	   WHERE intAOPDetailId	 IS NULL
    END
    SELECT * FROM @Detail
END TRY      
BEGIN CATCH       
	SET @ErrMsg = ERROR_MESSAGE()      
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH
