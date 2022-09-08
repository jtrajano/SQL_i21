CREATE PROCEDURE [dbo].[uspSTUpdateShiftPhysicalItem]
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

DECLARE @tmpTblShiftPhysicalItem TABLE (
		intCheckoutId INT NULL,
		intItemId INT NULL,
		intCountGroupId INT NULL,
		intItemLocationId INT NULL,
		dblSystemCount NUMERIC(20, 2) NULL,
		dblQtyReceived NUMERIC(20, 2) NULL,
		dblQtyTransferred NUMERIC(20, 2) NULL,
		dblQtySold NUMERIC(20, 2) NULL,
		intItemUOMId INT NULL,
		intEntityUserSecurityId INT NULL,
		intConcurrencyId INT NULL
)

--NORMAL ITEMS
INSERT INTO @tmpTblShiftPhysicalItem(
	intCheckoutId
	, intItemId
	, intItemLocationId
	, dblSystemCount
	, dblQtyReceived
	, dblQtyTransferred
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
	, InventoryQtyTransferred.dblQtyTransferred
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
		IT.intFromLocationId,
		IT.dtmTransferDate,
		ITD.intItemId,
		UOM.intUnitMeasureId,
		SUM(ITD.dblQuantity) AS dblQtyTransferred
	FROM tblICInventoryTransfer IT
	JOIN tblICInventoryTransferDetail ITD
		ON IT.intInventoryTransferId = ITD.intInventoryTransferId
	JOIN tblICItemUOM UOM
		ON ITD.intItemUOMId = UOM.intItemUOMId
	JOIN tblICItemLocation IL
		ON IL.intItemId = ITD.intItemId AND IL.intLocationId = IT.intFromLocationId
	WHERE ISNULL(IL.intCountGroupId, 0) = 0 AND IL.ysnCountedDaily = 1
	GROUP BY 
		IT.intFromLocationId,
		IT.dtmTransferDate,
		ITD.intItemId,
		UOM.intUnitMeasureId
) AS InventoryQtyTransferred
	ON I.intItemId = InventoryQtyTransferred.intItemId
	AND IL.intLocationId = InventoryQtyTransferred.intFromLocationId
	AND @dtmCheckoutDate = InventoryQtyTransferred.dtmTransferDate
	AND UOM.intItemUOMId = InventoryQtyTransferred.intUnitMeasureId
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
		PI.dblQtyTransferred		AS 	 dblQtyTransferredNew,		
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
		,e.dblQtyTransferred = u.dblQtyTransferred
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
		, dblQtyTransferred
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
		ISNULL(u.dblQtyTransferred, 0),
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