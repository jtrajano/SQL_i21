CREATE PROCEDURE [dbo].[uspMBILCreateSite]        
 @EntityCustomerId INT,        
 @SiteDescription NVARCHAR(MAX) = NULL,        
 @SiteAddress NVARCHAR(MAX)  = NULL,        
 @City NVARCHAR(MAX)  = NULL,        
 @State NVARCHAR(MAX)  = NULL,        
 @ZipCode NVARCHAR(MAX)  = NULL,        
 @DriverId INT = NULL,        
 @Country NVARCHAR(MAX) = NULL,        
 @AcctStatus NVARCHAR(MAX) = NULL,      
 @ClockId INT = NULL,        
 @RouteId INT = NULL,        
 @ItemId INT = NULL,        
 @LocationId INT = NULL,        
 @UserId INT = NULL,        
 @SiteId INT OUTPUT,    
 @SiteNumber INT OUTPUT    
AS        
        
SET QUOTED_IDENTIFIER OFF        
SET ANSI_NULLS ON        
SET NOCOUNT ON        
SET XACT_ABORT ON        
SET ANSI_WARNINGS OFF        
        
DECLARE @ErrorMessage NVARCHAR(4000)        
DECLARE @ErrorSeverity INT        
DECLARE @ErrorState INT        
        
BEGIN TRY        
        
 DECLARE @Message NVARCHAR(MAX)        
  , @DefaultSiteNo NVARCHAR(50)        
  , @CountNo INT = 0        
  --, @SiteNumber INT = 0        
  , @TMCustomerId INT        
        
 SELECT TOP 1 @TMCustomerId = intCustomerID, @SiteNumber = intCurrentSiteNumber FROM tblTMCustomer WHERE intCustomerNumber = @EntityCustomerId        
        
 IF (ISNULL(@TMCustomerId, 0) = 0)        
 BEGIN        
  INSERT INTO tblTMCustomer(intCurrentSiteNumber, intCustomerNumber, intConcurrencyId)        
  VALUES (1, @EntityCustomerId, 1)        
        
  SET @TMCustomerId = SCOPE_IDENTITY()        
  SET @SiteNumber = 1        
        
 END        
 ELSE        
 BEGIN        
  SET @SiteNumber = @SiteNumber + 1        
  UPDATE tblTMCustomer SET intCurrentSiteNumber = @SiteNumber  WHERE intCustomerNumber = @EntityCustomerId        
 END        
        
 INSERT INTO tblTMSite(intProduct        
  , intCustomerID        
  , intLocationId        
  , intSiteNumber        
  , intDriverID        
  , strDescription        
  , strSiteAddress        
  , strCity        
  , strState        
  , strZipCode        
  , intClockID        
  , intRouteId        
  , intHoldReasonID        
  , intFillMethodId      
  , strCountry      
  , strAcctStatus  
  , ysnRequirePump)        
 SELECT @ItemId        
  , @TMCustomerId        
  , @LocationId        
  , @SiteNumber        
  , @DriverId        
  , @SiteDescription        
  , @SiteAddress        
  , @City        
  , @State        
  , @ZipCode        
  , @ClockId        
  , @RouteId        
  , null        
  , null        
  , @Country      
  , @AcctStatus   
  , 1  
 SET @SiteId = SCOPE_IDENTITY()        
        
END TRY        
BEGIN CATCH        
 SELECT         
  @ErrorMessage = ERROR_MESSAGE(),        
  @ErrorSeverity = ERROR_SEVERITY(),        
  @ErrorState = ERROR_STATE();        
        
 -- Use RAISERROR inside the CATCH block to return error        
 -- information about the original error that caused        
 -- execution to jump to the CATCH block.        
 RAISERROR (        
  @ErrorMessage, -- Message text.        
  @ErrorSeverity, -- Severity.        
  @ErrorState -- State.        
 );        
END CATCH