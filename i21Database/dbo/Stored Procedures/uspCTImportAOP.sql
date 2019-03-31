﻿CREATE PROCEDURE [dbo].[uspCTImportAOP]
	@intExternalId		INT,
	@strScreenName		NVARCHAR(50),
	@intUserId		INT,
	@XML				NVARCHAR(MAX)
AS
BEGIN TRY

    DECLARE	 @ErrMsg				NVARCHAR(MAX),
			 @strYear				NVARCHAR(200),
			 @dtmFromDate			DATETIME,
			 @dtmToDate				DATETIME,
			 @strBook				NVARCHAR(200),
			 @strSubBook			NVARCHAR(200),
			 @strCommodity			NVARCHAR(200),
			 @strCompanyLocation	NVARCHAR(200),
			 @strItem				NVARCHAR(200),
			 @dblVolume				NUMERIC(18, 6),
			 @strVolumeUOM			NVARCHAR(200),
			 @strCurrency			NVARCHAR(200),
			 @strWeightUOM			NVARCHAR(200),
			 @strPriceUOM			NVARCHAR(200),
			 @dblComponent1			NUMERIC(18, 6),
			 @dblComponent2			NUMERIC(18, 6),
			 @dblComponent3			NUMERIC(18, 6),
			 @dblComponent4			NUMERIC(18, 6),
			 @dblComponent5			NUMERIC(18, 6),
			 @dblComponent6			NUMERIC(18, 6),
			 @dblComponent7			NUMERIC(18, 6),
			 @dblComponent8			NUMERIC(18, 6),
			 @dblComponent9			NUMERIC(18, 6),
			 @dblComponent10		NUMERIC(18, 6),
			 @intAOPId				INT,
			 @intBookId				INT,
			 @intSubBookId			INT,
			 @intCommodityId		INT,
			 @intCompanyLocationId	INT,
			 @intStorageLocationId	INT,
			 @intItemId				INT,
			 @intVolumeUOMId		INT,
			 @intCurrencyId			INT,
			 @intWeightUOMId		INT,
			 @intPriceUOMId			INT,
			 @intAOPDetailId		INT

	DECLARE	 @Component TABLE
	(
		intItemId			INT, 
		dblCost				NUMERIC(18,6),
		intAOPComponentId	INT
	)

    UPDATE  B
    SET		B.intAOPId  =   A.intAOPId
    FROM	tblCTAOP				A
	JOIN	tblICCommodity			C	ON	C.intCommodityId		=	A.intCommodityId
	JOIN	tblSMCompanyLocation	L	ON  L.intCompanyLocationId  =	A.intCompanyLocationId
    JOIN	tblCTImportAOP			B   ON  A.strYear				=	B.strYear 
										AND A.dtmFromDate			=	B.dtmFromDate
										AND A.dtmToDate				=	B.dtmToDate
										
    WHERE	ISNULL(ysnImported,0)	=	0
	AND		B.strCommodity			=	C.strCommodityCode
	AND		B.strCompanyLocation	=	L.strLocationName	

	UPDATE	B 
	SET		B.dblComponent1 = ISNULL(dblComponent1,0),
			B.dblComponent2 = ISNULL(B.dblComponent2,0),
			B.dblComponent3 = ISNULL(B.dblComponent3,0),
			B.dblComponent4 = ISNULL(B.dblComponent4,0),
			B.dblComponent5 = ISNULL(B.dblComponent5,0),
			B.dblComponent6 = ISNULL(B.dblComponent6,0),
			B.dblComponent7 = ISNULL(B.dblComponent7,0),
			B.dblComponent8 = ISNULL(B.dblComponent8,0),
			B.dblComponent9 = ISNULL(B.dblComponent9,0),
			B.dblComponent10 = ISNULL(B.dblComponent10,0)
	FROM	tblCTImportAOP B
	WHERE   intImportAOPId  = @intExternalId

	SELECT	@strYear			=	AO.strYear,
			@dtmFromDate		=	AO.dtmFromDate,
			@dtmToDate			=	AO.dtmToDate,
			@strBook			=	AO.strBook,
			@strSubBook			=	AO.strSubBook,
			@strCommodity		=	AO.strCommodity,
			@strCompanyLocation =	AO.strCompanyLocation,
			@strItem			=	AO.strItem,
			@dblVolume			=	AO.dblVolume,
			@strVolumeUOM		=	AO.strVolumeUOM,
			@strCurrency		=	AO.strCurrency,
			@strWeightUOM		=	AO.strWeightUOM,
			@strPriceUOM		=	AO.strPriceUOM,
			@dblComponent1		=	AO.dblComponent1,
			@dblComponent2		=	AO.dblComponent2,
			@dblComponent3		=	AO.dblComponent3,
			@dblComponent4		=	AO.dblComponent4,
			@dblComponent5		=	AO.dblComponent5,
			@dblComponent6		=	AO.dblComponent6,
			@dblComponent7		=	AO.dblComponent7,
			@dblComponent8		=	AO.dblComponent8,
			@dblComponent9		=	AO.dblComponent9,
			@dblComponent10		=	AO.dblComponent10,

			@intBookId			=	BK.intBookId,
			@intSubBookId		=	SB.intSubBookId,
			@intCommodityId		=	CO.intCommodityId,
			@intCompanyLocationId=	CL.intCompanyLocationId,
			@intItemId			=	IM.intItemId,
			@intVolumeUOMId		=	VM.intItemUOMId,
			@intCurrencyId		=	CY.intCurrencyID,
			@intWeightUOMId		=	WM.intItemUOMId,
			@intPriceUOMId		=	PM.intItemUOMId,
			@intStorageLocationId=	SL.intCompanyLocationSubLocationId,

			@intAOPId			=	intAOPId

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
	LEFT JOIN	 tblSMCompanyLocationSubLocation	SL	ON	SL.strSubLocationName = AO.strStorageLocation
	WHERE		 intImportAOPId	 = @intExternalId

    INSERT INTO @Component
    SELECT M.intItemId, Cost AS dblCost,C.intAOPComponentId
    FROM tblCTImportAOP 
    UNPIVOT 
    (
		  Cost FOR strComponent  IN 
		  (
			 dblComponent1,dblComponent2,dblComponent3,dblComponent4,dblComponent5,dblComponent6,dblComponent7,dblComponent8,dblComponent9
		  )
    ) unpvt
    JOIN tblCTComponentMap		M	ON	M.strComponent		=	REPLACE(unpvt.strComponent,'dbl','') COLLATE Latin1_General_CI_AS
    LEFT JOIN tblCTAOPDetail	D	ON	D.intAOPId			=	ISNULL(unpvt.intAOPId,0) 
									AND D.intItemId			=	@intItemId 
									AND ISNULL(D.intStorageLocationId,0) = @intStorageLocationId
	LEFT JOIN tblCTAOPComponent C	ON	C.intBasisItemId	=	M.intItemId 
									AND C.intAOPDetailId	=	D.intAOPDetailId
    WHERE	intImportAOPId = @intExternalId 
	AND		M.intItemId IS NOT NULL

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
	IF @strPriceUOM IS NULL OR @intPriceUOMId IS NULL
	BEGIN
		SET @ErrMsg = 'Price UOM is missing.'
		RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')    
	END
	IF @strItem IS NULL OR @intItemId IS NULL
	BEGIN
		SET @ErrMsg = 'Item is missing from csv or in i21.'
		RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')    
	END
	IF @strCompanyLocation IS NULL OR @intCompanyLocationId IS NULL
	BEGIN
		SET @ErrMsg = 'Location is missing from csv or in i21.'
		RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')    
	END
	IF @strCommodity IS NULL OR @intCommodityId IS NULL
	BEGIN
		SET @ErrMsg = 'Commodity is missing from csv or in i21.'
		RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')    
	END

    IF @intAOPId IS NULL
    BEGIN

	   INSERT INTO tblCTAOP(strYear,dtmFromDate,dtmToDate,intBookId,intSubBookId,intConcurrencyId,intCommodityId,intCompanyLocationId)
	   SELECT @strYear,@dtmFromDate,@dtmToDate,@intBookId,@intSubBookId,1,@intCommodityId,@intCompanyLocationId

	   SELECT @intAOPId = SCOPE_IDENTITY()

	   IF EXISTS(SELECT TOP 1 1 FROM tblCTAOPDetail WHERE intAOPId = @intAOPId AND intItemId = @intItemId AND ISNULL(intStorageLocationId,0) = ISNULL(@intStorageLocationId,0))
	   BEGIN
			SET @ErrMsg = 'Storage location is already available.'
			RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')    
	   END

	   INSERT INTO tblCTAOPDetail(intAOPId,intItemId,dblVolume,intVolumeUOMId,intCurrencyId,intWeightUOMId,intPriceUOMId,intConcurrencyId,intStorageLocationId)
	   SELECT @intAOPId,@intItemId,@dblVolume,@intVolumeUOMId,@intCurrencyId,@intWeightUOMId,@intPriceUOMId,1, @intStorageLocationId

	   SELECT @intAOPDetailId = SCOPE_IDENTITY()

	   INSERT INTO tblCTAOPComponent(intAOPDetailId, intBasisItemId, dblCost, intConcurrencyId)
	   SELECT @intAOPDetailId,M.intItemId, M.dblCost, 1
	   FROM @Component M
	   WHERE intAOPComponentId	 IS NULL
    END
    ELSE
    BEGIN
	   UPDATE AD
	   SET AD.dblCost = D.dblCost
	   FROM @Component D
	   JOIN tblCTAOPComponent AD ON AD.intAOPComponentId = D.intAOPComponentId
	   WHERE D.intAOPComponentId IS NOT NULL

	   SELECT @intAOPDetailId = intAOPDetailId FROM tblCTAOPDetail WHERE intAOPId = @intAOPId AND intItemId = @intItemId AND ISNULL(intStorageLocationId,0) = ISNULL(@intStorageLocationId,0)

	   IF @intAOPDetailId IS NULL
	   BEGIN
			INSERT INTO tblCTAOPDetail(intAOPId,intItemId,dblVolume,intVolumeUOMId,intCurrencyId,intWeightUOMId,intPriceUOMId,intConcurrencyId,intStorageLocationId)
			SELECT @intAOPId,@intItemId,@dblVolume,@intVolumeUOMId,@intCurrencyId,@intWeightUOMId,@intPriceUOMId,1, @intStorageLocationId

			SELECT @intAOPDetailId = SCOPE_IDENTITY()
	   END

	   INSERT INTO tblCTAOPComponent(intAOPDetailId, intBasisItemId, dblCost, intConcurrencyId)
	   SELECT @intAOPDetailId,M.intItemId, M.dblCost, 1
	   FROM @Component M
	   WHERE intAOPComponentId	 IS NULL
    END
    SELECT * FROM @Component
END TRY      
BEGIN CATCH       
	SET @ErrMsg = ERROR_MESSAGE()      
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH
