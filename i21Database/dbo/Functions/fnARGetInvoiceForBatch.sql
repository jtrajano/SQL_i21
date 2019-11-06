CREATE FUNCTION [dbo].[fnARGetInvoiceForBatch]
(
	  @intEntityCustomerId          INT
    , @intContractShipToLocationId  INT
)
RETURNS INT
AS
BEGIN
	DECLARE @intInvoiceId			INT = NULL
          , @strBatchInvoiceBy		NVARCHAR(MAX)
          , @dtmBatchTimeFrom		TIME = NULL
          , @dtmBatchTimeTo			TIME = NULL

    SELECT @strBatchInvoiceBy	= strBatchInvoiceBy
         , @dtmBatchTimeFrom	= CAST(ISNULL(dtmBatchTimeFrom, '12:00:00 AM') AS TIME)
         , @dtmBatchTimeTo		= CAST(ISNULL(dtmBatchTimeTo, '11:59:59 PM') AS TIME)
    FROM tblARCustomer
    WHERE ISNULL(strBatchInvoiceBy, '') <> ''
    AND intEntityId = @intEntityCustomerId

    IF UPPER(@strBatchInvoiceBy) = UPPER('Per Time')
        BEGIN
            SELECT TOP 1 @intInvoiceId = intInvoiceId
            FROM tblARInvoice
            WHERE ysnPosted = 0
              AND strTransactionType = 'Invoice'
              AND strType = 'Standard'
              AND intEntityCustomerId = @intEntityCustomerId
              AND CAST(dtmDateCreated AS DATE) = CAST(GETDATE() AS DATE)
              AND CAST(GETDATE() AS TIME) BETWEEN @dtmBatchTimeFrom AND @dtmBatchTimeTo
            ORDER BY dtmDateCreated DESC
        END
    ELSE IF UPPER(@strBatchInvoiceBy) = UPPER('Per Time and Location') AND ISNULL(@intContractShipToLocationId, 0) <> 0
        BEGIN
            SELECT TOP 1 @intInvoiceId = intInvoiceId
            FROM tblARInvoice
            WHERE ysnPosted = 0
              AND strTransactionType = 'Invoice'
              AND strType = 'Standard'
              AND intEntityCustomerId = @intEntityCustomerId
              AND CAST(dtmDateCreated AS DATE) = CAST(GETDATE() AS DATE)
              AND CAST(GETDATE() AS TIME) BETWEEN @dtmBatchTimeFrom AND @dtmBatchTimeTo
              AND intShipToLocationId = @intContractShipToLocationId
            ORDER BY dtmDateCreated DESC
        END

    RETURN @intInvoiceId
END
