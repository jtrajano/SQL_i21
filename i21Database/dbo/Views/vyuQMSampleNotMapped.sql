CREATE VIEW vyuQMSampleNotMapped
AS
SELECT S.intSampleId
	,ST.intControlPointId
	,I.strDescription
	,IR.strReceiptNumber
FROM tblQMSample S
JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
LEFT JOIN tblICItem I ON I.intItemId = S.intItemId
LEFT JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = S.intInventoryReceiptId
