CREATE FUNCTION [dbo].[fnMBILGetInvoiceStatus]
(
	@CustomerId INT,
	@SiteId INT
)
RETURNS NVARCHAR(MAX)

AS

BEGIN
	
	DECLARE @DefaultCustomer NVARCHAR(50)
		, @DefaultSite NVARCHAR(50)
		, @Status NVARCHAR(MAX) = ''
		, @CustomerNo NVARCHAR(50)
		, @Site NVARCHAR(50)

	SELECT TOP 1 @DefaultCustomer = strDefaultCustomerNo, @DefaultSite = strDefaultSiteNo FROM tblMBILCompanyPreference

	IF (ISNULL(@CustomerId, 0) != 0)
	BEGIN
		SELECT TOP 1 @CustomerNo = strEntityNo FROM tblEMEntity WHERE intEntityId = @CustomerId
		SET @Status = (CASE WHEN ISNULL(@CustomerNo, '') = '' THEN 'Customer does not exist!'
							WHEN LEFT(@CustomerNo, LEN(@DefaultCustomer)) = @DefaultCustomer THEN 'Customer needs review.'
							ELSE '' END)
	END

	IF (ISNULL(@SiteId, 0) != 0)
	BEGIN
		SELECT TOP 1 @Site = strDescription FROM tblTMSite WHERE intSiteID = @SiteId
		SET @Status = (CASE WHEN ISNULL(@Site, '') = '' THEN 'Site does not exist!'
							WHEN LEFT(@Site, LEN(@DefaultSite)) = @DefaultSite THEN 'Site needs review.'
							ELSE '' END)
	END
	
	RETURN @Status
END
