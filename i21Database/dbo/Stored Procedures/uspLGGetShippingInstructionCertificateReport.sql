CREATE PROCEDURE [dbo].[uspLGGetShippingInstructionCertificateReport]
		@intReferenceNumber INT  
AS
BEGIN
SELECT 
	SIC.intShippingInstructionId,
	DOC.strDocumentName,
	SIC.strDocumentType,
	SIC.intOriginal,
	SIC.intCopies

FROM	tblLGShippingInstructionCertificates SIC
JOIN	tblLGShippingInstruction SI ON SI.intShippingInstructionId = SIC.intShippingInstructionId
JOIN	tblICDocument DOC ON DOC.intDocumentId = SIC.intDocumentId
WHERE 	SI.intReferenceNumber = @intReferenceNumber	
END
