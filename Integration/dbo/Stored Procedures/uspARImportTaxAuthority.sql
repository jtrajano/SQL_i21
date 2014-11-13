GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspARImportTaxAuthority')
	DROP PROCEDURE uspARImportTaxAuthority
GO
CREATE PROCEDURE uspARImportTaxAuthority
    @Checking BIT = 0,
    @Total INT = 0 OUTPUT

    AS
 BEGIN 
    --================================================
    --     ONE TIME TAX AUTHORITY SYNCHRONIZATION    
    --================================================
    IF(@Checking = 0) 
    BEGIN

        INSERT INTO [tblARTaxAuthority]
            ([strState]
            ,[strAuthorityId1]
            ,[strAuthorityId2])
        SELECT
             LTRIM(RTRIM(aglcl_tax_state))
            ,LTRIM(RTRIM(aglcl_tax_auth_id1))
            ,LTRIM(RTRIM(aglcl_tax_auth_id2))
        FROM aglclmst

    END
    
    IF(@Checking = 1)
    BEGIN
        DECLARE @originTaxAuthorityCount INT
        DECLARE @taxAuthorityCount INT
        
        SELECT @originTaxAuthorityCount = COUNT(aglcl_tax_state) FROM aglclmst
        SELECT @taxAuthorityCount = COUNT(intTaxAuthorityId) FROM tblARTaxAuthority
        
        IF(@originTaxAuthorityCount = @taxAuthorityCount)
        BEGIN
            SET @Total = 0
        END
        ELSE
            Set @Total = @originTaxAuthorityCount
    END
END
