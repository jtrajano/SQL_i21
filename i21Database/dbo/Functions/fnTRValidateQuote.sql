CREATE FUNCTION [dbo].[fnTRValidateQuote]
(
	@intQuoteId INT
)
RETURNS BIT
AS
BEGIN
	DECLARE @valid BIT = 0

	DECLARE @intSetupCount INT = NULL
	DECLARE @intTransCount INT = NULL

	SELECT @intSetupCount = SETUP,  @intTransCount = [QUOTE] 
	FROM (
		SELECT 'TOTAL' AS TOTAL, [SETUP], [QUOTE] 
		FROM (
			SELECT COUNT(strType) CNT, strType  FROM (
				SELECT  DISTINCT QD.intItemId
				, SP.intEntityVendorId intTerminalId
				, QD.intSupplyPointId
				, EL.intEntityLocationId intLocationId	
				, EL.intTaxGroupId
				, GC.intTaxCodeId
				, 'SETUP' strType
				FROM tblEMEntityLocation EL
				INNER JOIN tblTRQuoteHeader QH ON QH.intEntityCustomerId = EL.intEntityId
				LEFT JOIN vyuTRQuoteSelection QD ON QD.intEntityCustomerId = EL.intEntityId AND QD.intEntityCustomerLocationId = EL.intEntityLocationId
				LEFT JOIN vyuTRSupplyPointView SP ON QD.intSupplyPointId = SP.intSupplyPointId
				LEFT JOIN tblSMTaxGroupCode GC ON GC.intTaxGroupId = EL.intTaxGroupId
				WHERE QD.ysnQuote = 1 AND QH.intQuoteHeaderId = @intQuoteId
				UNION ALL
				SELECT DISTINCT QD.intItemId
				, QD.intTerminalId
				, QD.intSupplyPointId
				, QD.intShipToLocationId intLocationId
				, QD.intTaxGroupId
				, QDT.intTaxCodeId
				, 'QUOTE' strType
				 FROM tblTRQuoteDetailTax QDT
				INNER JOIN tblTRQuoteDetail QD ON QD.intTaxGroupId = QDT.intTaxGroupId
				INNER JOIN tblTRQuoteHeader QH ON QH.intQuoteHeaderId = QD.intQuoteHeaderId
				WHERE QH.intQuoteHeaderId = @intQuoteId
			) A
			GROUP BY A.intItemId, A.intTerminalId, A.intSupplyPointId, A.intLocationId, A.intTaxGroupId, A.intTaxCodeId, A.strType
		) B

		PIVOT 
		(COUNT(CNT) FOR strType IN ([SETUP], [QUOTE])) AS PIVOTDATA

	) RESULTDATA

	--PRINT @intTransCount
	IF (@intTransCount IS NOT NULL AND @intSetupCount IS NOT NULL)
	BEGIN
		IF (@intTransCount = @intSetupCount)
		BEGIN
			SET @valid = 1
		END
	END	

	RETURN @valid
END
