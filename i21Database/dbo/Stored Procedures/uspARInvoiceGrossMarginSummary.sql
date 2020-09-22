
CREATE PROCEDURE uspARInvoiceGrossMarginSummary
(
	@ysnPosted BIT = 0,
    @ysnRebuild BIT = 0,
	@intInvoiceId INT = 0,
	@dtmDate DATETIME = '01-01-1900'
)
AS
IF @ysnRebuild = 1
BEGIN
    TRUNCATE TABLE tblARInvoiceGrossMarginSummary
    INSERT INTO tblARInvoiceGrossMarginSummary (strType, intInvoiceId,dblAmount, dtmDate,intConcurrencyId)
    SELECT strType ,intInvoiceId,SUM(dblAmount) dblAmount, dtmDate,1  FROM vyuARInvoiceGrossMargin GROUP BY intInvoiceId,strType,dtmDate
END
ELSE
BEGIN
    IF @ysnPosted = 1 
    BEGIN
        INSERT INTO tblARInvoiceGrossMarginSummary (strType, intInvoiceId,  dblAmount ,dtmDate, intConcurrencyId)
        SELECT strType ,intInvoiceId,SUM(dblAmount) dblAmount, dtmDate,1  FROM vyuARInvoiceGrossMargin WHERE intInvoiceId = @intInvoiceId group by strType, dtmDate,intInvoiceId
        
    END
    ELSE
    BEGIN
        INSERT INTO tblARInvoiceGrossMarginSummary (strType, intInvoiceId, dtmDate, dblAmount, intConcurrencyId)
        SELECT strType, @intInvoiceId, @dtmDate, SUM(dblAmount) * -1, 1 FROM tblARInvoiceGrossMarginSummary WHERE @intInvoiceId = intInvoiceId group by strType, dtmDate,intInvoiceId
    END
END