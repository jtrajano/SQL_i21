CREATE PROCEDURE [dbo].[uspMBILCreateCustomer]         
 @UserId INT,        
 @EntityId INT OUTPUT,      
 @EntityNo NVARCHAR(MAX) OUTPUT,      
 @strName NVARCHAR(MAX) = NULL,      
 @strEmail NVARCHAR(MAX) = NULL,      
 @intTermId INT = NULL,      
 @strLocation NVARCHAR(MAX) = NULL,      
 @intCountryId INT = NULL,      
 @strState NVARCHAR(MAX) = NULL,      
 @intFreightTermId INT = NULL,      
 @strCity NVARCHAR(MAX) = NULL,      
 @strAddress NVARCHAR(MAX) = NULL,      
 @strZipCode NVARCHAR(50) = NULL,      
 @strPhone NVARCHAR(MAX) = NULL,      
 @strMobile NVARCHAR(MAX) = NULL    
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
  , @DefaultCustomerNo NVARCHAR(50)        
  , @CountNo INT = 0        
  --, @EntityNo NVARCHAR(50)        
  , @Len INT = 0      
  , @strCountry NVARCHAR(100) = NULL    
  , @EntityLocationId Int = 0     
        
 SELECT TOP 1 @DefaultCustomerNo = ISNULL(strDefaultCustomerNo, ''),@Len = len(strDefaultCustomerNo) FROM tblMBILCompanyPreference      
 SELECT @CountNo = COUNT(1)+1 FROM tblEMEntity WHERE left(strEntityNo,@Len) = @DefaultCustomerNo      
 SET @EntityNo = @DefaultCustomerNo + CAST(@CountNo AS NVARCHAR(50))      
    
 EXEC uspEMCreateEntityById        
  @Id = @EntityNo,        
  @Type = 'Customer',        
  @UserId = @UserId,        
  @Message = @Message OUTPUT,        
  @EntityId = @EntityId OUTPUT      
      
  IF @EntityId IS NOT NULL      
  BEGIN      
   SELECT @strCountry = strCountry FROM tblSMCountry WHERE intCountryID = @intCountryId      
   SELECT @EntityLocationId = intEntityLocationId from tblEMEntityLocation where intEntityId = @EntityId    
    
 Update tblARCustomer       
 SET intTermsId = @intTermId    
 ,intBillToId = @EntityLocationId    
 ,intShipToId = @EntityLocationId    
 WHERE intEntityId = @EntityId      
     
 Update tblEMEntity set strName = @strName where intEntityId = @EntityId    
    
 Update tblEMEntityLocation      
 SET  strState = @strState      
  ,intFreightTermId = @intFreightTermId      
  ,strCountry = @strCountry      
  ,strCity = @strCity      
  ,strAddress = @strAddress      
  ,strZipCode = @strZipCode      
  ,strLocationName = @strLocation      
 WHERE intEntityId = @EntityId      
      
    
 DECLARE @ContactId AS INT = (SELECT [intEntityContactId] FROM [tblEMEntityToContact] WHERE ysnDefaultContact = 1  and intEntityId = @EntityId)      
 UPDATE Con      
 SET Con.strEmail = @strEmail    
    ,Con.strName = @strName    
 FROM tblEMEntity Con      
 WHERE Con.intEntityId = @ContactId      
      
 If NOT EXISTS(SELECT TOP 1 1 FROM tblEMEntityPhoneNumber WHERE intEntityId = @ContactId)      
 BEGIN      
  INSERT INTO tblEMEntityPhoneNumber(intEntityId,strPhone,strPhoneCountry,strPhoneArea,strPhoneLocal,strPhoneExtension,strPhoneLookUp,strFormatCountry,strFormatArea,strFormatLocal,intCountryId,intAreaCityLength)  
  Select TOP 1 @ContactId as intEntityId  
    ,@strPhone as strPhone  
    ,'' as strPhoneCountry  
    ,'' as strPhoneArea  
    ,'' as strPhoneLocal  
    ,'' as strPhoneExtension  
    ,@strPhone as strPhoneLookUp  
    ,strCountryFormat as strFormatCountry  
    ,strAreaCityFormat as strFormatArea  
    ,strLocalNumberFormat as strFormatArea  
    ,intCountryID  
    ,intAreaCityLength   
 From tblSMCountry where intCountryID = @intCountryId     
 END     
   
 IF NOT EXISTS(SELECT TOP 1 1 FROM tblEMEntityMobileNumber WHERE intEntityId = @ContactId)      
 BEGIN      
  INSERT INTO tblEMEntityMobileNumber(intEntityId,strPhone,strPhoneCountry,strPhoneArea,strPhoneLocal,strPhoneExtension,strPhoneLookUp,strFormatCountry,strFormatArea,strFormatLocal,intCountryId,intAreaCityLength)  
  Select TOP 1 @ContactId as intEntityId  
    ,@strMobile as strPhone  
    ,'' as strPhoneCountry  
    ,'' as strPhoneArea  
    ,'' as strPhoneLocal  
    ,'' as strPhoneExtension  
    ,@strMobile as strPhoneLookUp  
    ,strCountryFormat as strFormatCountry  
    ,strAreaCityFormat as strFormatArea  
    ,strLocalNumberFormat as strFormatArea  
    ,intCountryID  
    ,intAreaCityLength   
 From tblSMCountry where intCountryID = @intCountryId     
 END  
  
 IF NOT EXISTS(SELECT TOP 1 1 FROM tblTMCustomer where intCustomerNumber = @EntityId)  
 BEGIN  
 INSERT INTO tblTMCustomer(intCurrentSiteNumber, intCustomerNumber, intConcurrencyId)      
  VALUES (0, @EntityId, 1)  
 END  
     
END      
    
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