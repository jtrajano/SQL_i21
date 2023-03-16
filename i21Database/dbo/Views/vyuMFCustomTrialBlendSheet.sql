CREATE VIEW [dbo].[vyuMFCustomTrialBlendSheet]
AS 
SELECT intWorkOrderId			= WO.intWorkOrderId
	 , strLocationName			= CL.strLocationName									-- Plant
	 , strReferenceNo			= COALESCE(WO.strReferenceNo, BR.strReferenceNo)		-- Order Nbr
	 , strItemNo				= Item.strItemNo										-- Blend Code
	 , dtmCreated				= FORMAT(WO.dtmCreated, 'dd,MM,yyyy')					-- Date Created
	 , dblEstNoOfBlendSheet		= FLOOR(BR.dblEstNoOfBlendSheet)						-- Mixes
	 , dblEstimatedIssueQty		= [dbo].[fnRemoveTrailingZeroes](CASE WHEN ISNULL(BR.dblEstNoOfBlendSheet, 0) > 0 THEN WOIL.dblIssuedQuantity / BR.dblEstNoOfBlendSheet ELSE WOIL.dblIssuedQuantity END)
	 , dblBlenderSize			= BR.dblBlenderSize										-- Net Wt per mix
	 , dblQuantity				= FLOOR(WO.dblQuantity)									-- Total Blend Wt
	 , strComment				= WO.strComment											-- Comment
	 , dblWorkOrderQty			= ISNULL(WO.dblQuantity, 0)								-- Work Order Quantity
	 , WOIL.*
FROM tblMFWorkOrder AS WO
LEFT JOIN tblSMCompanyLocation AS CL ON WO.intLocationId = CL.intCompanyLocationId
LEFT JOIN tblICItem AS Item ON WO.intItemId = Item.intItemId
LEFT JOIN tblMFBlendRequirement AS BR ON WO.intBlendRequirementId = BR.intBlendRequirementId
LEFT JOIN (
	SELECT intReferenceWOId					= IL.intWorkOrderId
		 , ysnKeep							= CASE WHEN IL.ysnKeep = 1 THEN 'KEEP' ELSE '' END
		 , intLotId							= IL.intLotId
		 , strLotNumber						= Lot.strLotNumber																		-- Batch
		 , dblTBSQuantity					= ISNULL(IL.dblTBSQuantity, (IL.dblQuantity / OIL.dblSumQuantity)) * ISNULL(CP.dblTrialBlendSheetSize, 0)		-- Weigh Up (Grams)
		 , strERPPONumber					= Batch.strERPPONumber																	-- Purchase Order
		 , strTeaGardenChopInvoiceNumber	= Batch.strTeaGardenChopInvoiceNumber													-- Chop
		 , strGardenMark					= GM.strGardenMark																		-- Mark
		 , strLeafGrade						= Batch.strLeafGrade																	-- Grade
		 , strTeaItemNo						= Item.strItemNo																		-- Tea Item
		 , dblTeaTaste						= Batch.dblTeaTaste																		-- T
		 , dblTeaHue						= Batch.dblTeaHue																		-- H
		 , dblTeaIntensity					= Batch.dblTeaIntensity																	-- I
		 , dblTeaMouthFeel					= Batch.dblTeaMouthFeel																	-- M
		 , dblTeaAppearance					= Batch.dblTeaAppearance 																-- A
		 , dblTeaVolume						= Batch.dblTeaVolume																	-- V
		 , strLeafCategory					= Batch.strLeafCategory 																-- Leaf
		 , strTasterComments				= Batch.strTasterComments																-- Comments
		 , dblTeaQuantity					= IL.dblQuantity																		-- Wght
		 , dblSellingPrice					= Batch.dblSellingPrice 																-- Sell
		 , dblLandedPrice					= Batch.dblLandedPrice 																	-- Land
		 , dblWeightPerQty					= Lot.dblWeightPerQty																	-- Kgs./Bags / Weight Per Qty
		 , strFW							= ISNULL(strFW, '')																		-- FW
		 , dblSumQuantity					= CAST(OIL.dblSumQuantity AS NUMERIC(38,0))							-- Sum Qty ***
		 , strTINNumber						= TinClearance.strTINNumber																-- TIN Number
		 , intAge							= DATEDIFF(D, ISNULL(Lot.dtmManufacturedDate, Lot.dtmDateCreated), GETDATE())			-- Age
		 , strLeaf							= Batch.strLeafSize + ' - ' + Batch.strLeafStyle										-- Leaf 
		 , dblIssuedQuantity				= IL.dblIssuedQuantity
		 , dblPercentage					= CASE WHEN ISNULL(OIL.dblSumQuantity, 0) > 0 THEN (IL.dblQuantity/OIL.dblSumQuantity) * 100 ELSE 100 END
	FROM tblMFWorkOrderInputLot IL
	INNER JOIN tblICLot AS Lot ON IL.intLotId = Lot.intLotId
	INNER JOIN tblICItem AS Item ON IL.intItemId = Item.intItemId
	INNER JOIN tblMFLotInventory AS LotInventory ON IL.intLotId = LotInventory.intLotId
	INNER JOIN tblMFBatch AS Batch ON LotInventory.intBatchId = Batch.intBatchId 
	LEFT JOIN tblQMGardenMark AS GM ON Batch.intGardenMarkId = GM.intGardenMarkId
	OUTER APPLY (
		SELECT TOP 1 dblTrialBlendSheetSize 
		FROM tblMFCompanyPreference
	) CP	
	LEFT JOIN (
		SELECT intWorkOrderId	= intWorkOrderId
			 , dblSumQuantity	= SUM(dblQuantity)
		FROM tblMFWorkOrderInputLot
		GROUP BY intWorkOrderId
	) OIL ON IL.intWorkOrderId = OIL.intWorkOrderId
	OUTER APPLY (
		SELECT TOP 1 strTINNumber
		FROM tblQMTINClearance TC
		WHERE TC.intBatchId= Batch.intBatchId 
		ORDER BY intTINClearanceId DESC
	) AS TinClearance
) WOIL ON WO.intWorkOrderId = WOIL.intReferenceWOId