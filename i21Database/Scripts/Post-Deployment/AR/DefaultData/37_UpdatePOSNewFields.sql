print('/*******************  BEGIN Update tblARPOS.strInvoiceNumber, strCreditMemoNumber, ysnMixed  *******************/')
GO

DECLARE @INSERTED_INVOICENUMBER TABLE(intPOSId INT, intCompanyLocationId INT, ysnReturn BIT, ysnMixed BIT)
DECLARE @intPOSId 						INT = NULL
DECLARE @intCompanyLocationId 			INT = NULL
DECLARE @intInvoiceStartingNumberId 	INT = NULL
DECLARE @ysnReturn						BIT = NULL
DECLARE @ysnMixed						BIT = NULL
DECLARE @strInvoiceNumber 				NVARCHAR(50) = NULL
DECLARE @strCreditMemoNumber			NVARCHAR(50) = NULL

INSERT INTO @INSERTED_INVOICENUMBER
SELECT intPOSId
	 , intCompanyLocationId 
	 , ysnReturn
	 , ysnMixed
FROM tblARPOS
WHERE ysnHold = 0
AND intInvoiceId IS NULL
AND intCreditMemoId IS NULL
AND (strInvoiceNumber IS NULL AND strCreditMemoNumber IS NULL)
ORDER BY intPOSId

SELECT TOP 1 @intInvoiceStartingNumberId = intStartingNumberId FROM tblSMStartingNumber WHERE strTransactionType = 'Invoice' AND strModule = 'Accounts Receivable'

WHILE((SELECT TOP 1 1 FROM @INSERTED_INVOICENUMBER) IS NOT NULL)
BEGIN
	SET @strInvoiceNumber = NULL
	SET @strCreditMemoNumber = NULL

	SELECT TOP 1 @intPOSId = intPOSId
			   , @intCompanyLocationId = intCompanyLocationId
			   , @ysnReturn = ysnReturn
			   , @ysnMixed = ysnMixed 
	FROM @INSERTED_INVOICENUMBER
	
	IF @ysnReturn = 0	
		EXEC uspSMGetStartingNumber @intInvoiceStartingNumberId, @strInvoiceNumber OUT, @intCompanyLocationId

	IF @ysnReturn = 1 OR @ysnMixed = 1
		EXEC uspSMGetStartingNumber @intInvoiceStartingNumberId, @strCreditMemoNumber OUT, @intCompanyLocationId

	IF ISNULL(@strInvoiceNumber, '') <> ''
	BEGIN
		IF EXISTS (SELECT NULL FROM tblARInvoice WHERE strInvoiceNumber = @strInvoiceNumber) OR EXISTS(SELECT NULL FROM tblARPOS WHERE strInvoiceNumber = @strInvoiceNumber OR strCreditMemoNumber = @strInvoiceNumber)
			BEGIN
				SET @strInvoiceNumber = NULL
				
				EXEC uspSMGetStartingNumber @intInvoiceStartingNumberId, @strInvoiceNumber OUT, @intCompanyLocationId			
			END
	END

	IF ISNULL(@strCreditMemoNumber, '') <> ''
	BEGIN
		IF EXISTS (SELECT NULL FROM tblARInvoice WHERE strInvoiceNumber = @strCreditMemoNumber) OR EXISTS(SELECT NULL FROM tblARPOS WHERE strInvoiceNumber = @strCreditMemoNumber OR strCreditMemoNumber = @strCreditMemoNumber)
			BEGIN
				SET @strCreditMemoNumber = NULL
				
				EXEC uspSMGetStartingNumber @intInvoiceStartingNumberId, @strCreditMemoNumber OUT, @intCompanyLocationId			
			END
	END

	UPDATE tblARPOS
	SET strInvoiceNumber	= CASE WHEN @ysnReturn = 0 THEN @strInvoiceNumber ELSE NULL END
	  , strCreditMemoNumber	= CASE WHEN @ysnReturn = 1 OR @ysnMixed = 1 THEN @strCreditMemoNumber ELSE NULL END
	WHERE intPOSId = @intPOSId

	DELETE FROM @INSERTED_INVOICENUMBER
	WHERE intPOSId = @intPOSId
END


--UPDATE MIXED POS
UPDATE POS
SET ysnMixed = CAST(1 AS BIT)
FROM tblARPOS POS
INNER JOIN tblARPOSLog POSLOG ON POS.intPOSLogId = POSLOG.intPOSLogId
INNER JOIN tblARPOSEndOfDay EOD ON POSLOG.intPOSEndOfDayId = EOD.intPOSEndOfDayId
CROSS APPLY (
	SELECT TOP 1 POSD.intPOSId
	FROM tblARPOSDetail POSD
	WHERE POSD.dblQuantity < 0 
	  AND POSD.intPOSId = POS.intPOSId
	GROUP BY intPOSId	
) NEGQTY
CROSS APPLY (
	SELECT TOP 1 POSD.intPOSId
	FROM tblARPOSDetail POSD
	WHERE POSD.dblQuantity > 0 
	  AND POSD.intPOSId = POS.intPOSId
	GROUP BY intPOSId	
) POSQTY
WHERE POS.ysnReturn = 0
  AND POS.ysnHold = 0

--REGULAR POS
UPDATE POS
SET strInvoiceNumber = I.strInvoiceNumber
FROM tblARPOS POS
INNER JOIN tblARInvoice I ON POS.intInvoiceId = I.intInvoiceId
WHERE POS.ysnHold = 0
  AND POS.intInvoiceId IS NOT NULL
  AND POS.strInvoiceNumber IS NULL

--RETURN POS
UPDATE POS
SET strCreditMemoNumber = I.strInvoiceNumber
  , strInvoiceNumber    = NULL
FROM tblARPOS POS
INNER JOIN tblARInvoice I ON POS.intCreditMemoId = I.intInvoiceId
WHERE POS.ysnHold = 0
  AND POS.intInvoiceId IS NULL
  AND POS.intCreditMemoId IS NOT NULL
  AND POS.strCreditMemoNumber IS NULL
 
--MIXED POS INVOICE NUMBER
UPDATE POS
SET strCreditMemoNumber = I.strInvoiceNumber
FROM tblARPOS POS
INNER JOIN tblARInvoice I ON POS.intCreditMemoId = I.intInvoiceId
WHERE POS.ysnHold = 0
  AND POS.ysnMixed = 1  
  AND POS.intCreditMemoId IS NOT NULL
  AND POS.strCreditMemoNumber IS NULL

--MIXED POS CREDIT MEMO NUMBER
UPDATE POS
SET strInvoiceNumber = I.strInvoiceNumber
FROM tblARPOS POS
INNER JOIN tblARInvoice I ON POS.intInvoiceId = I.intInvoiceId
WHERE POS.ysnHold = 0
  AND POS.ysnMixed = 1  
  AND POS.intInvoiceId IS NOT NULL
  AND POS.strInvoiceNumber IS NULL
			
GO
print('/*******************  BEGIN Update tblARPOS.strInvoiceNumber, strCreditMemoNumber, ysnMixed  *******************/')