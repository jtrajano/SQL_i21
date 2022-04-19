CREATE PROCEDURE [dbo].[uspSTUpdateShiftPhysical]
	  @intCheckoutId INT
	, @dtmCheckoutDate DATETIME
	, @intEntityUserSecurityId INT
	, @intCompanyLocationId INT
	, @strStatusMsg NVARCHAR(1000) OUTPUT
AS

BEGIN TRY
SET @strStatusMsg = 'Success'

DELETE FROM tblSTCheckoutShiftPhysicalPreview
WHERE intCheckoutId = @intCheckoutId

DECLARE @tmpTblShiftPhysicalCountGroup TABLE (
		intCheckoutId INT NULL,
		intItemId INT NULL,
		intCountGroupId INT NULL,
		intItemLocationId INT NULL,
		dblSystemCount NUMERIC(20, 2) NULL,
		dblQtyReceived NUMERIC(20, 2) NULL,
		dblQtySold NUMERIC(20, 2) NULL,
		intItemUOMId INT NULL,
		intEntityUserSecurityId INT NULL,
		intConcurrencyId INT NULL
)

DECLARE @tmpTblShiftPhysicalItem TABLE (
		intCheckoutId INT NULL,
		intItemId INT NULL,
		intCountGroupId INT NULL,
		intItemLocationId INT NULL,
		dblSystemCount NUMERIC(20, 2) NULL,
		dblQtyReceived NUMERIC(20, 2) NULL,
		dblQtySold NUMERIC(20, 2) NULL,
		intItemUOMId INT NULL,
		intEntityUserSecurityId INT NULL,
		intConcurrencyId INT NULL
)

--COUNT GROUP
INSERT INTO @tmpTblShiftPhysicalCountGroup(
	intCheckoutId
	, intCountGroupId
	, dblSystemCount
	, dblQtyReceived
	, dblQtySold
	, intEntityUserSecurityId
	, intConcurrencyId)
SELECT 
	intCheckoutId = @intCheckoutId
	, CG.intCountGroupId
	, dblSystemCount = ISNULL(SUM(shiftPhysical.dblPhysicalCount), 0)
	, ISNULL(SUM(InventoryReceipt.dblQtyReceived), 0) AS dblQtyReceived
	, ISNULL(SUM(ItemMovement.dblQtySold), 0) AS dblQtySold
	, intEntityUserSecurityId = @intEntityUserSecurityId
	, intConcurrencyId = 1
FROM tblICCountGroup CG
JOIN (SELECT DISTINCT intCountGroupId 
			FROM tblICItemLocation IL
			WHERE IL.intLocationId = @intCompanyLocationId OR ISNULL(@intCompanyLocationId, 0) = 0) IL
	ON CG.intCountGroupId = IL.intCountGroupId
LEFT JOIN 
(
	SELECT * FROM (
		SELECT 
				SP.intCountGroupId,
				dblPhysicalCount,
				ROW_NUMBER() OVER (PARTITION BY SP.intCountGroupId ORDER BY CH.intCheckoutId DESC) AS intRowNum
		FROM tblSTCheckoutShiftPhysical SP
		JOIN tblSTCheckoutHeader CH
			ON SP.intCheckoutId = CH.intCheckoutId
		JOIN tblSTStore ST
			ON CH.intStoreId = ST.intStoreId
		WHERE dblPhysicalCount != 0 AND ISNULL(SP.intCountGroupId, 0) != 0 
			AND ST.intCompanyLocationId = @intCompanyLocationId
			AND CH.dtmCheckoutDate < @dtmCheckoutDate
	) AS tblShiftPhysical WHERE intRowNum = 1
) AS shiftPhysical
	ON IL.intCountGroupId = shiftPhysical.intCountGroupId
LEFT JOIN 
(
	SELECT 
		IR.intLocationId,
		IR.dtmReceiptDate,
		IL.intCountGroupId,
		SUM(IRI.dblOpenReceive) AS dblQtyReceived
	FROM tblICInventoryReceipt IR
	JOIN tblICInventoryReceiptItem IRI
		ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
	JOIN tblICItemLocation IL
		ON IL.intItemId = IRI.intItemId AND IL.intLocationId = IR.intLocationId
	WHERE ISNULL(IL.intCountGroupId, 0) != 0
	GROUP BY 
		IR.intLocationId,
		IR.dtmReceiptDate,
		IL.intCountGroupId
) AS InventoryReceipt
	ON IL.intCountGroupId = InventoryReceipt.intCountGroupId
	AND @dtmCheckoutDate = InventoryReceipt.dtmReceiptDate
	AND @intCompanyLocationId = InventoryReceipt.intLocationId
LEFT JOIN 
(
	SELECT 
		IL.intLocationId,
		CH.dtmCheckoutDate,
		IL.intCountGroupId,
		SUM(IM.intQtySold) AS dblQtySold
	FROM tblSTCheckoutItemMovements IM
	JOIN tblICItemUOM UOM
		ON IM.intItemUPCId = UOM.intItemUOMId
	JOIN tblSTCheckoutHeader CH
		ON IM.intCheckoutId = CH.intCheckoutId
	JOIN tblSTStore ST
		ON CH.intStoreId = ST.intStoreId
	JOIN tblICItemLocation IL
		ON ST.intCompanyLocationId = IL.intLocationId AND UOM.intItemId = IL.intItemId
	WHERE ISNULL(IL.intCountGroupId, 0) != 0
	GROUP BY 
		IL.intLocationId,
		CH.dtmCheckoutDate,
		IL.intCountGroupId
) AS ItemMovement
	ON IL.intCountGroupId = ItemMovement.intCountGroupId
	AND @dtmCheckoutDate = ItemMovement.dtmCheckoutDate
	AND @intCompanyLocationId = ItemMovement.intLocationId
WHERE IL.intCountGroupId IS NOT NULL
GROUP BY
	CG.intCountGroupId


--NORMAL ITEMS
INSERT INTO @tmpTblShiftPhysicalItem(
	intCheckoutId
	, intItemId
	, intItemLocationId
	, dblSystemCount
	, dblQtyReceived
	, dblQtySold
	, intItemUOMId
	, intEntityUserSecurityId
	, intConcurrencyId)
SELECT 
	intCheckoutId = @intCheckoutId
	, I.intItemId
	, IL.intItemLocationId
	, dblSystemCount = ISNULL(shiftPhysical.dblPhysicalCount, 0)
	, InventoryReceipt.dblQtyReceived
	, ItemMovement.dblQtySold
	, UOM.intItemUOMId
	, intEntityUserSecurityId = @intEntityUserSecurityId
	, intConcurrencyId = 1
FROM tblICItem I
JOIN tblICItemUOM UOM
	ON I.intItemId = UOM.intItemId
JOIN tblICItemLocation IL
	ON I.intItemId = IL.intItemId
LEFT JOIN 
(
	SELECT * FROM (
		SELECT 
				intItemId,
				intItemLocationId,
				intItemUOMId,
				dblPhysicalCount,
				ROW_NUMBER() OVER (PARTITION BY intItemId, intItemLocationId, intItemUOMId ORDER BY CH.intCheckoutId DESC) AS intRowNum
		FROM tblSTCheckoutShiftPhysical SP
		JOIN tblSTCheckoutHeader CH
			ON SP.intCheckoutId = CH.intCheckoutId
		WHERE dblPhysicalCount != 0
			AND CH.dtmCheckoutDate < @dtmCheckoutDate
	) AS tblShiftPhysical WHERE intRowNum = 1
) AS shiftPhysical
	ON I.intItemId = shiftPhysical.intItemId
	AND IL.intItemLocationId = shiftPhysical.intItemLocationId
	AND UOM.intItemUOMId = shiftPhysical.intItemUOMId
LEFT JOIN 
(
	SELECT 
		IR.intLocationId,
		IR.dtmReceiptDate,
		IRI.intItemId,
		IRI.intUnitMeasureId,
		SUM(IRI.dblOpenReceive) AS dblQtyReceived
	FROM tblICInventoryReceipt IR
	JOIN tblICInventoryReceiptItem IRI
		ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
	JOIN tblICItemLocation IL
		ON IL.intItemId = IRI.intItemId AND IL.intLocationId = IR.intLocationId
	WHERE ISNULL(IL.intCountGroupId, 0) = 0 AND IL.ysnCountedDaily = 1
	GROUP BY 
		IR.intLocationId,
		dtmReceiptDate,
		IRI.intItemId,
		intUnitMeasureId
) AS InventoryReceipt
	ON I.intItemId = InventoryReceipt.intItemId
	AND IL.intLocationId = InventoryReceipt.intLocationId
	AND @dtmCheckoutDate = InventoryReceipt.dtmReceiptDate
	AND UOM.intItemUOMId = InventoryReceipt.intUnitMeasureId
LEFT JOIN 
(
	SELECT 
		IL.intLocationId,
		CH.dtmCheckoutDate,
		UOM.intItemId,
		UOM.intUnitMeasureId,
		SUM(IM.intQtySold) AS dblQtySold
	FROM tblSTCheckoutItemMovements IM
	JOIN tblICItemUOM UOM
		ON IM.intItemUPCId = UOM.intItemUOMId
	JOIN tblSTCheckoutHeader CH
		ON IM.intCheckoutId = CH.intCheckoutId
	JOIN tblSTStore ST
		ON CH.intStoreId = ST.intStoreId
	JOIN tblICItemLocation IL
		ON ST.intCompanyLocationId = IL.intLocationId AND UOM.intItemId = IL.intItemId
	WHERE ISNULL(IL.intCountGroupId, 0) = 0 AND IL.ysnCountedDaily = 1
	GROUP BY 
		IL.intLocationId,
		CH.dtmCheckoutDate,
		UOM.intItemId,
		UOM.intUnitMeasureId
) AS ItemMovement
	ON I.intItemId = ItemMovement.intItemId
	AND IL.intLocationId = ItemMovement.intLocationId
	AND @dtmCheckoutDate = ItemMovement.dtmCheckoutDate
	AND UOM.intUnitMeasureId = ItemMovement.intUnitMeasureId
WHERE IL.ysnCountedDaily = 1 AND ISNULL(IL.intCountGroupId, 0) = 0
AND (IL.intLocationId = @intCompanyLocationId OR ISNULL(@intCompanyLocationId, 0) = 0)



--COUNT GROUP MERGE TO HANDLE IF SHIFT PHYSICAL IS EXISTING
MERGE	
INTO	dbo.tblSTCheckoutShiftPhysicalPreview
WITH	(HOLDLOCK) 
AS		e
USING (
	SELECT SPP.*,
		PI.intCheckoutId			AS 	 intCheckoutIdNew,		
		PI.intItemId				AS 	 intItemIdNew,	
		PI.intCountGroupId			AS 	 intCountGroupIdNew,		
		PI.intItemLocationId		AS 	 intItemLocationIdNew,		
		PI.dblSystemCount			AS 	 dblSystemCountNew,			
		PI.dblQtyReceived			AS 	 dblQtyReceivedNew,			
		PI.dblQtySold				AS 	 dblQtySoldNew,				
		PI.intItemUOMId				AS 	 intItemUOMIdNew,				
		PI.intEntityUserSecurityId	AS 	 intEntityUserSecurityIdNew,
		PI.intConcurrencyId			AS	 intConcurrencyIdNew
	FROM @tmpTblShiftPhysicalCountGroup PI
	LEFT JOIN tblSTCheckoutShiftPhysicalPreview SPP
		ON SPP.intCheckoutId = PI.intCheckoutId
		AND SPP.intCountGroupId = PI.intCountGroupId
) AS u
	ON e.intCheckoutShiftPhysicalPreviewId = u.intCheckoutShiftPhysicalPreviewId

-- If matched, update the effective cost.
WHEN MATCHED THEN 
	UPDATE 
	SET 
		--e.dblSystemCount = u.dblSystemCount
		e.dblQtyReceived = u.dblQtyReceived
		,e.dblQtySold = u.dblQtySold
		,e.dtmCheckoutDate = @dtmCheckoutDate


------------- Merging of Default values to preview table -------------	 	
-- If none found, insert a new Effective Item Cost
WHEN NOT MATCHED THEN 
	INSERT (
		intCheckoutId
		, intItemId
		, intCountGroupId
		, intItemLocationId
		, dblSystemCount
		, dblQtyReceived
		, dblQtySold
		, intItemUOMId
		, intEntityUserSecurityId
		, dtmCheckoutDate
		, intLocationId
		, intConcurrencyId
	)
	VALUES (
		u.intCheckoutIdNew,
		u.intItemIdNew,
		u.intCountGroupIdNew,
		u.intItemLocationIdNew,
		u.dblSystemCountNew,
		ISNULL(u.dblQtyReceivedNew, 0),
		ISNULL(u.dblQtySoldNew, 0),
		u.intItemUOMIdNew,
		u.intEntityUserSecurityIdNew,
		@dtmCheckoutDate,
		@intCompanyLocationId,
		u.intConcurrencyIdNew
	);


--NORMAL ITEMS MERGE TO HANDLE IF SHIFT PHYSICAL IS EXISTING
MERGE	
INTO	dbo.tblSTCheckoutShiftPhysicalPreview
WITH	(HOLDLOCK) 
AS		e
USING (
	SELECT SPP.*,
		PI.intCheckoutId			AS 	 intCheckoutIdNew,		
		PI.intItemId				AS 	 intItemIdNew,	
		PI.intCountGroupId			AS 	 intCountGroupIdNew,		
		PI.intItemLocationId		AS 	 intItemLocationIdNew,		
		PI.dblSystemCount			AS 	 dblSystemCountNew,			
		PI.dblQtyReceived			AS 	 dblQtyReceivedNew,			
		PI.dblQtySold				AS 	 dblQtySoldNew,				
		PI.intItemUOMId				AS 	 intItemUOMIdNew,				
		PI.intEntityUserSecurityId	AS 	 intEntityUserSecurityIdNew,
		PI.intConcurrencyId			AS	 intConcurrencyIdNew
	FROM @tmpTblShiftPhysicalItem PI
	LEFT JOIN tblSTCheckoutShiftPhysicalPreview SPP
		ON SPP.intCheckoutId = PI.intCheckoutId
		AND SPP.intItemId = PI.intItemId
		AND SPP.intItemLocationId = PI.intItemLocationId
		AND SPP.intItemUOMId = PI.intItemUOMId
) AS u
	ON e.intCheckoutShiftPhysicalPreviewId = u.intCheckoutShiftPhysicalPreviewId

-- If matched, update the effective cost.
WHEN MATCHED THEN 
	UPDATE 
	SET 
		--e.dblSystemCount = u.dblSystemCount
		e.dblQtyReceived = u.dblQtyReceived
		,e.dblQtySold = u.dblQtySold
		,e.dtmCheckoutDate = @dtmCheckoutDate
		
-- If none found, insert a new Effective Item Cost
WHEN NOT MATCHED THEN 
	INSERT (
		intCheckoutId
		, intItemId
		, intCountGroupId
		, intItemLocationId
		, dblSystemCount
		, dblQtyReceived
		, dblQtySold
		, intItemUOMId
		, intEntityUserSecurityId
		, dtmCheckoutDate
		, intLocationId
		, intConcurrencyId
	)
	VALUES (
		u.intCheckoutIdNew,
		u.intItemIdNew,
		u.intCountGroupIdNew,
		u.intItemLocationIdNew,
		u.dblSystemCountNew,
		ISNULL(u.dblQtyReceivedNew, 0),
		ISNULL(u.dblQtySoldNew, 0),
		u.intItemUOMIdNew,
		u.intEntityUserSecurityIdNew,
		@dtmCheckoutDate,
		@intCompanyLocationId,
		u.intConcurrencyIdNew
	);

	

END TRY
BEGIN CATCH
		SET @strStatusMsg = ERROR_MESSAGE()
END CATCH