CREATE VIEW [dbo].[vyuMFGetItemSupplyTarget]
AS
SELECT I.strItemNo as strNo
	,IL.dblLeadTime AS dblTgt
FROM dbo.tblICItem I
JOIN dbo.tblICItemLocation IL ON IL.intItemId = I.intItemId
WHERE strType <> 'Other Charge'
