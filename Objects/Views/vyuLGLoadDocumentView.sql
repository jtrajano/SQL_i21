CREATE VIEW [dbo].[vyuLGLoadDocumentView]
AS
SELECT LD.*,D.strDocumentName 
FROM tblLGLoadDocuments LD
JOIN tblICDocument D ON D.intDocumentId = LD.intDocumentId
