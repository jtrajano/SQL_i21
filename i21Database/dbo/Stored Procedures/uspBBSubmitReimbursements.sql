CREATE PROCEDURE [dbo].[uspBBSubmitReimbursements] (@UniqueId UNIQUEIDENTIFIER)
AS

INSERT INTO tblBBBuyback (intEntityId, dtmReimbursementDate, strReimbursementNo, guiUniqueId, intConcurrencyId)
SELECT br.intEntityId, GETDATE(), CAST(ROW_NUMBER() OVER(PARTITION BY br.intEntityId ORDER BY  br.intEntityId ASC) AS NVARCHAR(100)), @UniqueId, 1
FROM (
    SELECT DISTINCT r.intEntityId
    FROM vyuBBOpenBuybackWithRate r
    JOIN tblBBReimbursementPostingSession ps ON ps.intInvoiceDetailId = r.intInvoiceDetailId
    WHERE ISNULL(r.dblRatePerUnit, 0) != 0
        AND ps.guiSessionId = @UniqueId
) br

DECLARE @StartingNo NVARCHAR(50)
DECLARE @BuybackId INT

DECLARE cur CURSOR FAST_FORWARD FOR
    SELECT intBuybackId
    FROM tblBBBuyback
    WHERE guiUniqueId = @UniqueId
 
OPEN cur
FETCH NEXT FROM cur INTO @BuybackId
 
WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC dbo.uspSMGetStartingNumber 130, @StartingNo OUT

    UPDATE tblBBBuyback
    SET strReimbursementNo = @StartingNo
    WHERE intBuybackId = @BuybackId

    FETCH NEXT FROM cur INTO @BuybackId
END

CLOSE cur
DEALLOCATE cur

DECLARE @Details TABLE (
	intBuybackId INT, 
	intInvoiceDetailId INT, 
	intProgramRateId INT NULL, intItemId INT, 
    dblBuybackRate NUMERIC(18, 6), dblBuybackQuantity NUMERIC(32, 20), 
	dblReimbursementAmount NUMERIC(18, 6), 
	dblItemCost NUMERIC(18, 6),
    strCharge NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	intConcurrencyId INT)

INSERT INTO @Details (
    intBuybackId, intInvoiceDetailId, intProgramRateId, intItemId, 
    dblBuybackRate, dblBuybackQuantity, dblReimbursementAmount, dblItemCost,
    strCharge, intConcurrencyId)
SELECT bb.intBuybackId, br.intInvoiceDetailId, br.intProgramRateId, br.intItemId,
    br.dblRatePerUnit, br.dblQuantity, br.dblReimbursementAmount, br.dblItemCost,
    br.strCharge, 1
FROM tblBBBuyback bb
JOIN vyuBBOpenBuybackWithRate br ON br.intEntityId = bb.intEntityId
JOIN tblBBReimbursementPostingSession ps ON ps.intInvoiceDetailId = br.intInvoiceDetailId
WHERE ISNULL(br.dblRatePerUnit, 0) != 0
    AND ps.guiSessionId = @UniqueId
    AND bb.guiUniqueId = @UniqueId

-- Create Inventory
INSERT INTO tblBBBuybackDetail(
    intBuybackId, intInvoiceDetailId, intProgramRateId, intItemId, 
    dblBuybackRate, dblBuybackQuantity, dblReimbursementAmount, dblItemCost,
    strCharge, intConcurrencyId)
SELECT DISTINCT intBuybackId, intInvoiceDetailId, NULL, intItemId, 
    dblItemCost, dblBuybackQuantity, dblBuybackQuantity * dblItemCost, dblItemCost,
    'Inventory', intConcurrencyId
FROM @Details

-- Create Charge
INSERT INTO tblBBBuybackDetail(
    intBuybackId, intInvoiceDetailId, intProgramRateId, intItemId, 
    dblBuybackRate, dblBuybackQuantity, dblReimbursementAmount, dblItemCost,
    strCharge, intConcurrencyId)
SELECT intBuybackId, intInvoiceDetailId, intProgramRateId, intItemId, 
    dblBuybackRate, dblBuybackQuantity, dblReimbursementAmount, dblItemCost,
    strCharge, intConcurrencyId
FROM @Details

UPDATE b
SET b.dblReimbursementAmount = (
    SELECT SUM(bd.dblReimbursementAmount)
    FROM tblBBBuybackDetail bd
    JOIN tblBBBuyback bb ON bb.intBuybackId = bd.intBuybackId
        AND bb.intBuybackId = b.intBuybackId
)
FROM tblBBBuyback b
WHERE b.guiUniqueId = @UniqueId

INSERT INTO tblBBBuybackCharge (strCharge, intBuybackId, dblReimbursementAmount, intConcurrencyId)
SELECT bd.strCharge, bb.intBuybackId, bd.dblReimbursementAmount, 1
FROM tblBBBuybackDetail bd
JOIN tblBBBuyback bb ON bb.intBuybackId = bd.intBuybackId
    AND bb.intBuybackId = bd.intBuybackId 
WHERE bb.guiUniqueId = @UniqueId
    AND bd.strCharge != 'Inventory'

DELETE FROM tblBBReimbursementPostingSession WHERE guiSessionId = @UniqueId

DECLARE @strBuybackIds NVARCHAR(MAX)

DECLARE @Delimiter CHAR(2) 
SET @Delimiter = ', '

SELECT @strBuybackIds = COALESCE(@strBuybackIds + @Delimiter,'') + CAST(intBuybackId AS NVARCHAR(200))
FROM dbo.tblBBBuyback
WHERE guiUniqueId = @UniqueId

SET @strBuybackIds = RTRIM(LTRIM(@strBuybackIds))

IF (@strBuybackIds IS NOT NULL)
BEGIN
    EXEC dbo.uspBBAddTransactionLinks @strBuybackIds, 1
    EXEC uspBBResolveBuybackCosts @strBuybackIds
END